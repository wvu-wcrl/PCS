classdef LinkSimulation < Simulation
    
    properties
        EsN0    % Es/N0 in Linear.
        EbN0    % Eb/N0 in Linear.
        NumNewPoints
        UpperSymbolBoundValue
        UpperBitBoundValue
        RunMode = 0;  % Running Mode: 0 = Local, 1 = Cluster
    end
    
    methods( Static )
        function UpperSymbolBoundValue = UnionBoundSymbol( SignalSet, EsN0, SignalProb )
            if nargin<3, SignalProb = []; end
            Distance = AWGN.GetSignalDistance(SignalSet);
            
            UpperSymbolBoundValue = zeros(1, length(EsN0));
            for m = 1:length(EsN0)
                QValues = AWGN.ClculateQValues( Distance, EsN0(m) );
                % Calculate conditional symbol error bound.
                CondSymbolErrorBound = sum(QValues);
                UpperSymbolBoundValue(m) = AWGN.GetUnionBoundSymbol(CondSymbolErrorBound, SignalProb);
            end
        end
        
        function UpperBitBoundValue = UnionBoundBit( SignalSet, EsN0, SignalProb )
            Distance = AWGN.GetSignalDistance(SignalSet);
            NoSignals = size( SignalSet, 2);    % Determine the number of signals.
            HammingDistance = AWGN.SymbolHammingDis(NoSignals);
            
            UpperBitBoundValue = zeros(1, length(EsN0));
            for m = 1:length(EsN0)
                CondBitErrorBound = AWGN.CondUnionBoundBit( Distance, EsN0(m), HammingDistance );
                % Calculate the union bound on average bit error probability.
                if (nargin<3 || isempty(SignalProb))
                    UpperBitBoundValue(m) = sum(CondBitErrorBound) / NoSignals;
                else
                    UpperBitBoundValue(m) = sum( CondBitErrorBound .* (SignalProb/sum(SignalProb)) );
                end
            end
        end
    end
    
    methods
        function obj = LinkSimulation(SimParam)
            obj.SimParam = SimParam;
            if isfield( SimParam, 'SNR' )
                obj.NumNewPoints = length( SimParam.SNR );
            end
            % Make sure that number of MaxTrials and number of SNR points are the same.
            if isfield( SimParam, 'MaxTrials' )
                if ( length( SimParam.MaxTrials ) == 1 )
                    obj.SimParam.MaxTrials = SimParam.MaxTrials * ones(size(SimParam.SNR));
                elseif ( length( SimParam.MaxTrials ) ~= length( SimParam.SNR ) )
                    error( 'Number of MaxTrials must match number of SNR points or it should be a scalar.' );
                end
            end
            
            % Determine Es/N0 in linear.
            if ( strcmpi(SimParam.SNRType(2), 'b') ) % Eb/N0
                obj.EbN0 = 10.^(SimParam.SNR/10);
                obj.EsN0 = obj.EbN0 * log2(SimParam.ChannelObj.ModulationObj.Order);
            else % Es/N0
                obj.EsN0 = 10.^(SimParam.SNR/10);
                obj.EbN0 = obj.EsN0 / ( log2(SimParam.ChannelObj.ModulationObj.Order) );
            end
            obj.SimStateInit();
            obj.UpperSymbolBoundValue = obj.UnionBoundSymbol( SimParam.ChannelObj.ModulationObj.SignalSet, obj.EsN0, SimParam.ChannelObj.ModulationObj.SignalProb );
            obj.UpperBitBoundValue = obj.UnionBoundBit( SimParam.ChannelObj.ModulationObj.SignalSet, obj.EsN0, SimParam.ChannelObj.ModulationObj.SignalProb );
        end
        
        function SimStateInit(obj)
            % For Uncoded Modulation:
            SimState.Trials = zeros( 1,  obj.NumNewPoints );
            SimState.SymbolErrors = zeros( 1, obj.NumNewPoints );
            SimState.BitErrors = zeros( 1, obj.NumNewPoints );            
            SimState.BER = SimState.Trials;
            SimState.SER = SimState.Trials;

            obj.SimState = SimState;
        end
        
        function SingleSimulate(obj)
            Test = false;              % turning off tests (scheduler will decided if needs to run full work unit) 
            TestInactivation = false;  % don't want to deactivate in this method when error rates below minBER or minSER
            ElapsedTime = 0;
            if(Test)
                RemainingSymError = obj.SimParam.MaxSymErrors - obj.SimState.SymbolErrors;
                RemainingSymError(RemainingSymError<0) = 0;
                % Determine the number of remaining trials reqiured for each SNR point.
                RemainingTrials = obj.SimParam.MaxTrials - obj.SimState.Trials;
                RemainingTrials(RemainingTrials<0) = 0;
                % Determine the position of active SNR points based on the number of remaining symbol errors and trials.
                OldActiveSNRPoints = ( (RemainingSymError>0) & (RemainingTrials>0) );
            end
