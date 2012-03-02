classdef LinkSimulation < Simulation
    
    properties
        EsN0        % Es/N0 in Linear.
        EbN0        % Eb/N0 in Linear.
        RunMode = 1 % Running Mode: 0 = Local, 1 = Cluster.
    end
    
    properties( SetAccess = protected )
        NumNewPoints
        MaxIteration    % Maximum number of decoding iterations.
    end
    
    methods( Access = protected )
        function SimParamInit( obj, SimParam )
            if isfield( SimParam, 'SNR' )
                obj.NumNewPoints = length( SimParam.SNR );
            end
            % Make sure that the number of MaxTrials and number of SNR points are the same.
            if isfield( SimParam, 'MaxTrials' )
                if isscalar( SimParam.MaxTrials )
                    SimParam.MaxTrials = SimParam.MaxTrials * ones(size(SimParam.SNR));
                elseif ( length( SimParam.MaxTrials ) ~= length( SimParam.SNR ) )
                    error( 'LinkSimulation:MaxTrialsLength','The number of MaxTrials must match the number of SNR points or it should be a scalar.' );
                end
            end
            
            obj.MaxIteration = SimParam.CodedModObj.ChannelCodeObject.MaxIteration;
            
            % Determine Es/N0 in linear.
            % This was corrected on 02/05/2011. Account for modulation order.
            if( strcmpi(SimParam.SNRType(2), 'b') )     % Eb/N0
                obj.EbN0 = 10.^(SimParam.SNR/10);
                obj.EsN0 = obj.EbN0 * SimParam.CodedModObj.ChannelCodeObject.Rate * SimParam.CodedModObj.Mapper.NoBitsPerSymb;
            elseif( strcmpi(SimParam.SNRType(2), 's') ) % Es/N0
                obj.EsN0 = 10.^(SimParam.SNR/10);
                obj.EbN0 = obj.EsN0 / ( SimParam.CodedModObj.ChannelCodeObject.Rate * SimParam.CodedModObj.Mapper.NoBitsPerSymb );
            end
            
            obj.SimParam = SimParam;
        end
        
        
        function SimStateInit(obj)
            SimState.Trials = zeros(1, obj.NumNewPoints);
            SimState.BitErrors = zeros(obj.MaxIteration, obj.NumNewPoints);
            SimState.FrameErrors = SimState.BitErrors;
            SimState.BER = SimState.BitErrors;
            SimState.FER = SimState.BitErrors;
            [Status, SimState.NodeID] = system('hostname');
            SimState.StartTime = 0;
            SimState.StopTime = 0;

            obj.SimState = SimState;
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
    
    methods
        function obj = LinkSimulation(SimParam)
            obj.SimParamInit( SimParam );
            obj.SimStateInit();
        end
        
        
        function SimState = SingleSimulate(obj, SimParam)
            obj.SimState.StartTime = clock;
            [Status, SimState.NodeID] = system('hostname');
            if(nargin>=2 && ~isempty(SimParam)), obj.SimParamInit( SimParam ); end
            Test = false;              % Turning off test (scheduler will decide if it needs to run full work unit).
            TestInactivation = false;  % Don't want to deactivate in this method when error rate is below minBER or minFER.
            ElapsedTime = 0;
            if(Test)
                % Determine the number of remaining frame errors reqiured for each SNR point.
                RemainingFrameError = obj.SimParam.MaxFrameErrors - obj.SimState.FrameErrors(end,:);
                RemainingFrameError(RemainingFrameError<0) = 0;
                % Determine the number of remaining trials reqiured for each SNR point.
                RemainingTrials = obj.SimParam.MaxTrials - obj.SimState.Trials;
                RemainingTrials(RemainingTrials<0) = 0;
                % Determine the position of active SNR points based on the number of remaining frame errors and trials.
                OldActiveSNRPoints = ( (RemainingFrameError>0) & (RemainingTrials>0) );
            end
