classdef CodedModulation < handle
    
    properties
        ChannelCodeObject   % An object which performs the operations of Encoding and Decoding.
        Mapper              % An object which performs the operations of Mapping and Demapping. It has log2(obj.Order) as its input.
        ZeroRandFlag=0      % A binary flag which is used when input vector DataBits is not given to Encode method:
                            % =0 Generate a vector of ALL ZEROS for encoding (Default).
                            % =1 Generate a RANDOM vector of bits for encoding.
    end
    
    properties( SetAccess = protected )
        PaddingLength = 0   % Number of bits required to padd input DataBits to Encode method to make its length an integer  multiple of ChannelCodeObject.DataLength.
        NumBitError
        NumCodewords
    end
    
    methods
        
        function obj = CodedModulation(ChannelCodeObject, M, DemodType, ZeroRandFlag)
        % Calling syntax: obj = CodedModulation(ChannelCodeObject [,M] [,DemodType] [,ZeroRandFlag])
            if(nargin<2 || isempty(M)), M = 2; end
            if(nargin<3 || isempty(DemodType)), DemodType = 0; end
            if(nargin>=4 && ~isempty(ZeroRandFlag)), obj.ZeroRandFlag = ZeroRandFlag; end
            obj.ChannelCodeObject = ChannelCodeObject;
            obj.Mapper = Mapping( log2(M),DemodType );    % log2(M) is the number of bits per symbol.
        end
        
        
        function DataSymbols = Encode(obj, DataBits)
            K = obj.ChannelCodeObject.DataLength;
            if(nargin<2 || isempty(DataBits))
                if obj.ZeroRandFlag==0      % DataBits is all zeros.
                    obj.ChannelCodeObject.DataBits = zeros(1,K);
                    obj.NumCodewords = 1;
                    Codeword = zeros(1,obj.ChannelCodeObject.CodewordLength);
                    obj.ChannelCodeObject.Codeword = Codeword;
                    DataSymbols = obj.Mapper.Map(cast(Codeword,'uint8')); % vector of M-ary symbols as INT32.
                    return;
                elseif obj.ZeroRandFlag==1  % DataBits is random.
                    DataBits = round( rand(1,K) );
                end
            else
                obj.PaddingLength = ceil(length(DataBits)/K) * K - length(DataBits);
                if(obj.PaddingLength>0), DataBits = [zeros(1,obj.PaddingLength) DataBits]; end
            end
            obj.NumCodewords = length(DataBits)/K;
            Codeword = obj.ChannelCodeObject.Encode(DataBits);
            DataSymbols = obj.Mapper.Map(cast(reshape(Codeword',1,[]),'uint8')); % vector of M-ary symbols as INT32.
        end
        
        
        function [EstBits, NumBitError, NumCodewordError] = Decode(obj, SymbolLikelihood, ExtrinsicInfo)
            if(nargin<3 || isempty(ExtrinsicInfo))
                % Extrinsic information is considered to be all zero (DEFAULT).
                ExtrinsicInfo = zeros( 1, size(SymbolLikelihood,2)*log2(size(SymbolLikelihood,1)) );
            end
            BitLikelihood = obj.Mapper.Demap( SymbolLikelihood, ExtrinsicInfo );
            % Find EstBits which includes padded bits and codeword bits affected by them.
            [EstBits, obj.NumBitError] = obj.ChannelCodeObject.Decode(cast(reshape(BitLikelihood,obj.ChannelCodeObject.CodewordLength,[])','double'));
            % Assume that the code is systematic.
            % obj.NumBitError = sum( EstBits(obj.PaddingLength+1:obj.ChannelCodeObject.DataLength) ~= obj.ChannelCodeObject.DataBits(obj.PaddingLength+1:end) );
            NumBitError = obj.NumBitError;
            NumCodewordError = (NumBitError>0);
        end
        
        
        function [NumBitError, NumCodewordError] = ErrorCount(obj, SymbolLikelihood, ExtrinsicInfo)
            if(nargin<3 || isempty(ExtrinsicInfo))
                % Extrinsic information is considered to be all zero (DEFAULT).
                ExtrinsicInfo = zeros( 1, size(SymbolLikelihood,2)*log2(size(SymbolLikelihood,1)) );
            end
            [EstBits, NumBitError, NumCodewordError] = obj.Decode(SymbolLikelihood, ExtrinsicInfo);
            % NumBitError = sum( EstBits(obj.PaddingLength+1:obj.ChannelCodeObject.DataLength) ~= obj.ChannelCodeObject.DataBits(obj.PaddingLength+1:end) );
            % NumCodewordError = sum(NumBitError>0);
        end
    end
    
end