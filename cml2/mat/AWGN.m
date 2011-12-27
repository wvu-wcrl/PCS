classdef AWGN < Channel
    
    properties
        DataIndex           % DataIndex row vector to be modulated.
        RecievedSignal      % K by N REAL matrix of received signal at the output of matched filter to be demodulated.
    end
    
    properties(SetAccess = protected)
        EsN0                % Ratio of Es/N0 for the realization of the channel (in Linear Units NOT dB).
        Variance            % Noise variance.
        ModulatedSignal     % K by N matrix containing modulated signal (K is the dimensionality of the signal space and N is the number of symbols.)
                            % Each symbol is composed of LOG2(Modulation.Order) bits.
        SymbolLikelihood    % Order by N real matrix of SYMBOL likelihoods (It specifies the likelihood of each of N received symbols to each of the Order
                            % possible points in the signal constellation.)
    end
    
    methods
        function obj = AWGN( ModulationObj, EsN0 )
            obj.ModulationObj = ModulationObj;
            obj.SetEsN0(EsN0);
        end
        
        
        function SetEsN0(obj, EsN0)
            if (EsN0<0)
                error('AWGN:EsN0NotLinear','EsN0 of the channel has to be specified in LINEAR units.');
            end
            obj.EsN0 = EsN0;
            % Determine the noise variance.
            obj.Variance = 1/(2*EsN0);
        end
        
        
        function SymbolLikelihood = ChannelUse(obj, SymbolIndex, EsN0)
            if(nargin>=3 && ~isempty(EsN0))
                obj.SetEsN0(EsN0);
            end
            ModulatedSignal = obj.Modulate(SymbolIndex);
            RecievedSignal = obj.PassToChannel(ModulatedSignal);
            SymbolLikelihood = obj.Demodulate(RecievedSignal);
        end
        
        
        function ModulatedSignal=Modulate(obj, DataIndex)
        % Modulate Method.
            obj.DataIndex = DataIndex;
            ModulatedSignal = obj.ModulationObj.SignalSet(:, DataIndex);
            obj.ModulatedSignal = ModulatedSignal;
        end
        
        
        function SymbolLikelihood = Demodulate( obj, RecievedSignal )
        % Demodulate Method: SymbolLikelihood = Demodulate( obj, RecievedSignal )
            obj.RecievedSignal = RecievedSignal;
            SymbolLikelihood = VectorDemod(obj.RecievedSignal, obj.ModulationObj.SignalSet, obj.EsN0);
            obj.SymbolLikelihood = SymbolLikelihood;
        end
        
        
        function RecievedSignal = PassToChannel(obj, ModulatedSignal)
            Noise = sqrt(obj.Variance) * randn(size(obj.ModulationObj.SignalSet,1) , size(ModulatedSignal,2));
            RecievedSignal = Noise + ModulatedSignal;
            obj.RecievedSignal = RecievedSignal;
        end
    end
    
end