classdef LDPCCode < ChannelCode
    
    properties
        HRows   % M-row matrix of column locations of non-zero entries in each row of the parity check matrix.
        HCols   % Matrix of row locations of non-zero entries in each column of the parity check matrix.
                % It has N-M rows for DVBS2 and N-M+z rows for LDPCWiMax.
        P       % (Optional) z-by-z matrix used to generate the first z check bits for WiMax LDPC codes.
                % Default = [].
        MaxIteration    % (Optional) Maximum number of message passing decoding iterations (Default MaxIteration=30).
        DecoderType     % (Optional) Message passing decoder type:
                        % =0 Sum-product decoding algorithm (DEFAULT).
                        % =1 Min-sum decoding algorithm.
                        % =2 Approximate min-sum decoding algorithm.
    end
    
    methods
        
        function obj = LDPCCode( HRows, HCols, P, MaxIteration, DecoderType )
        % Calling Syntax: obj = LDPCCode( HRows, HCols [,P] [,MaxIteration] [,DecoderType] )
            obj.HRows = HRows;
            obj.HCols = HCols;
            if ( nargin<3 || isempty(P) )
                P = [];
            end
            obj.P = P;
            if ( nargin<4 || isempty(MaxIteration) )
                MaxIteration = 30;
            end
            obj.MaxIteration = MaxIteration;
            if ( nargin<5 || isempty(DecoderType) )
                DecoderType = 0;
            elseif isempty( find(DecoderType==[0 1 2]) )
                error('LDPCCode:DecoderType', 'The optional input DecoderType should be either 0 (sum-product), 1 (min-sum), or 2 (approximate min-sum).');
            end
            obj.DecoderType = DecoderType;
        end
        
        function Codeword = Encode( obj, DataBits )
        % Encode method for eIRA LDPC codes.
            obj.DataBits = DataBits;
            obj.DataLength = length(obj.DataBits);
            
            Codeword = LdpcEncode(obj.DataBits, obj.HRows, obj.P);
            
            obj.Codeword=Codeword;
            obj.CodewordLength = length(obj.Codeword);
            obj.Rate = obj.DataLength/obj.CodewordLength;
        end
        
        function [EstBits, NumError] = Decode(obj, ReceivedLLR, DecoderType, MaxIteration)
        % Decoder method for message passing decoding for a block code.
        %
        % The syntax of calling this method is as follows: [EstBits, NumError] = Decode(obj, ReceivedLLR [,DecoderType] [,MaxIteration])
        % ReceivedLLR is the received vector of bit Log-Likelihood-Ratio (LLR) for the received data (Codeword) to be decoded.
        % NumError is a column vector showing the number of code bit errors after each iteration of decoding.
            obj.ReceivedLLR = ReceivedLLR;
            if ( nargin>2 && ~isempty(DecoderType) )
                obj.DecoderType = DecoderType;
            end
            if ( nargin>3 && ~isempty(MaxIteration) )
                obj.MaxIteration = MaxIteration;
            end
            [EstBitsHat NumError] = MpDecode( -obj.ReceivedLLR, obj.HRows, obj.HCols, obj.MaxIteration, obj.DecoderType, 1, 1, obj.DataBits );
            % EstBitsHat is MaxIteration-by-N matrix of decoded code bits for each iteration of decoding.
            EstBits = EstBitsHat(obj.MaxIteration,:);
            obj.EstBits = EstBits;
            obj.NumError = NumError;
        end
    end
    
end