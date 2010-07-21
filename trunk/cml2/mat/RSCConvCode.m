classdef RSCConvCode < ConvCode
    
    properties
    end
    
    methods
        % The syntax of calling the construcot of this class is as follows: obj = RSCConvCode(Generator [, DecoderType])
        function obj = RSCConvCode(Generator, varargin)
            
            DecoderType=-1;         % optimum Soft-In/Hard-Out Viterbi decoding algorithm (DEFAULT)
            if(length(varargin) >= 1)
                DecoderType=varargin{1};
            end
            
            obj@ConvCode(Generator, 0, DecoderType);
        end
    end
end

