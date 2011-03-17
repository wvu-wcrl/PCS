classdef LinkSimulation < Simulation
    
    properties
        EsN0    % Es/N0 in Linear.
        EbN0    % Eb/N0 in Linear.
        NumNewPoints
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
            
            % Determine Es/N0.
            if ( strcmpi(SimParam.SNRType(2), 'b') ) % Eb/N0
                obj.EbN0 = 10.^(SimParam.SNR/10);
                obj.EsN0 = obj.EbN0 * log2(SimParam.ChannelObj.ModulationObj.Order);
            else % Es/N0
                obj.EsN0 = 10.^(SimParam.SNR/10);
                obj.EbN0 = obj.EsN0 / ( log2(SimParam.ChannelObj.ModulationObj.Order) );
            end
            obj.SimStateInit();
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
            ElapsedTime = 0;
%             if (fopen(obj.SimParam.FileName) ~= -1)
%                 NewParam = load(obj.SimParam.FileName, 'SimParam', 'SimState');
%                 obj.SimState = NewParam.SimState;
%                 obj.SimParam = NewParam.SimParam;
%             end
            % Accumulate errors for different SNR points unitil time is up.
            while ElapsedTime < obj.SimParam.SimTime
                RemainingBitError = obj.SimParam.MaxBitErrors - obj.SimState.BitErrors;
                RemainingBitError(RemainingBitError<0) = 0;
                tic;
                if sum(unique(RemainingBitError) ~= 0)
                    SNRPoint = randp(RemainingBitError);    % Choose SNR point based on remaining errors required.
                    % Loop until either there are enough trials or enough errors or the time is up.
                    while ( ( obj.SimState.Trials( 1, SNRPoint) < obj.SimParam.MaxTrials(SNRPoint) ) && ...
                            ( obj.SimState.BitErrors(1, SNRPoint) < obj.SimParam.MaxBitErrors(SNRPoint) ) && ...
                            ( obj.SimState.SymbolErrors(1, SNRPoint) < obj.SimParam.MaxSymErrors(SNRPoint) ) )
                        % Increment the trials counter.
                        obj.SimState.Trials(1, SNRPoint) = obj.SimState.Trials(1, SNRPoint) + 1;
                        [NumBitError, NumSymbolError] = obj.Trial(obj.EsN0(SNRPoint));
                        obj.UpdateErrorRate(SNRPoint, NumBitError, NumSymbolError);

                        % Halt if BER and SER is low enough.
                        if ( (obj.SimState.BER(1, SNRPoint) < obj.SimParam.minBER) && (obj.SimState.SER(1, SNRPoint) < obj.SimParam.minSER) )
                            break;
                        end
                        % Determine if it is time to save and exit from while loop (once per CheckPeriod trials)
                        if ~rem(obj.SimState.Trials(1, SNRPoint), obj.SimParam.CheckPeriod)
                            break;
                        end
                    end
                    obj.Save();
                    ElapsedTime = toc + ElapsedTime;
                else
                    return;
                end
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