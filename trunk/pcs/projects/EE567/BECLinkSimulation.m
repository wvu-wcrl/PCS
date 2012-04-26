classdef BECLinkSimulation < Simulation

    properties
        RunMode = 1 % Running Mode: 0 = Local, 1 = Cluster.
%         SimParam = struct(...
%             'HStruct', [], ...        % A structure array corresponding to the parity-check matrix.
%             ...                       % H(j).loc_ones gives the location of ones in the jth row of H matrix.
%             'Epsilon', [], ...        % Row vector of channel erasure probabilities.
%             'MaxTrials', [], ...      % A vector of integers (or a scalar), one for each Epsilon point. Maximum number of trials to run per point.
%             'FileName', [], ...
%             'RunTime', 300, ...       % Simulation time in Seconds.
%             'CheckPeriod', 10, ...    % Checking time in number of Trials.
%             'MaxBitErrors', [], ...
%             'MaxFrameErrors', [], ...
%             'MaxIteration', [], ...   % Maximum number of decoding iterations.
%             'RandSeed', 1000*sum(clock) );
%         SimState = struct( ...
%             'Trials', [], ...
%             'BitErrors', [], ...
%             'FrameErrors', [], ...
%             'BER', [], ...
%             'FER', [] );
    end

    properties( SetAccess = protected )
        DataLength
        CodewordLength
        CodeRate
        EpsilonThresholdStar	% Maximum erasure probability.
        FullRank                % A flag of whether or not the parity-check matrix HStruct is full rank.
        NumNewPoints
    end

    methods( Static )
        function PrevStream = SetRandSeed(SeedValue)
            if( nargin<1 || isempty(SeedValue) ), SeedValue = 1000*sum(clock); end
            if( verLessThan('matlab','7.7') || ~exist('RandStream','class') )
                % RandStream class was added to MATLAB Version 7.7 Release (R2008b).
                PrevStream = rand('twister');
                rand('twister',SeedValue);
                randn('state',SeedValue);
            else
                % In newer than Version 7.7 Release (R2008b) of MATLAB, it is recommended to use RandStream class.
                CurRndStream = RandStream('mt19937ar','Seed',SeedValue);
                MethodList = methods(CurRndStream);
                if sum( strcmpi(MethodList,'setGlobalStream') )==1
                    PrevStream = RandStream.setGlobalStream(CurRndStream);
                elseif sum( strcmpi(MethodList,'setDefaultStream') )==1
                    PrevStream = RandStream.setDefaultStream(CurRndStream);
                end
            end
        end
    end

    methods
        function obj = BECLinkSimulation(SimParam)
            obj.SimParamInit( SimParam );
            obj.SimStateInit();
            if( ~isfield(SimParam, 'RandSeed') || isempty(SimParam.RandSeed) ), SimParam.RandSeed = []; end
            obj.SetRandSeed( SimParam.RandSeed );
        end

        function SimParamInit( obj, SimParam )
            if isfield( SimParam, 'Epsilon' )
                obj.NumNewPoints = length( SimParam.Epsilon );
            end
            % Make sure that the number of MaxTrials and number of Epsilon points are the same.
            if isfield( SimParam, 'MaxTrials' )
                if isscalar( SimParam.MaxTrials )
                    SimParam.MaxTrials = SimParam.MaxTrials * ones(size(SimParam.Epsilon));
                elseif ( length( SimParam.MaxTrials ) ~= length( SimParam.Epsilon ) )
                    error( 'BECLinkSimulation:MaxTrialsLength','The number of MaxTrials must match the number of Epsilon points or it should be a scalar.' );
                end
            end
            if isfield( SimParam, 'MaxFrameErrors' )
                if isscalar( SimParam.MaxFrameErrors )
                    SimParam.MaxFrameErrors = SimParam.MaxFrameErrors * ones(size(SimParam.Epsilon));
                elseif ( length( SimParam.MaxFrameErrors ) ~= length( SimParam.Epsilon ) )
                    error( 'BECLinkSimulation:MaxFrameErrorsLength','The number of MaxFrameErrors must match the number of Epsilon points or it should be a scalar.' );
                end
            end
            if isfield( SimParam, 'HStruct' )
                obj.CodewordLength = max([SimParam.HStruct(:).loc_ones]);
                obj.DataLength = obj.CodewordLength - length(SimParam.HStruct);
                [obj.EpsilonThresholdStar, obj.FullRank, obj.CodeRate] = HstructEval( SimParam.HStruct );
            end
            obj.SimParam = SimParam;
        end

        function SimStateInit(obj, SimState)
            if( nargin<2 || isempty(SimState) )
                SimState.Trials = zeros(1, obj.NumNewPoints);
                SimState.BitErrors = zeros(obj.SimParam.MaxIteration, obj.NumNewPoints);
                SimState.FrameErrors = SimState.BitErrors;
                SimState.BER = SimState.BitErrors;
                SimState.FER = SimState.BitErrors;
            end
            obj.SimState = SimState;
        end
        
        function SimState = SingleSimulate(obj, SimParam)
            if(nargin>=2 && ~isempty(SimParam)), obj.SimParamInit( SimParam ); end
            if( ~isfield(obj.SimParam, 'RandSeed') || isempty(obj.SimParam.RandSeed) ), obj.SimParam.RandSeed = []; end
            obj.SetRandSeed(obj.SimParam.RandSeed);
            ElapsedTime = 0;
            if ~obj.RunMode % If it is running locally, determine active Epsilon points.
                % If it is running on the cluster, Job Manager will decide if it needs to run full work unit.
                % Determine the number of remaining frame errors reqiured for each Epsilon point.
                RemainingFrameError = obj.SimParam.MaxFrameErrors - obj.SimState.FrameErrors(end,:);
                RemainingFrameError(RemainingFrameError<0) = 0;
                % Determine the number of remaining trials reqiured for each Epsilon point.
                RemainingTrials = obj.SimParam.MaxTrials - obj.SimState.Trials;
                RemainingTrials(RemainingTrials<0) = 0;
                % Determine the position of active Epsilon points based on the number of remaining frame errors and trials.
                OldActiveEpsilonPoints = ( (RemainingFrameError>0) & (RemainingTrials>0) );
            end

            % Accumulate errors for different Epsilon points unitil time is up.
            while ElapsedTime < obj.SimParam.RunTime
                TaskTime = tic;
                % Determine the number of remaining frame errors reqiured for each Epsilon point.
                RemainingFrameError = obj.SimParam.MaxFrameErrors - obj.SimState.FrameErrors(end,:);
                RemainingFrameError(RemainingFrameError<0) = 0;
                % Determine the number of remaining trials reqiured for each Epsilon point.
                RemainingTrials = obj.SimParam.MaxTrials - obj.SimState.Trials;
                RemainingTrials(RemainingTrials<0) = 0;
                % Determine the position of active Epsilon points based on the number of remaining frame errors and trials.
                ActiveEpsilonPoints = ( (RemainingFrameError>0) & (RemainingTrials>0) );

                if ~obj.RunMode % If it is running locally, determine if simulation for an Epsilon point is over.
                    if sum(OldActiveEpsilonPoints-ActiveEpsilonPoints) ~= 0
                        FinishedEpsilonID = find(OldActiveEpsilonPoints-ActiveEpsilonPoints == 1);
                        fprintf( '\nThe simulation for Epsilon=%.2f is finished.\n', obj.SimParam.Epsilon(FinishedEpsilonID) );
                    end
                end

                obj.NumNewPoints = sum(ActiveEpsilonPoints);
                if obj.NumNewPoints ~= 0
                    EpsilonIndex = randp(ActiveEpsilonPoints);      % Choose a random Epsilon point uniformly.
                    % EpsilonIndex = randp(RemainingFrameError);    % Choose a random Epsilon point based on remaining frame errors required.
                    fprintf( '\nMore TRIALS are run for simulation of Epsilon = %.4f.\n', obj.SimParam.Epsilon(EpsilonIndex) );
                    % Loop until either there are enough trials or enough errors or the time is up.
                    while ( ( obj.SimState.Trials(EpsilonIndex) < obj.SimParam.MaxTrials(EpsilonIndex) ) && ...
                            ( obj.SimState.FrameErrors(end, EpsilonIndex) < obj.SimParam.MaxFrameErrors(EpsilonIndex) ) )
                        % Increment the trials counter.
                        obj.SimState.Trials(EpsilonIndex) = obj.SimState.Trials(EpsilonIndex) + 1;
                        % Perform one simulation Trial.
                        NumBitError = obj.Trial(obj.SimParam.Epsilon(EpsilonIndex));
                        if( NumBitError(end)>0 )
                            fprintf('x');   % Echo 'x' when there is a frame error.
                        else
                            fprintf('.');   % Echo '.' when there is no frame error.
                        end
                        % Record the bit and frame error rates after each trial.
                        obj.UpdateErrorRate(EpsilonIndex, NumBitError);

                        % Determine if it is time to save and exit from while loop (once per CheckPeriod trials).
                        if ~rem(obj.SimState.Trials(EpsilonIndex), obj.SimParam.CheckPeriod)
                            if( ~obj.RunMode ), obj.Save(); end % Only do this if running locally.
                            break;
                        end
                    end
                    ElapsedTime = toc(TaskTime) + ElapsedTime;
                    fprintf('\n');
                    if(~obj.RunMode), OldActiveEpsilonPoints = ActiveEpsilonPoints; end
                else % There are no active Epsilon point.
                    SimState = obj.SimState;
                    % Save the results only if running locally.
                    if( ~obj.RunMode ), obj.Save(); end
                    return;
                end
            end
            SimState = obj.SimState;
            % Save the results when the time for simulation is up.
            if( ~obj.RunMode ), obj.Save(); end % Only do this if running locally.
        end

        function NumBitError = Trial(obj, Epsilon)
            % NumBitError is a vector of length MaxIteration containing the number of uncorrected BIT erasures after each iteration.
            Codeword = zeros(1,obj.CodewordLength);    % Assume all zero codeword.
            % Binary erasure channel simulation, erasure is indicated by -1.
            RXCodeword = Codeword;
            RXCodeword( rand(1,obj.CodewordLength) < Epsilon ) = -1;
            % BEC Decoder.
            [EstCodeword, NumBitError] = DecBEC( RXCodeword, obj.SimParam.HStruct, obj.SimParam.MaxIteration );
        end

        function UpdateErrorRate(obj, EpsilonIndex, NumBitError)
            % Update bit and codeword error counters.
            obj.SimState.BitErrors( :,EpsilonIndex )  = obj.SimState.BitErrors( :,EpsilonIndex ) + NumBitError;
            obj.SimState.FrameErrors( :,EpsilonIndex ) = obj.SimState.FrameErrors( :,EpsilonIndex ) + ( NumBitError > 0 );
            obj.SimState.BER( :,EpsilonIndex ) = obj.SimState.BitErrors( :,EpsilonIndex ) ./ ( obj.SimState.Trials(1, EpsilonIndex) * obj.CodewordLength);
            obj.SimState.FER( :,EpsilonIndex ) = obj.SimState.FrameErrors( :,EpsilonIndex ) ./ obj.SimState.Trials(1, EpsilonIndex);
        end

        function Save(obj)
            % Temporary filename.
            TempFile = 'TempSave.mat';
            % In case system crashes during save.
            SimState = obj.SimState;
            SimParam = obj.SimParam;
            save( TempFile, 'SimState', 'SimParam' );
            movefile( TempFile, obj.SimParam.FileName, 'f');
        end
    end
end