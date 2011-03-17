classdef UncodedModulation < CodedModulation
    
    properties
        BlockLength = 1024  % The number of SYMBOLS in each block.
        DataBits            % Data row vector as bits (The length of Data (DataLength) has to be an integer multiple (BlockLength) of NoBitsPerSymb).
        DataSymbols         % Symbol row vector as numbers between 1 and M (The length of DataSymbols has to be BlockLength).
        SymbolProb = [1 1]
        SymbolLikelihood
    end
    
    properties( SetAccess = protected )
        DataLength
        BitLikelihood       % 1 by N*LOG2(M) row vector of BITWISE likelihood.
        EstBits
        EstSymbols
    end
    
    
    methods( Access=protected )
        function CheckSymbols(obj, DataSymbols)
            if length(DataSymbols) ~= obj.BlockLength
                % The length of DataSymbols has to be BlockLength.
                error('UncodedModulation:BlockLength', 'Length of the input symbol vector for this object should be BlockLength=%d.', obj.BlockLength);
            elseif ( unique(DataSymbols) ~= ( 1:length(obj.SymbolProb) ) )
                error('UncodedModulation:DataSymbols', 'Input stream of data SYMBOLS should only contain integers between 1 and %d.', length(obj.SymbolProb));
            end
            obj.DataSymbols = DataSymbols;
        end
        
        function GenSymbols(obj)
            obj.DataSymbols = randp(obj.SymbolProb, 1, obj.BlockLength);
        end
        
        function DataBits = GenBits(obj, DataSymbols)
            DataBitsT = de2bi(DataSymbols, obj.Mapper.NoBitsPerSymb, [], 'left-msb');
            % Each decimal symbol in DataSymbols (between 0 and M-1) is converted to binary and saved in one of the rows of the DataBitsT.
            DataBits = reshape(DataBitsT',1,[]);
            obj.DataBits = DataBits;
        end
        
        function EstSymbols = DecBits2Symbols(obj, EstBits)
            EstMatrix = reshape(EstBits,obj.Mapper.NoBitsPerSymb,[]); % Each column is binary representation of one symbol.
            EstSymbols = bi2de(EstMatrix','left-msb')+1;    % Column vector of estimated symbols.
            EstSymbols = EstSymbols';
            obj.EstSymbols = EstSymbols;
        end
        
        function GenMarySymbols(obj)
        end
    end
    
    
    methods
        function obj = UncodedModulation(M, SymbolProb, BlockLength)
            obj.Mapper = Mapping( log2(M) );    % log2(M) is the number of bits per symbol.
            obj.ChannelCodeObject = 'UnCoded';
            if ( nargin>=2 && ~isempty(SymbolProb) )
                if length(SymbolProb) ~= M
                    error('UncodedModulation:SymbolProb', 'The length of SymbolProb should be equal to M=%d.', M);
                end
                obj.SymbolProb = SymbolProb;
            elseif M~=2
                obj.SymbolProb = (1/M)*ones(1,M);
            end
            if ( nargin>=3 && ~isempty(BlockLength) )
                obj.BlockLength = BlockLength;
            end
            obj.DataLength = obj.Mapper.NoBitsPerSymb * obj.BlockLength;
        end
        
        
        function DataSymbolsOut = Encode(obj, DataSymbolsIn)
            if ( nargin>=2 && ~isempty(DataSymbolsIn) )
                obj.CheckSymbols(DataSymbolsIn);
            else
                obj.GenSymbols();
            end
            if ~isempty(obj.DataSymbols)
                obj.GenBits(obj.DataSymbols-1);
            elseif ~isempty(obj.DataBits)
                obj.GenMarySymbols(obj.DataBits);
            else
                error('UncodedModulation:EmptySymBit', 'Both DataSymbols and DataBits are empty.');
            end
            DataSymbolsOut = obj.DataSymbols;
        end
        
        
        function [EstBits, EstSymbols] = Decode(obj, SymbolLikelihood, DemodType)
            obj.SymbolLikelihood = SymbolLikelihood;
            if ( nargin>=3 && ~isempty(DemodType) )
                obj.Mapper.DemodType = DemodType;
            end
            BitLikelihood = obj.Mapper.Demap( obj.SymbolLikelihood ); % Extrinsic information is considered to be all zero (DEFAULT).
            obj.BitLikelihood = BitLikelihood;
            EstBits = obj.BitLikelihood>0;  % Hard decision on bits ( (sign(obj.BitLikelihood)+1)/2 )
            obj.EstBits = EstBits;
            EstSymbols = DecBits2Symbols(obj, EstBits);
        end
        
        
        function [NumBitError, NumSymbolError] = ErrorCount(obj, SymbolLikelihood, DemodType)
            if (nargin<3 || isempty(DemodType)), DemodType=0; end % Default demapper with linear-log-MAP algorithm.
            [EstBits, EstSymbols] = Decode(obj, SymbolLikelihood, DemodType);
            NumBitError = sum( EstBits ~= obj.DataBits );
            NumSymbolError = sum( EstSymbols ~= obj.DataSymbols );
        end
        
    end
    
end