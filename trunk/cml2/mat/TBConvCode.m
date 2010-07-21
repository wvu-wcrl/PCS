classdef TBConvCode < ConvCode
    
    properties
    end
    
    methods
        % The syntax of calling the construcot of this class is as follows: obj = TailConvCode(Generator [, Depth])
        function obj = TailConvCode(Generator, varargin)
            DecoderType=-1;         % optimum Soft-In/Hard-Out Viterbi decoding algorithm (DEFAULT)
            Depth=-1;
            if(length(varargin) >= 1)
               Depth=varargin{1};
            end
            
            obj@ConvCode(Generator, 2, DecoderType, Depth);
        end
    end
end