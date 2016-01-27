SimState = struct;

SimParamFieldNames = fieldnames( SimParam );
getfield( SimParam, SimParamChangeableFieldnames{i} );
setfield( SimParam_out, SimParamChangeableFieldnames{i}, fieldvalue );

SimParam = struct(...
    'reset', 0, ...
    'FrameSize', [], ...
    'blocks_per_frame', [], ...
    'bicm', 1, ...
    'modulation', 'BPSK', ...
    'mod_order', 2, ...
    'demod_type', [], ...
    'MaxIterations', 1, ...   % Number of decoder iterations.
    'max_frame_errors', [], ...
    'channel', 'AWGN', ...
    'X_set', [], ...
    'P', [], ...
    'rate', [], ...
    'S_matrix', [], ...
    'SaveRate', 100, ...      % Number of trials between saves.
    'comment', [], ...
    'legend', [], ...
    'linetype', 'k', ...
    'plot_iterations', [], ...
    'input_FileName', [], ... % Contains results of a capacity simulation. Used for a table look-up operation.
    'trial_size', 1, ...
    'compiled_mode', 0);

SimState = struct( ...
    'capacity_sum', [], ...
    'capacity_avg', [], ...
    'throughput', [], ...
    'min_rate', [], ...
    'best_rate', [], ...
    'min_EsNodB', [], ...
    'min_EbNodB', [], ...
    'frame_errors', [], ...
    'FER', [] );



% determine where your root directory is (added 10-12-07).
load( 'CmlHome.mat' );

% determine if SimParam.FileName is relative or absolute.
if ( length( SimParam.FileName ) >= length( cml_home ) )
    temp_string = SimParam.FileName(1:length(cml_home));
    if strcmp( temp_string, cml_home )
        % this is an absolute path. strip out cml home
        SimParam_out.FileName = SimParam.FileName( length(cml_home)+1: length( SimParam.FileName ) );
    end
end

% determine if a saved file exists.
fid = fopen( [cml_home SimParam_out.FileName], 'r');

% load the file unless the simulation has been reset.
if ( (fid > 0) && ( SimParam.reset < 1 ) )
    % load the saved file
    load( [cml_home SimParam_out.FileName], '-mat' );

    % validate the unchangeable parameters.
    for i=1:length( SimParamUnchangeableFieldnames )
        if isfield( SaveParam, SimParamUnchangeableFieldnames{i} )
            % fprintf( ['\nValidating ' SimParamUnchangeableFieldnames{i} '\n' ] );

            % see if field is specified in the input scenario.
            if isfield( SimParam, SimParamUnchangeableFieldnames{i} )
                % test to see if stored is same. Start with length.
                test_length = abs( length( getfield( SaveParam, SimParamUnchangeableFieldnames{i} ) ) - length( getfield( SimParam, SimParamUnchangeableFieldnames{i} ) ) );
                test_value = 1;
                if ~test_length
                    % test value.
                    test_value = sum( abs( getfield( SaveParam, SimParamUnchangeableFieldnames{i} ) ) - abs( getfield( SimParam, SimParamUnchangeableFieldnames{i} ) ) );
                end
                if test_value
                    % they don't match, trigger a warning.
                    % if set to [] in save file, should set it to the default value.
                    if ~length( getfield( SimParam, SimParamUnchangeableFieldnames{i} ) )
                        fprintf( ['Warning: Field "' SimParamUnchangeableFieldnames{i} '" undefined in the scenario file, using default value.\n' ] );
                        SaveParam = setfield( SaveParam, SimParamUnchangeableFieldnames{i}, getfield( SimParamUnchangeable, SimParamUnchangeableFieldnames{i} ) );
                    elseif ~length( getfield( SaveParam, SimParamUnchangeableFieldnames{i} ) )
                        fprintf( ['Warning: stored value of field ' SimParamUnchangeableFieldnames{i} ' is set to [], using default value.\n' ] );
                        SaveParam = setfield( SaveParam, SimParamUnchangeableFieldnames{i}, getfield( SimParamUnchangeable, SimParamUnchangeableFieldnames{i} ) );
                    else
                        % otherwise use saved value
                        fprintf( ['Warning: field ' SimParamUnchangeableFieldnames{i} ' does not match stored value, using stored value.\n' ] );
                    end
                end
            else
                % fprintf( ['Warning: field ' SimParamUnchangeableFieldnames{i} ' not defined in the scenario file, using stored value.\n' ] );
            end

            % set the value to the saved value.
            SimParam_out = setfield( SimParam_out, SimParamUnchangeableFieldnames{i}, getfield( SaveParam, SimParamUnchangeableFieldnames{i} ) );

        else
            % Set to default value when a new value is defined.
            SimParam_out = setfield( SimParam_out, SimParamUnchangeableFieldnames{i}, getfield( SimParamUnchangeable, SimParamUnchangeableFieldnames{i} ) );
        end
    end
