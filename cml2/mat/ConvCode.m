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
                        % 0 for Recursive Systematic Convolutional (RSC) codes (DEFAULT), 1 for non-systematic convolutional (NSC) codes and 2 for tail-biting NSC code
        
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
        
        % Class Constructor: Generator matrix of convolutional code and its type must be specified. The constructor syntax is as follows:
        % obj=ConvCode(Generator [,Type] [,DecoderType] [,Depth])
        function obj=ConvCode(Generator, varargin)
            obj.Generator=Generator;
            if (length(varargin)>=1)
                obj.Type=varargin{1};
                if (length(varargin)>=2)
                    obj.DecoderType=varargin{2};
                    if (length(varargin)>=3)
                        obj.Depth=varargin{3};
                    end
                end
            end
        end
        
        
        function [CodeWord]=Encode(obj, DataBits)
        % Encoder method
            obj.DataBits=DataBits;
            obj.DataLength=length(obj.DataBits);
            CodeWord=ConvEncode(obj.DataBits, obj.Generator, obj.Type);
%             obj.CodeWord=CodeWord;
        end
        
                
        function [EstData, varargout]=Decode(obj, ReceivedLLR, varargin)
        % Decoder Method performs Soft-In Hard or Soft-Out decoding for a convolutional code using the optimum Viterbi or SISO algorithms, respectively.
        % [DataBitsLLR] is the INPUT OPTIONAL Log-Likelihood Ratios (LLR) of the DataBits (Only used in the SISO decoding algorithms).
        
        % The syntax of calling this method is as follows: [ EstData [,OutU] [,OutC] ]=Decode(obj, ReceivedLLR, [DataBitsLLR])
        
            obj.ReceivedLLR=ReceivedLLR;
            
            if (length(varargin)>=1)
                InU=varargin{1};
            else
                InU=zeros( 1,length(obj.DataBits) );
            end
            
            switch obj.DecoderType
                case -1
                    if (obj.Type==2 && obj.Depth>=0)
                        EstData=ViterbiDecode(obj.ReceivedLLR, obj.Generator, obj.Type, obj.Depth);
                    else
                        EstData=ViterbiDecode(obj.ReceivedLLR, obj.Generator, obj.Type);
                    end
                    
                case {0, 1, 2, 3, 4}
                    if (obj.Type==2)
                        errordlg( 'You cannot use any Soft-Input Soft-Output (SISO) decoding algorithm for Tali-biting Convolutional Codes.' , 'SISO NOT Valid for Tail-Biting Conv Codes' );
                    else
                        [obj.OutU obj.OutC] = SisoDecode(obj.ReceivedLLR, InU, obj.Generator, obj.Type, obj.DecoderType);
                        EstData=(sign(obj.OutU)+1)/2;
                        varargout{1}=obj.OutU;
                        varargout{2}=obj.OutC;
                    end
                    
                otherwise
                        errordlg( 'Decoder type has to be one of the integers -1, 0, 1, 2, 3 or 4. Please refer to the help of the ConvCode class to find out the meaning of these options for the Decoder Type.', 'Invalid Decoder Type' );
            end
            obj.EstBits=EstData;
        end        
    end    
end