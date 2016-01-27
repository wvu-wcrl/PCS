classdef TBConvCode < ConvCode
    
    methods
        function obj = TBConvCode(Generator, K, Depth)
        % Calling syntax: obj = TailConvCode(Generator, K [, Depth])
        
            DecoderType=-1; % optimum Soft-In/Hard-Out Viterbi decoding algorithm (DEFAULT)
            if( nargin<3 || isempty(Depth)), Depth = -1; end
            
            obj@ConvCode(Generator, K, 2, DecoderType, Depth);
        end
    end
end