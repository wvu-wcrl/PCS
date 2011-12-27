classdef LDPC_DVBS2 < LDPCCode
    
    methods
        function obj = LDPC_DVBS2(EffectiveRate, FrameSize, MaxIteration, DecoderType)
        % Calling Syntax: obj = LDPC_DVBS2([EffectiveRate] [,FrameSize] [,MaxIteration] [,DecoderType])
        %
        % EffectiveRate is the effective rate of the concatenated BCH/LDPC code components in DVBS2 standard (Default = 1/2).
        % For NORMAL frames: EffectiveRate = 1/4, 1/3, 2/5, 1/2, 3/5, 2/3, 3/4, 4/5, 5/6, 8/9, 9/10.
        % For SHORT frames: EffectiveRate = 1/4, 1/3, 2/5, 1/2, 3/5, 2/3, 3/4, 4/5, 5/6, 8/9.
        % FrameSize=64800 (NORMAL frames) (Default) or 16200 (SHORT frames).
        % MaxIteration: Maximum number of message passing decoding iterations (Default MaxIteration=30).
        % DecoderType: Message passing decoder type:
        %              0 Sum-product decoding algorithm (DEFAULT).
        %              1 Min-sum decoding algorithm.
        %              2 Approximate min-sum decoding algorithm.
            if( nargin<1 || isempty(EffectiveRate) ), EffectiveRate = 1/2; end
            if( nargin<2 || isempty(FrameSize) ), FrameSize = 64800; end
            if( nargin<3 || isempty(MaxIteration) ), MaxIteration = 30; end
            if( nargin<4 || isempty(DecoderType) ), DecoderType = 0; end
            
            [HRows, HCols] = InitializeDVBS2(EffectiveRate, FrameSize);
            obj@LDPCCode( HRows, [], MaxIteration, DecoderType );
        end
    end
    
end