classdef Modulation < handle
% Last Modulation class updated on July 15, 2010.
    
    properties
        Type        % Modulation Type (as a STRING) (ALL case-INsensitive)
                    % 'BPSK', 'QPSK', 'APSK'(Order=16,32), 'HEX'(Order=16), 'HSDPA' (Order=4,16) or 'custom'
                    % 'FSK'(MappingType='gray','reversegray'(Order=8,16),'mv'(Order=8,16),'dt'(Order=8,16), For ALL {'gray2','gray3','gray4','gray5','gray6'} Order is 8)
                    % 'PSK' (MappingType='gray','SP'(Order=4,8),'SSP'(Order=8),'MSEW'(Order=8))
                    % 'QAM'(MappingType='gray'(Order=16,64,256), For ALL{'Antigray','SP','MSP','MSEW','huangITNr1','huangITNr2','huangLetterNr1','huangLetterNr2'} Order is 16,Order=32(Fixed Mapping))
        Order       % Modulation Order which is the number of points (symbols) in the signal constellation (It has to be a power of 2.)
                    % It is not needed for 'BPSK' (Order=2), 'QPSK' (Order=4), or 'HEX' (Order=16). Default for 'FSK' is Order=2.
%         MappingType='gray'  
        MappingType         % Mapping type (as a STRING OR VECTOR of integers 0 through Order-1 exactly once)
                            % 'gray' (DEFAULT), 'Antigray', 'quasigray', 'SP', 'SSP', 'MSEW', 'huangITNr1', 'huangITNr2', 'huangLetterNr1', 'huangLetterNr2', 'mv', 'dt'.
                            % It is not needed for 'BPSK', 'QPSK', 'HSDPA', 'HEX', 'APSK', or orthogonal 'FSK' (h=1).
                            % For 'custom' modulation type, MappingType has to be a valid VECTOR.
        MappingVector       % Mapping vector (ith element of this vector is the set of bits associated with the ith symbol.)
                
        SignalSet   % K by Order REAL Signal Constellation (K is the dimensionality of the signal space. There are Order points in the signal space.)
        
        Data        % Data row vector to be modulated (The length of Data has to be an integer multiple (N) of LOG2(Order).)
        
        ModulatedSignal     % K by N matrix containing modulated signal (K is the dimensionality of the signal space and N is the number of
                            % symbols. Each symbol is composed of LOG2(Order) bits.)
                            
        RecievedSignal      % K by N REAL matrix of received signal at the output of matched filter to be demodulated
        SymbolLikelihood    % Order by N real matrix of SYMBOL likelihoods (It specifies the likelihood of each of N received symbols to each of the Order
                            % possible points in the signal constellation.)
        BitLikelihood       % 1 by N*LOG2(Order) row vector of BITWISE likelihood
        
        EsN0=-1             % Ratio of Es/N0 for the realization of the channel (in Linear Units NOT dB)
        
        FadingCoef='UnDef'  % 1 by N roe vector of (complex) fading coefficients of the channel (DEFAULT =1 (AWGN Channel))
        
        DemodType=0         % Demodulater type indicating how the max_star function is implemented within the demodulator
                            % =0 For linear-log-MAP algorithm (Correction function is a straght line.) (DEFAULT)
                            % =1 For max-log-MAP algorithm FASTEST (max*(x,y) = max(x,y) and correction function = 0)
                            % =2 For Constant-log-MAP algorithm (Correction function is a constant.)
                            % =3 For log-MAP (Correction factor from small nonuniform table and interpolation.)
                            % =4 For log-MAP (Correction factor uses C function calls.)
        Mapper              % An object which performs the operations of Mapping and Demapping. It has log2(obj.Order) as its input.
    end
    
    methods
        
%         % Class constructor: obj = Modulation(Type [,Order] [,MappingType] [,Mapper] [SignalSet in 'custom' modulation])
%         function obj = Modulation(Type, varargin)
        

        % Class constructor: obj = Modulation(SignalSet, [,Mapper])
        function obj = Modulation(SignalSet, varargin)
            obj.SignalSet = SignalSet;
            obj.Order = size(SignalSet, 2);
%             obj.Type=Type;
            
%             if ( strcmpi(obj.Type, 'BPSK') )
%                 obj.Order=2;
%             elseif ( strcmpi(obj.Type, 'QPSK') )
%                 obj.Order=4;
%             elseif ( strcmpi(obj.Type, 'HEX') )
%                 obj.Order=16;
%             else
%                 if (length(varargin)>=1)
%                     obj.Order = varargin{1};
%                     % Making sure that modulation Order is a power of 2.
%                     if ( rem( log(obj.Order)/log(2),1 ) )
%                         error('The order of modulation MUST be a power of 2.');
%                     end
%                 elseif ( strcmpi(obj.Type, 'APSK') || strcmpi(obj.Type, 'QAM') )
%                     obj.Order=16;
%                 elseif ( strcmpi(obj.Type, 'HSDPA') )
%                     obj.Order=4;
%                 elseif ( strcmpi(obj.Type, 'PSK') )
%                     obj.Order=8;
%                 end
%             end
            
%             if (length(varargin)>=2)
%                 obj.MappingType = varargin{2};
%                 if ~ischar(obj.MappingType)
%                     if (length(obj.MappingType) ~= obj.Order)
%                         error('Length of MappingType must be EQUALL to the Order of modulation.');
%                     elseif (sum( sort(obj.MappingType) ~= [0:obj.Order-1] ) > 0)
%                         error( 'MappingType must contain integers 0 through Order-1.' );
%                     end
%                 end
%             end
            