else
    % setup the "unchangeable" SimParam_out fields.
    for i=1:length( SimParamUnchangeableFieldnames )
        % fprintf( ['\nValidating ' SimParamUnchangeableFieldnames{i} '\n' ] );
        % initialize to default value (Corrected on 9-8-07).
        SimParam_out = setfield( SimParam_out, SimParamUnchangeableFieldnames{i}, getfield( SimParamUnchangeable, SimParamUnchangeableFieldnames{i} ) );

        if isfield( SimParam, SimParamUnchangeableFieldnames{i} )
            if ( length( getfield( SimParam, SimParamUnchangeableFieldnames{i} ) ) )
                % value is in the scenario file, so use it.
                SimParam_out = setfield( SimParam_out, SimParamUnchangeableFieldnames{i}, getfield( SimParam, SimParamUnchangeableFieldnames{i} ) );
            end
        end
    end
end


% restore the saved SimState.
if ( (fid > 0) && ( SimParam_out.reset < 1 ) )
    % determine if the SNR has changed.
    if ~exist( 'NumberNewPoints' )
        SNR_has_changed = 0;
    elseif ( length( SaveParam.SNR ) ~= NumberNewPoints )
        SNR_has_changed = 1; % a different number of SNR points.
    elseif max( SaveParam.SNR ~= SimParam.SNR )
        SNR_has_changed = 1; % different SNR points (but same number).
    end

    % will need to add or delete SNR points to the state.
    if SNR_has_changed
        fprintf( 'Warning: SNR vector does not match saved vector.\n' );
    end

    % restore saved state, one structure element at a time:
    for i=1:length( SimStateFieldnames )
        if isfield( SaveState, SimStateFieldnames{i} )
            saved_vector = getfield( SaveState, SimStateFieldnames{i} );
            if ( SNR_has_changed && ~isempty( saved_vector ) )
                % fix 6-11-06.
                row_count = size( saved_vector, 1 );
                new_vector = zeros( row_count, NumberNewPoints );

                % this logic needs to be verified 8-10-06.
                for j=1:NumberNewPoints
                    index = find( (SaveParam.SNR  <= SimParam.SNR(j) + epsilon)&(SaveParam.SNR >= SimParam.SNR(j)-epsilon) );
                    if (length( index ) > 1)
                        error( 'Duplicate SNR points in saved SimParam.' );
                    elseif (length(index) == 1)
                        new_vector(:,j) = saved_vector(:,index);
                    end
                end
                SimState = setfield( SimState, SimStateFieldnames{i}, new_vector);
            else
                SimState = setfield( SimState, SimStateFieldnames{i}, saved_vector );
            end
        end
    end
end

% alphabetize fields.
SimParam_out = orderfields( SimParam_out );
SimState = orderfields( SimState );

if (fid>0)
    fclose( fid );
end


% determine matlab version.
version_text = version;
if ( str2num( version_text(1) ) > 6)
    CodeParam.save_flag = '-v6';
else
    CodeParam.save_flag = '-mat';
end


% -----------------------------------------------------------------------------


% determine where your root directory is (added 10-12-07).
CodeParam.filename = [cml_home SimParam.filename];

% variable used for determining if the SNR has changed
SNR_has_changed = 0;

% uncoded modulation
SimState.frame_errors = zeros( 1, number_new_SNR_points );
% coded modulation
SimState.frame_errors = zeros( SimParam_out.MaxIterations, number_new_SNR_points );

% randomly seed the random number generators
rand('state',sum(100*clock));
randn('state',sum(100*clock));
% close open files (4/22/06)
fclose all;


% -----------------------------------------------------------------------------
% syms EsN0;
% Pb = PbUB( SignalSet, EsN0 );
% minEsN0 = double( solve(Pb - maxPb) );
% minEsN0dB = 10*log10(minEsN0);
% clear EsN0;