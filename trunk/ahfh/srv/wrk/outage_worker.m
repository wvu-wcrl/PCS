% outate_worker
%
% computes the outage

function outage_worker(n,ahfhRoot)
% Outage Worker.  Loads a Job and runs it.
%
% The JobFile contains a JobParam structure containing the following
% elements:
%   Gamma  % SNR values
%   Beta   % Threholds 
%   p      % Collision probabilities
%   NetworkFileName  % Name of file in the NetworksDir containing network
%   description (in the form of an OutageNakagami object called "b")
%

% build directories
InDir = [ahfhRoot '/input/' ];
OutDir = [ahfhRoot '/output/'];
IndicesDir = [ahfhRoot '/indices/'];
NetworksDir = [ahfhRoot '/networks/'];
LogDir = [ahfhRoot '/log/'];
RunningDir = [ahfhRoot '/running/' ];

TempFile = ['TempSave' int2str(n) '.mat'];
ChmodStr = ['chmod 666 ' TempFile];
MovStr = ['mv ' TempFile ' ' OutDir];

% update path
MatDir = [ahfhRoot, '/mat'];
addpath( MatDir );

running = 1;
PauseTime = 1;

% create a logfile for this worker
LogFile = ['Worker' int2str(n) '.log'];
fid = fopen( [LogDir LogFile], 'a+' );

[tilde, host] = system( 'hostname' );
msg = sprintf( 'Worker %s started at %s on host %s\nRoot dir is %s\n', int2str(n), datestr(clock), host, ahfhRoot );
fprintf( msg );
fprintf( fid, msg );