%             if (length(varargin)>=3)
%                 obj.Mapper = varargin{3};
%                 if obj.Mapper.NoBitsPerSymb ~= log2(obj.Order)
%                     error('The number of bits per symol in the Mapper object must be EQUALL to the LOG2 of the Order of modulation.');
%                 end
%             else
%                 obj.Mapper = Mapping( log2(obj.Order) );    % log2(obj.Order) is the number of bits per symbol.
%             end
            
            if (length(varargin)>=1)
                obj.Mapper = varargin{1};
                if obj.Mapper.NoBitsPerSymb ~= log2(obj.Order)
                    error('The number of bits per symol in the Mapper object must be EQUALL to the LOG2 of the Order of modulation.');
                end
            else
                obj.Mapper = Mapping( log2(obj.Order) );    % log2(obj.Order) is the number of bits per symbol.
            end
            
%             if ( strcmpi(obj.Type, 'custom') ) % Custom modulation
%                 if (length(varargin)>=4)
%                     obj.SignalSet = varargin{4};
%                     obj.Order = size(obj.SignalSet,2);
%                     obj.MappingVector = varargin{2};
%                     if ischar(obj.MappingVector)
%                         error('The second input argument for the CUSTOM modulation should be Mapping Vector as a vector of length Modulation_Order.');
%                     elseif (length(obj.MappingVector) ~= obj.Order)
%                         error('Length of MappingVector must be EQUALL to the Order of modulation.');
%                     elseif (sum( sort(obj.MappingVector) ~= [0:obj.Order-1] ) > 0)
%                         error( 'MappingVector must contain integers 0 through Order-1.' );
%                     end
%                 else
%                     error('Custom Signal Constellation has to specified as the third input argument.');
%                 end
%             elseif ( ~strcmpi(obj.Type, 'FSK') )
                % Creating a K-dimensional signal constellation with obj.Order points (K is dimensionality and obj.Order is the number of symbols).
% OLD VERSION                 [obj.SignalSet, obj.MappingVector] = CreateConstellation(obj.Type, obj.Order, obj.MappingType);
%                 [Constellation, obj.MappingVector] = CreateConstellation(obj.Type, obj.Order, obj.MappingType);
%                 obj.SignalSet=[real(Constellation); imag(Constellation)];
%             end
            
%             obj.Mapper = Mapping( log2(obj.Order) );    % log2(obj.Order) is the number of bits per symbol.
        end
        
        
        % Modulate Method
        function ModulatedSignal=Modulate(obj, Data)
            obj.Data=Data;
            % The length of Data has to be an integer multiple of LOG2(obj.Order) and its type has to be 'uint8'.
            if rem( length(obj.Data), log2(obj.Order) )
                error('The length of Data to be modulated has to be an integer multiple of LOG2(Modulation_Order).');
            end
% OLD VERSION            ModulatedSignal = Modulate( obj.Data, obj.SignalSet );
            % The Map function maps obj.Data to a vector of M-ary symbols.
% OLD VERSION            ModulatedSignalIndex = Map( obj.Data, log2(obj.Order) ); % log2(obj.Order) is the number of bits per symbol.
            ModulatedSignalIndex = obj.Mapper.Map( obj.Data );     % The Map method od Mapping class maps obj.Data to a vector of M-ary symbols.
            ModulatedSignal=obj.SignalSet(:, ModulatedSignalIndex);
            obj.ModulatedSignal=ModulatedSignal;
        end
        
        
        % Demodulate Method: BitLikelihood=Demodulate(RecievedSignal [,EsN0], [,FadingCoef] [,DemodType])
        function BitLikelihood=Demodulate(obj, RecievedSignal, varargin)
            obj.RecievedSignal=RecievedSignal;
            if (length(varargin)>=1)
                    obj.EsN0 = varargin{1};
                    if (length(varargin)>=2)
                        obj.FadingCoef=varargin{2};
                    elseif (strcmpi(obj.FadingCoef, 'UnDef'))
                        obj.FadingCoef=ones(1,length(obj.RecievedSignal)); % Fading Coefficients for AWGN Channel
                    end
            elseif (obj.EsN0<0)
                error('In order to demodulate RecievedSignal, EsN0 of the channel has to be specified.');
            elseif (strcmpi(obj.FadingCoef, 'UnDef'))
                obj.FadingCoef=ones(1,length(obj.RecievedSignal)); % Fading Coefficients for AWGN Channel
            end
            
            if (length(varargin)>=3)
                obj.DemodType = varargin{3};
            end
                        
% OLD VERSION            obj.SymbolLikelihood = Demod2D(obj.RecievedSignal, obj.SignalSet, obj.EsN0, obj.FadingCoef);
            obj.SymbolLikelihood = VectorDemod(obj.RecievedSignal, obj.SignalSet, obj.EsN0);
            
            % The following if statement was commented on July 16, 2009.
%             if ( strcmpi(obj.Type, 'BPSK') )
%                 BitLikelihood = obj.SymbolLikelihood;
%             else
% OLDER VERSION                BitLikelihood = Somap(obj.SymbolLikelihood, obj.DemodType); % Extrinsic information is considered to be all zero (DEFAULT).
% OLD VERSION                BitLikelihood = Demap(obj.SymbolLikelihood, obj.DemodType); % Extrinsic information is considered to be all zero (DEFAULT).
                BitLikelihood = obj.Mapper.Demap( obj.SymbolLikelihood, obj.DemodType ); % Extrinsic information is considered to be all zero (DEFAULT).
%             end
            obj.BitLikelihood=BitLikelihood;
        end
    end    
end