%             if (fopen(obj.SimParam.FileName) ~= -1)
%                 NewParam = load(obj.SimParam.FileName, 'SimParam', 'SimState');
%                 obj.SimState = NewParam.SimState;
%                 obj.SimParam = NewParam.SimParam;
%             end
            
            % Accumulate errors for different SNR points unitil time is up.
            while ElapsedTime < obj.SimParam.MaxRunTime
                % Determine the number of remaining symbol errors reqiured for each SNR point.
                RemainingSymError = obj.SimParam.MaxSymErrors - obj.SimState.SymbolErrors;
                RemainingSymError(RemainingSymError<0) = 0;
                % Determine the number of remaining trials reqiured for each SNR point.
                RemainingTrials = obj.SimParam.MaxTrials - obj.SimState.Trials;
                RemainingTrials(RemainingTrials<0) = 0;
                % Determine the position of active SNR points based on the number of remaining symbol errors and trials.
                ActiveSNRPoints = ( (RemainingSymError>0) & (RemainingTrials>0) );
                
                % Check if we can discard SNR points whose BER WILL be less than SimParam.minBER.
                LastInactivePoint = find(ActiveSNRPoints == 0, 1, 'last');
                if ( ~isempty(LastInactivePoint) && ...
                     (obj.SimState.BER(1, LastInactivePoint) ~=0) && (obj.SimState.BER(1, LastInactivePoint) < obj.SimParam.minBER) && ...
                     (obj.SimState.SER(1, LastInactivePoint) ~=0) && (obj.SimState.SER(1, LastInactivePoint) < obj.SimParam.minSER) )
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
                        fprintf( 'The simulation for SNR=%.2f dB is finished.\n', obj.SimParam.SNR(FinishedSNRID) );
                    end
                end
                
                obj.NumNewPoints = sum(ActiveSNRPoints);
                tic;
                if obj.NumNewPoints ~= 0
                    SNRPoint = randp(ActiveSNRPoints);    % Choose SNR point uniformly.
%                     SNRPoint = randp(RemainingBitError);    % Choose SNR point based on remaining errors required.
                    % Loop until either there are enough trials or enough errors or the time is up.
                    while ( ( obj.SimState.Trials( 1, SNRPoint) < obj.SimParam.MaxTrials(SNRPoint) ) && ...
                            ( obj.SimState.SymbolErrors(1, SNRPoint) < obj.SimParam.MaxSymErrors(SNRPoint) ) )
                        % Increment the trials counter.
                        obj.SimState.Trials(1, SNRPoint) = obj.SimState.Trials(1, SNRPoint) + 1;
                        [NumBitError, NumSymbolError] = obj.Trial(obj.EsN0(SNRPoint));
                        obj.UpdateErrorRate(SNRPoint, NumBitError, NumSymbolError);

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
            if ~obj.RunMode % Only do this if running locally
                obj.Save();
            end
        end
        
        
        function [NumBitError, NumSymbolError] = Trial(obj, EsN0)
            DataSymbols = obj.SimParam.CodedModObj.Encode();
            SymbolLikelihood = obj.SimParam.ChannelObj.ChannelUse(DataSymbols, EsN0);
            [NumBitError, NumSymbolError] = obj.SimParam.CodedModObj.ErrorCount(SymbolLikelihood);
        end
        
        function UpdateErrorRate(obj, SNRPoint, NumBitError, NumSymbolError)
            % Update bit and symbol error counter.
            obj.SimState.BitErrors( 1, SNRPoint ) = obj.SimState.BitErrors( 1, SNRPoint ) + NumBitError;
            obj.SimState.SymbolErrors( 1, SNRPoint ) = obj.SimState.SymbolErrors( 1, SNRPoint ) + NumSymbolError;
            obj.SimState.BER(1, SNRPoint) = obj.SimState.BitErrors(1, SNRPoint) ./ ( obj.SimState.Trials(1, SNRPoint) * obj.SimParam.CodedModObj.DataLength );
            obj.SimState.SER(1, SNRPoint) = obj.SimState.SymbolErrors(1, SNRPoint) ./ ( obj.SimState.Trials(1, SNRPoint) * obj.SimParam.CodedModObj.BlockLength );
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