while( running )
    % look to see if there are any .mat files in the InDir
    D = dir( [InDir '*.mat'] );
    
    if ~isempty(D) 
        % start a timer
        t1 = tic;
        
        % pick a file at random
        InFileIndex = randint( 1, 1, [1 length(D)]);
        
        % construct the filename
        InFile = D(InFileIndex).name;
        OutFile = InFile;
       
        msg = sprintf( 'Servicing job %s using worker %d at %s on host %s', InFile, n, datestr(clock), host );
        fprintf( msg );
        fprintf( fid, msg );

        % try to move file to the running directory it
        try
            msg = sprintf( 'Moving input file to Running directory\n' );
            fprintf( msg );
            fprintf( fid, msg );
            
            RunningFileName = [ RunningDir 'Worker' int2str(n) '.' D(InFileIndex).name ];
            system( ['mv ' InDir D(InFileIndex).name ' ' RunningFileName] );
  
            success = 1;
        catch
            % file was bad, kick out of loop
            msg = sprintf( 'Error: Input File could not be moved to Running Directory\n' );
            fprintf( msg );
            fprintf( fid, msg );
            success = 0;
        end

        % change the file permission
        if (success)
            try
                msg = sprintf( 'Changing permissions of the Running file\n' );
                fprintf( msg );
                fprintf( fid, msg );
                
                % change the permissions
                system( ['chmod 666 ' RunningFileName ] );
                
                success = 1;
            catch
                % can't change permission, kick out of loop
                msg = sprintf( 'Error: Could not change permission of Running file\n' );
                fprintf( msg );
                fprintf( fid, msg );
                success = 0;
            end
        end
        
        
        % try to load the input file from the running directory
        if (success)
            msg = sprintf( 'Loading input file\n' );
            fprintf( msg ); fprintf( fid, msg );
            pause( 0.25 ); % short pause before trying to load file.
            
            try                
                load( RunningFileName, 'JobParam' );
                success = 1;
            catch                
                % file was bad, kick out of loop
                msg = sprintf( 'Error: Input File could not be loaded from Running Directory\n' );
                fprintf( msg );
                fprintf( fid, msg );
                success = 0;
            end
        end
        
        % try to load the Network Description file
        if (success)         
            NetworkFile = JobParam.NetworkFileName;
            try
                msg = sprintf( 'Loading Network file\n' );
                fprintf( msg ); fprintf( fid, msg );
                
                load( [NetworksDir NetworkFile], 'Omega' );
                success = 1;
            catch
                % file was bad, kick out of loop
                msg = sprintf( 'Error: Network File could not be loaded\n' );
                fprintf( msg );
                fprintf( fid, msg );
                success = 0;
            end
        end
            
        % try to compute the outage probability
        if (success)
            try
                msg = sprintf( 'Computing outage probabilty\n' );
                fprintf( msg ); fprintf( fid, msg );
                
                % Adjust Omega by the processing gain
                if  isfield( JobParam, 'PG' )
                    Omega = Omega/JobParam.PG;
                end
                
                % Create the OutageNakagami object
                b = OutageNakagami( Omega, JobParam.m, JobParam.m_i, IndicesDir );
                                
                % determine if adjacent channel interference is considered
                Splatter = 0;
                if isfield( JobParam, 'Fibp' );
                    if ( JobParam.Fibp < 1 )
                        Splatter = 1;
                    end
                end
                
                % determine if there is shadowing
                if isfield( JobParam, 'ShadowStd' )
                    if (JobParam.ShadowStd > 0)
                        b.SetShadowing( JobParam.ShadowStd );
                    end
                end
                
                ComputeCDF = false;
                if isfield( JobParam, 'ComputeCDF' )
                    if JobParam.ComputeCDF
                        ComputeCDF = true;
                    end
                end
                
                % Compute the outage
                if Splatter
                    msg = sprintf( 'Considering Spectral Splatter\n' );
                    fprintf( msg ); fprintf( fid, msg );
                    if ComputeCDF
                        epsilon = b.ComputeSingleOutageSplatter( JobParam.Gamma, JobParam.Beta(1), JobParam.p(1), JobParam.Fibp(1) );
                    else
                        epsilon = b.ComputeOutage( JobParam.Gamma, JobParam.Beta, JobParam.p, JobParam.Fibp );
                    end                    
                else
                    if ComputeCDF
                        epsilon = b.ComputeSingleOutage( JobParam.Gamma, JobParam.Beta(1), JobParam.p(1) );
                    else
                        epsilon = b.ComputeOutage( JobParam.Gamma, JobParam.Beta, JobParam.p );
                    end
                end
                
                msg = sprintf( 'Done computing outage probabilty\n' );
                fprintf( msg );
                fprintf( fid, msg );
                success = 1;
            catch
                % file was bad, kick out of loop
                msg = sprintf( '\nError: Could not compute outage probability\n\n' );
                fprintf( msg );
                fprintf( fid, msg );
                success = 0;
            end
        end

        
        % try to save it
        if (success)
            try
                msg = sprintf( 'Saving output file\n' );
                fprintf( msg );
                fprintf( fid, msg );
                
                % save to temporary file
                save( TempFile, 'JobParam', 'epsilon' );
                system( ChmodStr );
                system( [MovStr OutFile] );
                
                success = 1;
            catch
                % file cound not save, kick out of loop
                msg = sprintf( 'Error: Output File could not be saved\n' );
                fprintf( msg );
                fprintf( fid, msg );
                
                success = 0;
            end
        end
        
        % delete running file
        if (success)
            try
                msg = sprintf( 'Deleting Running file\n' );
                fprintf( msg );
                fprintf( fid, msg );
                
                delete( RunningFileName );
                
                % Done!
                msg = sprintf( 'Completed job at %s for a runtime of %f seconds\n', datestr(clock), toc(t1) );
                fprintf( msg );
                fprintf( fid, msg );
            catch
                % fcould not delete, just a warning
                msg = sprintf( 'Warning: Running file could not be deleted\n' );
                fprintf( msg );
                fprintf( fid, msg );
            end
        end
        
        msg = sprintf( '\nWaiting for next job...\n\n' );
        fprintf( msg );
        fprintf( fid, msg );
    end
        
    
    % wait before looping
    pause( PauseTime );
    
end
    