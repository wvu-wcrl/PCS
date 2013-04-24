classdef UncodedModulation < CodedModulation
    
    properties
        BlockLength = 1024  % The number of SYMBOLS in each block.
        DataBits            % Data row vector as bits (The length of Data (DataLength) has to be an integer multiple (BlockLength) of NoBitsPerSymb).
        DataSymbols         % Symbol row vector as INT32 numbers between 1 and M (The length of DataSymbols has to be BlockLength).
        SymbolProb
        SymbolLikelihood
    end
    
    properties( SetAccess = protected )
        BitLikelihood       % 1 by N*LOG2(M) row vector of BITWISE likelihood.
        EstBits
        EstSymbols
        NumSymbolError
    end
    
    
    methods( Access=protected )
        function CheckSymbols(obj, DataSymbols)
            if rem( length(DataSymbols), obj.BlockLength ) ~= 0
                % The length of DataSymbols has to be an integer multiple of BlockLength.
                error('UncodedModulation:BlockLength', 'Length of the input symbol vector for this object should be an integer multiple of BlockLength=%d.', obj.BlockLength);
            elseif( sum( ismember( unique(DataSymbols), (1:length(obj.SymbolProb)) ) ) ~= length(unique(DataSymbols)) )
                error('UncodedModulation:DataSymbols', 'Input stream of data SYMBOLS should only contain integers between 1 and %d.', length(obj.SymbolProb));
            end
            obj.DataSymbols = DataSymbols;
        end
        
        function GenSymbols(obj)
            if obj.ZeroRandFlag==0      % DataSymbols is all zeros (SYMBOL 0 is 1 since symbols are between 1 and M).
                obj.DataSymbols = ones(1, obj.BlockLength);
            elseif obj.ZeroRandFlag==1  % DataSymbols is random.
                obj.DataSymbols = randp(obj.SymbolProb, 1, obj.BlockLength);
            end
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
        end
        
        function GenMarySymbols(obj, DataBits)
        end
    end
    
    
    methods
        
        function obj = UncodedModulation(M, DemodType, ZeroRandFlag, BlockLength, SymbolProb)
            if(nargin<1 || isempty(M)), M = 2; end
            if(nargin<2 || isempty(DemodType)), DemodType = 0; end % Default demapper with linear-log-MAP algorithm.
            if(nargin<3 || isempty(ZeroRandFlag)), ZeroRandFlag = 1; end % By default DataSymbols is generated randomly.
            if(nargin>=5 && ~isempty(SymbolProb))
                if length(SymbolProb) ~= M
                    error('UncodedModulation:SymbolProb', 'The length of SymbolProb should be equal to the number of symbols M=%d.', M);
                end
            else
                SymbolProb = (1/M)*ones(1,M);
            end
            ChannelCodeObject = [];
            obj@CodedModulation(ChannelCodeObject, M, DemodType, ZeroRandFlag);
            obj.SymbolProb = SymbolProb;
            if (nargin>=4 && ~isempty(BlockLength))
                obj.BlockLength = BlockLength;
            end
            obj.ChannelCodeObject.DataLength = obj.BlockLength * obj.Mapper.NoBitsPerSymb;
            obj.ChannelCodeObject.CodewordLength = obj.ChannelCodeObject.DataLength;
            obj.ChannelCodeObject.Rate = 1;
            obj.ChannelCodeObject.MaxIteration = 1;
        end
        
        
        function DataSymbolsOut = Encode(obj, DataSymbolsIn)
            % DataBitLength = obj.Mapper.NoBitsPerSymb * obj.BlockLength;
            obj.NumCodewords = 1;
            if( nargin>=2 && ~isempty(DataSymbolsIn) )
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
            obj.DataSymbols = cast( obj.DataSymbols, 'int32' ); % This is to make this class consistent with the CodedModulation class.
            DataSymbolsOut = obj.DataSymbols;
        end
        
        
        function [EstBits, NumBitError, NumSymbolError, EstSymbols] = Decode(obj, SymbolLikelihood)
            obj.SymbolLikelihood = SymbolLikelihood;
            obj.BitLikelihood = obj.Mapper.Demap( obj.SymbolLikelihood ); % Extrinsic information is considered to be all zero (DEFAULT).
            EstBits = obj.BitLikelihood>0;  % Hard decision on bits ( (sign(obj.BitLikelihood)+1)/2 )
            obj.EstBits = EstBits;
            EstSymbols = obj.DecBits2Symbols(EstBits);
            obj.EstSymbols = EstSymbols;
            [NumBitError, NumSymbolError] = FindNumErrors(obj);
        end
        
        
        function [NumBitError, NumSymbolError] = ErrorCount(obj, SymbolLikelihood)
            [EstBits, NumBitError, NumSymbolError, EstSymbols] = obj.Decode(SymbolLikelihood);
        end
        
        
        function [NumBitError, NumSymbolError] = FindNumErrors(obj)
            obj.NumBitError = sum( obj.EstBits ~= obj.DataBits );
            obj.NumSymbolError = sum( obj.EstSymbols ~= obj.DataSymbols );
            NumBitError = obj.NumBitError;
            NumSymbolError = obj.NumSymbolError;
        end
        
    end
    
end