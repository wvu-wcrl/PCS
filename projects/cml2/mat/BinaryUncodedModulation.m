classdef BinaryUncodedModulation < UncodedModulation
    
    methods( Access=protected )
        function CheckSymbols(obj, DataBits)
            if rem( length(DataBits), obj.ChannelCodeObject.DataLength ) ~= 0
                % The length of DataBits has to be an integer multiple (BlockLength) of Mapper.NoBitsPerSymb.
                error('BinaryUncodedModulation:DataLength', 'Length of the input DataBits vector for this object should be %d (BlockLength=%d).',...
                    obj.ChannelCodeObject.DataLength, obj.BlockLength);
            elseif( sum( ismember( unique(DataBits), [0 1] ) ) ~= length(unique(DataBits)) )
                error('BinaryUncodedModulation:DataBits', 'Input stream of data BITS should only contain bits 0 and 1.');
            end
            obj.DataBits = DataBits;
        end
        
        function GenSymbols(obj)
            % Generate binary symbols.
            if obj.ZeroRandFlag==0      % DataSymbols is all zeros (SYMBOL 0 is 1 since symbols are between 1 and M).
                obj.DataBits = zeros(1, obj.ChannelCodeObject.DataLength*obj.BlockLength);
            elseif obj.ZeroRandFlag==1  % DataSymbols is random.
                obj.DataBits = (rand(1,obj.ChannelCodeObject.DataLength*obj.BlockLength) > 0.5);
            end
        end
        
        function DataSymbols = GenMarySymbols(obj, DataBits)
       obj.DataBits = cast(DataBits,'uint8');  % The type of DataBits should be 'uint8'.
%         obj.DataBits=DataBits;
            obj.DataSymbols = obj.Mapper.Map(obj.DataBits);   % The Map method of Mapping class maps obj.DataBits to a vector of M-ary symbols.
            DataSymbols = obj.DataSymbols;
        end
    end
    
    methods
        function obj = BinaryUncodedModulation(M, DemodType, ZeroRandFlag, BlockLength)
            if(nargin<1 || isempty(M)), M = 2; end
            if(nargin<2 || isempty(DemodType)), DemodType = 0; end % Default demapper with linear-log-MAP algorithm.
            if(nargin<3 || isempty(ZeroRandFlag)), ZeroRandFlag = 1; end % By default DataBits is generated randomly.
            if(nargin<4 || isempty(BlockLength)), BlockLength = 1024; end
            obj@UncodedModulation(M, DemodType, ZeroRandFlag, BlockLength, []);
        end
    end
    
end