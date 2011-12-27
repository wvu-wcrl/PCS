classdef NSCConvCode < ConvCode
    
    methods
        function obj = NSCConvCode(Generator, K, DecoderType)
        % Calling syntax: obj = NSCConvCode(Generator, K [, DecoderType])
            if( nargin<3 || isempty(DecoderType)), DecoderType = -1; end % optimum Soft-In/Hard-Out Viterbi decoding algorithm (DEFAULT)
            
            obj@ConvCode(Generator, K, 1, DecoderType);
        end
    end
end