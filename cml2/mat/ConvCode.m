%% Convolutional Code Class
% This class generates a convolution code object and performs the encoding
% and decoding operations using the generated convolutional code. Moreover, since it
% inheretes from the superclass ChannelCode, it can calculate the number of
% errors in any encoding/decoding operation. For more information on the
% _convolutiona codes_ and their unique characteristics, the reader can
% refere to <http://en.wikipedia.org/wiki/Convolutional_code [1]>.
% 
% In order to generate a convolutional code object, the user should specify
% the |Generator| polynomoal of the intended code as a _vector_ containing
% its coefficients. Morover, the optional |Type| (RSC/NSC/Tail Biting),
% |DecoderType|, and |Depth| of the decoder for the tail biting
% convolutional code can be specified by the user as optional inputs.
%
% This class has two main methods namely *Encode* and *Decode*.
%%
%% Encoding Operation
% The |Encode| operation is performed by calling the ConvEncode cmex function. The
% user specifies the |DataBits| to be encoded by the generated covolutional
% code object.
%%
%% Decoding Operation
% The |Decode| operation is performed by either *_hard_* decision or _soft_
% decision optimum decoding algorithms. In each case, the following
% respectice cmex functions are called to perform the decoding operations.
%
% * For *_soft_* decision decoding, SisoDecode cmex function with the
% specified decoder type is called.
% * For *_hard_* decision decoding, ViterbiDecode cmex function is called.
%
% The |DecoderType| for soft decision decoding can be one of the following
% options:
%
% # Optimum Soft-In/Hard-Out Viterbi algorithm (DEFAULT) (|DecoderType=-1|)
% # SISO linear-log-MAP algorithm (Correction function is a straght line)
% (|DecoderType=0|)
% # SISO max-log-MAP algorithm (max*(x,y) = max(x,y) and correction
% function is equal to zero.) (|DecoderType=1|)
% # SISO Constant-log-MAP algorithm (Correction function is a constant) (|DecoderType=2|)
% # SISO log-MAP algorithm in which the correction factor is selected from small nonuniform table and interpolation (|DecoderType=3|).
% # SISO log-MAP algorithm in which the correction factor uses C function calls (|DecoderType=4|).

