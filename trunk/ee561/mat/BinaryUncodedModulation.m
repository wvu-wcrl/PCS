classdef BinaryUncodedModulation < UncodedModulation
    
    methods( Access=protected )
        function CheckSymbols(obj, DataBits)
            if length(DataBits) ~= obj.DataLength
                % The length of DataBits has to be an integer multiple (BlockLength) of Mapper.NoBitsPerSymb.
                error('BinaryUncodedModulation:DataLength', 'Data length for this object should be %d (BlockLength=%d).', obj.DataLength, obj.BlockLength);
            elseif ( unique(DataBits) ~= [0 1] )
                error('BinaryUncodedModulation:DataBits', 'Input stream of data BITS should only contain bits 0 and 1.');
            end
            obj.DataBits = DataBits;
        end
        
        function GenSymbols(obj)
            % Generate binary symbols.
            obj.DataBits = (rand(1,obj.DataLength) > 0.5);
        end
        
        function DataSymbols = GenMarySymbols(obj, DataBits)
            obj.DataBits = cast(DataBits,'uint8');            % The type of DataBits should be 'uint8'.
            obj.DataSymbols = obj.Mapper.Map(obj.DataBits);   % The Map method of Mapping class maps obj.DataBits to a vector of M-ary symbols.
            DataSymbols = obj.DataSymbols;
        end
    end
    
    methods
        function obj = BinaryUncodedModulation(M, BlockLength)
            if ( nargin<1 || isempty(M) ), M = 2; end
            if ( nargin<2 || isempty(BlockLength) ), BlockLength = 1024; end
            obj@UncodedModulation(M, [], BlockLength);  % Default SymbolProb = [1 1].
        end
    end
    
end