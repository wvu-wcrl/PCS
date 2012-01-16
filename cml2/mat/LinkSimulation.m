classdef LinkSimulation < Simulation
    
    properties
        EsN0    % Es/N0 in Linear.
        EbN0    % Eb/N0 in Linear.
    end
    
    properties( SetAccess = protected )
        NumNewPoints
        RunMode = 1;  % Running Mode: 0 = Local, 1 = Cluster.
    end
    
    methods
        function obj = LinkSimulation(SimParam)
            obj.SimParam = SimParam;
            if isfield( SimParam, 'SNR' )
                obj.NumNewPoints = length( SimParam.SNR );
            end
            % Make sure that the number of MaxTrials and number of SNR points are the same.
            if isfield( SimParam, 'MaxTrials' )
                if isscalar( SimParam.MaxTrials )
                    obj.SimParam.MaxTrials = SimParam.MaxTrials * ones(size(SimParam.SNR));
                elseif ( length( SimParam.MaxTrials ) ~= length( SimParam.SNR ) )
                    error( 'LinkSimulation:MaxTrialsLength','The number of MaxTrials must match the number of SNR points or it should be a scalar.' );
                end
            end
            
            % Determine Es/N0 in linear.
            if( strcmpi(SimParam.SNRType(2), 'b') ) % Eb/N0
                obj.EbN0 = 10.^(SimParam.SNR/10);
                obj.EsN0 = obj.EbN0 * SimParam.CodedModObj.ChannelCodeObject.Rate;
            else % Es/N0
                obj.EsN0 = 10.^(SimParam.SNR/10);
                obj.EbN0 = obj.EsN0 / SimParam.CodedModObj.ChannelCodeObject.Rate;
            end
            obj.SimStateInit();
        end
        
        function SimStateInit(obj)
            SimState.Trials = zeros( 1,  obj.NumNewPoints );
            SimState.BitErrors = SimState.Trials;
            SimState.FrameErrors = SimState.Trials;
            SimState.BER = SimState.Trials;
            SimState.FER = SimState.Trials;

            obj.SimState = SimState;
        end
        
        function SimState = SingleSimulate(obj, SimParam)
            if(nargin>=2 && ~isempty(SimParam)), obj.SimParam = SimParam; end
            Test = false;              % Turning off test (scheduler will decide if it needs to run full work unit).
            TestInactivation = false;  % Don't want to deactivate in this method when error rate is below minBER or minFER.
            ElapsedTime = 0;
            if(Test)
                % Determine the number of remaining bit errors reqiured for each SNR point.
                RemainingBitError = obj.SimParam.MaxBitErrors - obj.SimState.BitErrors;
                RemainingBitError(RemainingBitError<0) = 0;
                % Determine the number of remaining trials reqiured for each SNR point.
                RemainingTrials = obj.SimParam.MaxTrials - obj.SimState.Trials;
                RemainingTrials(RemainingTrials<0) = 0;
                % Determine the position of active SNR points based on the number of remaining bit errors and trials.
                OldActiveSNRPoints = ( (RemainingBitError>0) & (RemainingTrials>0) );
            end
