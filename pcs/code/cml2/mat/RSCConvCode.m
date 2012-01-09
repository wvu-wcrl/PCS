classdef RSCConvCode < ConvCode
    
    methods
        function obj = RSCConvCode(Generator, K, DecoderType)
        % Calling syntax: obj = RSCConvCode(Generator K, [, DecoderType])
            if( nargin<3 || isempty(DecoderType)), DecoderType = -1; end % optimum Soft-In/Hard-Out Viterbi decoding algorithm (DEFAULT)
            
            obj@ConvCode(Generator, K, 0, DecoderType);
        end
    end
end