%             if (fopen(obj.SimParam.FileName) ~= -1)
%                 NewParam = load(obj.SimParam.FileName, 'SimParam', 'SimState');
%                 obj.SimState = NewParam.SimState;
%                 obj.SimParam = NewParam.SimParam;
%             end
            
            % Accumulate errors for different SNR points unitil time is up.
            while ElapsedTime < obj.SimParam.SimTime
                TaskTime = tic;
                % Determine the number of remaining frame errors reqiured for each SNR point.
                RemainingFrameError = obj.SimParam.MaxFrameErrors - obj.SimState.FrameErrors(end,:);
                RemainingFrameError(RemainingFrameError<0) = 0;
                % Determine the number of remaining trials reqiured for each SNR point.
                RemainingTrials = obj.SimParam.MaxTrials - obj.SimState.Trials;
                RemainingTrials(RemainingTrials<0) = 0;
                % Determine the position of active SNR points based on the number of remaining frame errors and trials.
                ActiveSNRPoints = ( (RemainingFrameError>0) & (RemainingTrials>0) );
                
                % Check if we can discard SNR points whose BER and FER WILL be less than SimParam.minBER and SimParam.minFER.
                LastInactivePoint = find(ActiveSNRPoints == 0, 1, 'last');
                if( ~isempty(LastInactivePoint) && ...
                        ... % Changed on February 24, 2012. When SNR point is inactive, its BER or FER CAN be ZERO.
                        ...( ( (obj.SimState.BER(end, LastInactivePoint) ~=0) && (obj.SimState.BER(end, LastInactivePoint) < obj.SimParam.minBER) ) || ...
                        ...( (obj.SimState.FER(end, LastInactivePoint) ~=0) && (obj.SimState.FER(end, LastInactivePoint) < obj.SimParam.minFER) ) ) )
                        ( obj.SimState.BER(end,LastInactivePoint) < obj.SimParam.minBER || obj.SimState.FER(end,LastInactivePoint) < obj.SimParam.minFER ) )
                    ActiveSNRPoints(LastInactivePoint:end) = 0;
                    if(Test && (sum(OldActiveSNRPoints-ActiveSNRPoints) ~= 0) && TestInactivation)
                        fprintf( '\nThe simulation for SNR=%.2f dB and all SNRs above it is not required since BER=%e @ SNR=%.2f dB.\n', ...
                            obj.SimParam.SNR(LastInactivePoint+1), obj.SimState.BER(end, LastInactivePoint), obj.SimParam.SNR(LastInactivePoint) );
                        OldActiveSNRPoints = ActiveSNRPoints;
                        TestInactivation = false;
                    end
                end
                
                if(Test)
                    if sum(OldActiveSNRPoints-ActiveSNRPoints) ~= 0
                        FinishedSNRID = find(OldActiveSNRPoints-ActiveSNRPoints == 1);
                        fprintf( '\nThe simulation for SNR=%.2f dB is finished.\n', obj.SimParam.SNR(FinishedSNRID) );
                    end
                end
                
                obj.NumNewPoints = sum(ActiveSNRPoints);
                if obj.NumNewPoints ~= 0
                    SNRPoint = randp(ActiveSNRPoints);      % Choose SNR point uniformly.
                    % SNRPoint = randp(RemainingFrameError);% Choose SNR point based on remaining frame errors required.
                    msg = sprintf('\nMore TRIALS are run for simulation of SNR = %.2f dB.\n\n', obj.SimParam.SNR(SNRPoint));
                    fprintf( msg );
                    % Loop until either there are enough trials or enough errors or the time is up.
                    while ( ( obj.SimState.Trials(SNRPoint) < obj.SimParam.MaxTrials(SNRPoint) ) && ...
                            ( obj.SimState.FrameErrors(end, SNRPoint) < obj.SimParam.MaxFrameErrors(SNRPoint) ) )
                        % Increment the trials counter.
                        obj.SimState.Trials(SNRPoint) = obj.SimState.Trials(SNRPoint) + 1;
                        [NumBitError, NumCodewordError] = obj.Trial(obj.EsN0(SNRPoint));
                        if( NumCodewordError(end)>0 ), fprintf('x');
                        else fprintf('.'); end
                        obj.UpdateErrorRate(SNRPoint, NumBitError, NumCodewordError);

                        % Determine if it is time to save and exit from while loop (once per CheckPeriod trials).
                        if ~rem(obj.SimState.Trials(SNRPoint), obj.SimParam.CheckPeriod)
                            break;
                        end
                    end
                    ElapsedTime = toc(TaskTime) + ElapsedTime;
                    fprintf('\n');
                    if(Test), OldActiveSNRPoints = ActiveSNRPoints; end
                else
                    obj.SimState.StopTime = clock;
                    SimState = obj.SimState;
                    % Save the results only once when the time for simulation is up.
                    if ~obj.RunMode % Only do this if running locally.
                        obj.Save();
                    end
                    return;
                end
            end
            obj.SimState.StopTime = clock;
            SimState = obj.SimState;
            % Save the results only once when the time for simulation is up.
            if ~obj.RunMode % Only do this if running locally.
                obj.Save();
            end
        end
        
        
        function [NumBitError, NumCodewordError] = Trial(obj, EsN0)
            DataSymbols = obj.SimParam.CodedModObj.Encode();
            SymbolLikelihood = obj.SimParam.ChannelObj.ChannelUse(DataSymbols, EsN0);
            [NumBitError, NumCodewordError] = obj.SimParam.CodedModObj.ErrorCount(SymbolLikelihood);
        end
        
        
        function UpdateErrorRate(obj, SNRPoint, NumBitError, NumCodewordError)
            % Update bit and codeword error counter.
            obj.SimState.BitErrors(:, SNRPoint) = obj.SimState.BitErrors(:, SNRPoint) + NumBitError;
            obj.SimState.FrameErrors(:, SNRPoint) = obj.SimState.FrameErrors(:, SNRPoint) + NumCodewordError;
            obj.SimState.BER(:, SNRPoint) = obj.SimState.BitErrors(:, SNRPoint) ./ ( obj.SimState.Trials(1, SNRPoint) * ...
                obj.SimParam.CodedModObj.NumCodewords * obj.SimParam.CodedModObj.ChannelCodeObject.DataLength );
            obj.SimState.FER(:, SNRPoint) = obj.SimState.FrameErrors(:, SNRPoint) ./ ...
                ( obj.SimState.Trials(1, SNRPoint) * obj.SimParam.CodedModObj.NumCodewords );
        end
    end
end