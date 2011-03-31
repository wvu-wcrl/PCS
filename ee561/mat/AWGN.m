classdef AWGN < Channel
    
    properties
        DataIndex           % DataIndex row vector to be modulated.
        
        ModulatedSignal     % K by N matrix containing modulated signal (K is the dimensionality of the signal space and N is the number of symbols.)
                            % Each symbol is composed of LOG2(Modulation.Order) bits.
        RecievedSignal      % K by N REAL matrix of received signal at the output of matched filter to be demodulated.
        SymbolLikelihood    % Order by N real matrix of SYMBOL likelihoods (It specifies the likelihood of each of N received symbols to each of the Order
                            % possible points in the signal constellation.)
        
        EsN0                % Ratio of Es/N0 for the realization of the channel (in Linear Units NOT dB).
        Variance            % Noise variance.
        UpperSymbolBoundValue % Value of union bound on average symbol error probability.
        UpperBitBoundValue  % Value of union bound on average bit error probability.
    end
    
    
    methods( Static )
        function UpperSymbolBoundValue = UnionBoundSymbol( SignalSet, EsN0, SignalProb )
            % EsN0 is in linear (Es = 1).
            if (nargin<3), SignalProb = []; end
            Distance = AWGN.GetSignalDistance(SignalSet);
            QValues = AWGN.ClculateQValues( Distance, EsN0 );
            
            % Calculate conditional symbol error bound.
            CondSymbolErrorBound = sum(QValues);
            UpperSymbolBoundValue = AWGN.GetUnionBoundSymbol(CondSymbolErrorBound, SignalProb);
        end
        
        function UpperBitBoundValue = UnionBoundBit( SignalSet, EsN0, SignalProb )
            % EsN0 is in linear (Es = 1).
            Distance = AWGN.GetSignalDistance(SignalSet);
            HammingDistance = AWGN.SymbolHammingDis(size(SignalSet,2));
            CondBitErrorBound = AWGN.CondUnionBoundBit( Distance, EsN0, HammingDistance );
            % Calculate the union bound on average bit error probability.
            if (nargin<3 || isempty(SignalProb))
                NoSignals = size( SignalSet, 2);    % Determine the number of signals.
                UpperBitBoundValue = sum(CondBitErrorBound) / NoSignals;
            else
                UpperBitBoundValue = sum( CondBitErrorBound .* (SignalProb/sum(SignalProb)) );
            end
        end
        
        function Distance = GetSignalDistance(SignalSet)
            NoSignals = size( SignalSet, 2);    % Determine the number of signals.
            Distance = zeros(NoSignals);
            % Calculate the distance between each signal and the rest of the signals.
            % Upper triangular part of Distance has the distances of signals with each other. It is a symmetric matrix.
            for m = 1:NoSignals-1
                SignalDifference = repmat(SignalSet(:,m), [1 NoSignals-m]) - SignalSet(:, m+1:end);
                Distance(m, m+1:end) = sqrt( sum( abs(SignalDifference).^2 ) );     % Sum over columns of matrix.
            end
        end
        
        function QValues = ClculateQValues( Distance, EsN0 )
            % Calculate Q function for upper triangular part.
            QValuesT = 0.5 * (1 - erf( sqrt(EsN0)*Distance / 2 ));
            
            % Use the symmetry to get the Q function valued for upper triangular part.
            QValuesUp = triu(QValuesT, 1);
            QValues = QValuesUp.' + QValuesUp;
        end
        
        function UpperSymbolBoundValue = GetUnionBoundSymbol(CondSymbolErrorBound, SignalProb)
            % Calculate the union bound on average symbol error probability.
            if (nargin<2 || isempty(SignalProb))
                NoSignals = length( CondSymbolErrorBound );    % Determine the number of signals.
                UpperSymbolBoundValue = sum(CondSymbolErrorBound) / NoSignals;
            else
                UpperSymbolBoundValue = sum( CondSymbolErrorBound .* (SignalProb/sum(SignalProb)) );
            end
        end
        
        function CondBitErrorBound = CondUnionBoundBit( Distance, EsN0, HammingDistance )
            if( nargin<3 || isempty(HammingDistance) )
                % Find the Hamming distance between symbols.
                HammingDistance = AWGN.SymbolHammingDis(size(Distance,2));
            end
            QValues = AWGN.ClculateQValues( Distance, EsN0 );
            
            % Calculate conditional symbol error bound.
            CondBitErrorBound = sum(HammingDistance .* QValues) / log2(size(Distance,2));
        end
        
        function HammingDistance = SymbolHammingDis(Syms)
        % HammingDistance calculates the Hamming distance between the elements of a vector of symbols.
        % Calling Syntax: HammingDistance = SymbolHammingDis(Syms)
        % Syms can be a vector of symbols or the number of symbols in which symbols 0:Syms-1 are considers.
            if isscalar(Syms)
                Symbols = 0:Syms-1;
                NoBits = ceil( log2(Syms) );    % The number of required bits to represent all Sybmols.
            else
                Symbols = Syms;
                NoBits = ceil( log2(max(Symbols)) );    % The number of required bits to represent all Sybmols.
            end
            M = length(Symbols);    % The number of symbols.
            
            HammingDistanceT = zeros(M);
            % Calculate the Hamming distance between each symbol and the rest of the symbols.
            % Lower triangular part of HammingDistance is filled with the Hamming distances of symbols with each other. It is a symmetric matrix.
            for k=1:M-1
                % Represent current symbol in binary format.
                CurrentSym = de2bi( Symbols(k), NoBits, [], 'left-msb' );
                % Represnt other symbols in binary format in each row of OtherSym.
                OtherSym = de2bi( Symbols(k+1:end), NoBits, [], 'left-msb' );
                BitDifference =  repmat(CurrentSym, [M-k 1]) ~= OtherSym;
                HammingDistanceT(k+1:end, k) = sum( BitDifference, 2 );
            end
            DL = tril(HammingDistanceT, -1);
            HammingDistance = DL + DL.';
        end
    end
    
    
    methods
        function obj = AWGN( ModulationObj, EsN0 )
            obj.ModulationObj = ModulationObj;
            obj.EsN0 = EsN0;
            % Determine the noise variance.
            obj.Variance = 1/(2*EsN0);
            obj.UpperSymbolBoundValue = AWGN.UnionBoundSymbol( ModulationObj.SignalSet, EsN0, ModulationObj.SignalProb );
            obj.UpperBitBoundValue = AWGN.UnionBoundBit( ModulationObj.SignalSet, EsN0, ModulationObj.SignalProb );
        end
        
        
        function SymbolLikelihood = ChannelUse(obj, SymbolIndex, EsN0)
            if (nargin>=3 && ~isempty(EsN0))
                if (obj.EsN0<0)
                    error('In order to demodulate RecievedSignal, EsN0 of the channel has to be specified in LINEAR units.');
                end
                obj.EsN0 = EsN0;
                obj.Variance = 1/(2*EsN0);
            end
            ModulatedSignal=Modulate(obj, SymbolIndex);
            RecievedSignal = PassToChannel(obj, ModulatedSignal);
            SymbolLikelihood = Demodulate( obj, RecievedSignal );
        end
        
        
        function ModulatedSignal=Modulate(obj, DataIndex)
        % Modulate Method.
            obj.DataIndex = DataIndex;
            ModulatedSignal=obj.ModulationObj.SignalSet(:, DataIndex);
            obj.ModulatedSignal=ModulatedSignal;
        end
        
        
        function SymbolLikelihood = Demodulate( obj, RecievedSignal, EsN0 )
        % Demodulate Method: SymbolLikelihood = Demodulate( RecievedSignal [,EsN0] )
            obj.RecievedSignal=RecievedSignal;
            if (nargin>=3 && ~isempty(EsN0))
                if (obj.EsN0<0)
                    error('In order to demodulate RecievedSignal, EsN0 of the channel has to be specified in LINEAR units.');
                end
                obj.EsN0 = EsN0;
                obj.Variance = 1/(2*EsN0);
            end
            
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
    