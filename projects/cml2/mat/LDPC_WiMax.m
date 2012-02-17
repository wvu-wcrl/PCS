classdef LDPC_WiMax < LDPCCode
    
    methods
        function obj = LDPC_WiMax(Rate, FrameSize, Index, MaxIteration, DecoderType)
        % Calling Syntax: obj = LDPC_WiMax([Rate] [,FrameSize] [,Index] [,MaxIteration] [,DecoderType])
        %
        % Rate is the effective rate of the LDPC code in WiMax standard (DEFAULT = 1/2).
        % For WiMax LDPC code Rate = 1/2, 2/3, 3/4, 5/6.
        % FrameSize = 576:96:2304 (DEFAULT = 576).
        % Index: Selects either code ’A’ or code ’B’ for rates 2/3 and 3/4 of WiMax LDPC codes.
        %        0 Code rate type ’A’ (DEFAULT).
        %        1 Code rate type ’B’.
        %        [empty array] All other code rates.
        % MaxIteration: Maximum number of message passing decoding iterations (Default MaxIteration=30).
        % DecoderType: Message passing decoder type:
        %              0 Sum-product decoding algorithm (DEFAULT).
        %              1 Min-sum decoding algorithm.
        %              2 Approximate min-sum decoding algorithm.
        
            if( nargin<1 || isempty(Rate) ), Rate = 1/2; end
            if( nargin<2 || isempty(FrameSize) ), FrameSize = 576; end
            if( nargin<3 || isempty(Index) ), Index = 0; end
            if( nargin<4 || isempty(MaxIteration) ), MaxIteration = 30; end
            if( nargin<5 || isempty(DecoderType) ), DecoderType = 0; end
            
            [HRows, HCols, P] = InitializeWiMaxLDPC( Rate, FrameSize, Index );
            obj@LDPCCode( HRows, HCols, P, MaxIteration, DecoderType );
        end
    end
    
end