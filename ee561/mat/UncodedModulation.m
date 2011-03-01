classdef UncodedModulation < CodedModulation
    
    properties
        BlockLength = 1024
        DataLength
        DataBits            % Data row vector as UINT8 to be mapped to an M-ary symbol (The length of Data (DataLength) has to be an integer multiple (BlockLength) of NoBitsPerSymb.)
        DataIndex
        SymbolLikelihood
        BitLikelihood       % 1 by N*LOG2(Order) row vector of BITWISE likelihood.
        EstBits
    end
    
    methods
        
        function obj = UncodedModulation(M, BlockLength)
            obj.Mapper = Mapping( log2(M) );    % log2(obj.Order) is the number of bits per symbol.
            obj.ChannelCodeObject = 'UnCoded';
            if ( nargin>=2 && ~isempty(BlockLength) )
                obj.BlockLength = BlockLength;
            end
            obj.DataLength = obj.Mapper.NoBitsPerSymb*obj.BlockLength;
        end
        
        
        function DataIndex = Encode(obj, DataBits)
            if ( nargin>=2 && ~isempty(DataBits) )
                if length(DataBits) ~= obj.DataLength
                % The length of DataBits has to be an integer multiple (BlockLength) of Mapper.NoBitsPerSymb.
                    error('UncodedModulation:DataLength', 'Data length for this object should be %d (BlockLength=%d).', obj.DataLength, obj.BlockLength);
                end
                obj.DataBits = DataBits;
            else
                obj.DataBits = (rand(1,obj.DataLength) > 0.5);
            end
            obj.DataBits = cast(obj.DataBits,'uint8');      % The type of DataBits should be 'uint8'.
            obj.DataIndex = obj.Mapper.Map(obj.DataBits);   % The Map method of Mapping class maps obj.DataBits to a vector of M-ary symbols.
            DataIndex = obj.DataIndex;
        end
        
        
        function EstBits = Decode(obj, SymbolLikelihood, DemodType)
            obj.SymbolLikelihood = SymbolLikelihood;
%             if obj.Mapper.NoBitsPerSymb==1
%                 BitLikelihood=obj.SymbolLikelihood;
%             else
                if ( nargin>=3 && ~isempty(DemodType) )
                    obj.Mapper.DemodType = DemodType;
                end
                BitLikelihood = obj.Mapper.Demap( obj.SymbolLikelihood ); % Extrinsic information is considered to be all zero (DEFAULT).
%             end
            obj.BitLikelihood = BitLikelihood;
            EstBits = obj.BitLikelihood>0.5;
            obj.EstBits = EstBits;
        end
        
        
        function NumError = ErrorCount(obj, SymbolLikelihood, DemodType)
            if (nargin<3 || isempty(DemodType)), DemodType=0; end % Default demapper with linear-log-MAP algorithm.
            Decode(obj, SymbolLikelihood, DemodType);
            NumError = sum( obj.EstBits ~= obj.DataBits );
        end
        
    end
    
end