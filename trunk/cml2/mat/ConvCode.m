classdef ConvCode < ChannelCode
% The methods of this class perform the operations of convolution encoding and decoding of a sequence of data bits or a vector of received bit Log-Likelihood Ratios
% (LLR) for the received data to be decoded, respectively.
    
    properties
        Generator       % Binary generator matrix for convolutional code
        % EstBits : Row vector containing hard or soft decision bits of decoded ReceivedLLR
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
        
        % Encoder method
        function [CodeWord]=Encode(obj, DataBits)
            obj.DataBits=DataBits;
            obj.DataLength=length(obj.DataBits);
            CodeWord=ConvEncode(obj.DataBits, obj.Generator, obj.Type);
%             obj.CodeWord=CodeWord;
        end
        
        % Decoder Method performs Soft-In Hard or Soft-Out decoding for a convolutional code using the optimum Viterbi or SISO algorithms, respectively.
        % [DataBitsLLR] is the INPUT OPTIONAL Log-Likelihood Ratios (LLR) of the DataBits (Only used in the SISO decoding algorithms).
        
        % The syntax of calling this method is as follows: [ EstData [,OutU] [,OutC] ]=Decode(obj, ReceivedLLR, [DataBitsLLR])
        
        function [EstData, varargout]=Decode(obj, ReceivedLLR, varargin)
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
                    end
                    
                    [obj.OutU obj.OutC] = SisoDecode(obj.ReceivedLLR, InU, obj.Generator, obj.Type, obj.DecoderType);
                    EstData=(sign(obj.OutU)+1)/2;
                    
                    varargout{1}=obj.OutU;
                    varargout{2}=obj.OutC;
                otherwise
                        errordlg( 'Decoder type has to be one of the integers -1, 0, 1, 2, 3 or 4. Please refer to the help of the ConvCode class to find out the meaning of these options for the Decoder Type.', 'Invalid Decoder Type' );
            end
            obj.EstBits=EstData;
        end        
    end    
end