classdef ConvCode < ChannelCode
    % The methods of this class perform the operations of convolution encoding and decoding of a sequence of data bits or a vector of received bit Log-Likelihood Ratios
    % (LLR) for the received data to be decoded, respectively.
    %
    % ConvCode Properties:
    % Generator       - Binary generator matrix for convolutional code
    % Type            - Type of the convolutional code
    %
    % ConvCode Methodes:
    % Encode
    % Decode

    properties
        Generator       % Binary generator matrix for convolutional code
        Type=0          % Type of the convolutional code
        % 0 for Recursive Systematic Convolutional (RSC) codes (DEFAULT)
        % 1 for non-systematic convolutional (NSC) codes
        % 2 for tail-biting NSC code

        DecoderType=-1  % (OPTIONAL INPUT) Type of the decoder to be used in the decoding process of the Convolutional Code
        % =-1 For the optimum Soft-In/Hard-Out Viterbi algorithm (DEFAULT)
        % =0 For the SISO linear-log-MAP algorithm (Correction function is a straght line)
        % =1 For the SISO max-log-MAP algorithm (max*(x,y) = max(x,y) and correction function is equal to zero.)
        % =2 For the SISO Constant-log-MAP algorithm (Correction function is a constant).
        % =3 For the SISO log-MAP algorithm in which the correction factor is selected from small nonuniform table and interpolation.
        % =4 For the SISO log-MAP algorithm in which the correction factor uses C function calls.
        Depth=-1        % OPTIONAL INPUT Wrap depth used for tail-biting decoding (Default is 6 times the constraint length)
        OutU            % OPTIONAL OUTPUT Log-Likelihood Ratios (LLR) of the Data Bits (Only used as an output in all SISO decoding algorithms)
        OutC            % OPTIONAL OUTPUT Log-Likelihood Ratios (LLR) of the Code Bits (Only used as an output in all SISO decoding algorithms)
    end

    methods

        function obj = ConvCode(Generator, K, Type, DecoderType, Depth)
            % Class Constructor: Generator matrix of convolutional code and its DataLength must be specified.
            % Constructor syntax: obj = ConvCode(Generator, K [,Type] [,DecoderType] [,Depth])
            obj.Generator = Generator; % The length of the generator matrix is m+1.
            obj.DataLength = K;
            if( nargin>=3 && ~isempty(Type)), obj.Type = Type; end
            if( nargin>=4 && ~isempty(DecoderType)), obj.DecoderType = DecoderType; end
            if( nargin>=5 && ~isempty(Depth)), obj.Depth = Depth; end

            Codeword = obj.Encode( zeros(1,obj.DataLength) );
            obj.CodewordLength = length(Codeword);
            obj.Rate = obj.DataLength/obj.CodewordLength;
        end


        function [Codeword] = Encode(obj, DataBits)
            % Encoder method
            if(nargin<2 || isempty(DataBits)), DataBits = round(rand(1,obj.DataLength)); end
            obj.DataBits=DataBits;
            Codeword = ConvEncode(obj.DataBits, obj.Generator, obj.Type);
            obj.Codeword=Codeword;
        end


        function [EstBits, NumBitError, varargout] = Decode(obj, ReceivedLLR, DataBitsLLR)
            % Decoder Method performs Soft-In Hard or Soft-Out decoding for a convolutional code using the optimum Viterbi or SISO algorithms, respectively.
            % [DataBitsLLR] is the INPUT OPTIONAL Log-Likelihood Ratios (LLR) of the DataBits (Only used in the SISO decoding algorithms).
            %
            % Calling syntax: [ EstBits, NumBitError [,OutC] [,OutU] ] = Decode(obj, ReceivedLLR, [DataBitsLLR])

            obj.ReceivedLLR = ReceivedLLR;
            InU=zeros( 1,length(obj.DataBits) );
            if(nargin>=3 && ~isempty(DataBitsLLR)), InU = DataBitsLLR; end

            switch obj.DecoderType
                case -1
                    if (obj.Type==2 && obj.Depth>=0)
                        EstBits=ViterbiDecode(obj.ReceivedLLR, obj.Generator, obj.Type, obj.Depth);
                    else
                        EstBits=ViterbiDecode(obj.ReceivedLLR, obj.Generator, obj.Type);
                    end

                case {0, 1, 2, 3, 4}
                    if (obj.Type==2)
                        error( 'ConvCodeDecode:InvalidSISOTailBiting', 'You cannot use any Soft-Input Soft-Output (SISO) decoding algorithm for Tali-biting Convolutional Codes.' );
                    else
                        [obj.OutU obj.OutC] = SisoDecode(obj.ReceivedLLR, InU, obj.Generator, obj.Type, obj.DecoderType);
                        EstBits=(obj.OutU>0);
                    end

                otherwise
                    error( 'ConvCodeDecode:InvalidDecoderType', 'Decoder type has to be one of the integers -1, 0, 1, 2, 3 or 4. Please refer to the help of the ConvCode class to find out the meaning of these options for the Decoder Type.' );
            end
            obj.EstBits=EstBits;
            NumBitError = sum( EstBits ~= obj.DataBits );
            obj.NumError = NumBitError;
            varargout{1}=obj.OutC;
            varargout{2}=obj.OutU;
        end
        
        
        function NumBitError = ErrorCount(obj, ReceivedLLR, DataBitsLLR)
        % This is the methode responsible for counting the errors made between the input and ouput of the Encode and Decode methods, respectively.
            if(nargin<3 || isempty(DataBitsLLR)), DataBitsLLR = []; end
            [EstBits, NumBitError] = obj.Decode(ReceivedLLR, DataBitsLLR);
        end
    end
end