%             if (fopen(obj.SimParam.FileName) ~= -1)
%                 NewParam = load(obj.SimParam.FileName, 'SimParam', 'SimState');
%                 obj.SimState = NewParam.SimState;
%                 obj.SimParam = NewParam.SimParam;
%             end
            
            % Accumulate errors for different SNR points unitil time is up.
            while ElapsedTime < obj.SimParam.SimTime
                % Determine the number of remaining bit errors reqiured for each SNR point.
                RemainingBitError = obj.SimParam.MaxBitErrors - obj.SimState.BitErrors;
                RemainingBitError(RemainingBitError<0) = 0;
                % Determine the number of remaining trials reqiured for each SNR point.
                RemainingTrials = obj.SimParam.MaxTrials - obj.SimState.Trials;
                RemainingTrials(RemainingTrials<0) = 0;
                % Determine the position of active SNR points based on the number of remaining bit errors and trials.
                ActiveSNRPoints = ( (RemainingBitError>0) & (RemainingTrials>0) );
                
                % Check if we can discard SNR points whose BER WILL be less than SimParam.minBER.
                LastInactivePoint = find(ActiveSNRPoints == 0, 1, 'last');
                if ( ~isempty(LastInactivePoint) && ...
                     (obj.SimState.BER(1, LastInactivePoint) ~=0) && (obj.SimState.BER(1, LastInactivePoint) < obj.SimParam.minBER) && ...
                     (obj.SimState.FER(1, LastInactivePoint) ~=0) && (obj.SimState.FER(1, LastInactivePoint) < obj.SimParam.minFER) )
                    ActiveSNRPoints(LastInactivePoint:end) = 0;
                    if(Test && (sum(OldActiveSNRPoints-ActiveSNRPoints) ~= 0) && TestInactivation)
                        fprintf( '\nThe simulation for SNR=%.2f dB and all SNRs above it is not required since BER=%e @ SNR=%.2f dB.\n', ...
                            obj.SimParam.SNR(LastInactivePoint+1), obj.SimState.BER(1, LastInactivePoint), obj.SimParam.SNR(LastInactivePoint) );
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
                tic;
                if obj.NumNewPoints ~= 0
                    SNRPoint = randp(ActiveSNRPoints);    % Choose SNR point uniformly.
%                     SNRPoint = randp(RemainingBitError);    % Choose SNR point based on remaining bit errors required.
                    % Loop until either there are enough trials or enough errors or the time is up.
                    while ( ( obj.SimState.Trials( 1, SNRPoint) < obj.SimParam.MaxTrials(SNRPoint) ) && ...
                            ( obj.SimState.BitErrors(1, SNRPoint) < obj.SimParam.MaxBitErrors(SNRPoint) ) )
                        % Increment the trials counter.
                        obj.SimState.Trials(1, SNRPoint) = obj.SimState.Trials(1, SNRPoint) + 1;
                        [NumBitError, NumCodewordError] = obj.Trial(obj.EsN0(SNRPoint));
                        obj.UpdateErrorRate(SNRPoint, NumBitError, NumCodewordError);

                        % Determine if it is time to save and exit from while loop (once per CheckPeriod trials)
                        if ~rem(obj.SimState.Trials(1, SNRPoint), obj.SimParam.CheckPeriod)
                            break;
                        end
                    end
                    ElapsedTime = toc + ElapsedTime;
                    if(Test), OldActiveSNRPoints = ActiveSNRPoints; end
                else
                    return;
                end
            end
            % Save the results only once when the time for simulation is up.
            if ~obj.RunMode % Only do this if running locally.
                obj.Save();
            end
            SimState = obj.SimState;
        end
        
        
        function [NumBitError, NumCodewordError] = Trial(obj, EsN0)
            DataSymbols = obj.SimParam.CodedModObj.Encode();
            SymbolLikelihood = obj.SimParam.ChannelObj.ChannelUse(DataSymbols, EsN0);
            [NumBitError, NumCodewordError] = obj.SimParam.CodedModObj.ErrorCount(SymbolLikelihood);
        end
        
        function UpdateErrorRate(obj, SNRPoint, NumBitError, NumCodewordError)
            % Update bit and codeword error counter.
            obj.SimState.BitErrors( 1, SNRPoint ) = obj.SimState.BitErrors( 1, SNRPoint ) + NumBitError;
            obj.SimState.FrameErrors( 1, SNRPoint ) = obj.SimState.FrameErrors( 1, SNRPoint ) + NumCodewordError;
            obj.SimState.BER(1, SNRPoint) = obj.SimState.BitErrors(1, SNRPoint) ./ ( obj.SimState.Trials(1, SNRPoint) * ...
                obj.SimParam.CodedModObj.NumCodewords * obj.SimParam.CodedModObj.ChannelCodeObject.DataLength );
            obj.SimState.FER(1, SNRPoint) = obj.SimState.FrameErrors(1, SNRPoint) ./ ...
                ( obj.SimState.Trials(1, SNRPoint) * obj.SimParam.CodedModObj.NumCodewords );
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