classdef CodedModulation < handle
    
    properties
        ChannelCodeObject   % An object which performs the operations of Encoding and Decoding.
        Mapper              % An object which performs the operations of Mapping and Demapping. It has log2(obj.Order) as its input.
    end
    
    methods
        function [Codeword] = Encode(obj, DataBits)
%       This is the encode method.            
        end
        function [EstData] = Decode(obj, ReceivedLLR)
%       This is the decode method.            
        end
        function NumError = ErrorCount()
%       This is the methode responsible for counting the errors made between the input and ouput of the Encode and Decode methods, respectively.
        end
    end
    
end