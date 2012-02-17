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
        MaxColWeight=30
    end
    
    methods
        
        function obj = LDPCCode( HRows, HCols, P, MaxIteration, DecoderType )
        % Calling Syntax: obj = LDPCCode( HRows, [,HCols] [,P] [,MaxIteration] [,DecoderType] )
            if(nargin<2 || isempty(HCols)), HCols = []; end
            if(nargin<3 || isempty(P)), P = []; end
            if(nargin<4 || isempty(MaxIteration)), MaxIteration = 30; end
            if(nargin<5 || isempty(DecoderType))
                DecoderType = 0;
            elseif isempty( find(DecoderType==[0 1 2], 1) )
                error('LDPCCode:DecoderType', 'The optional input DecoderType should be either 0 (sum-product), 1 (min-sum), or 2 (approximate min-sum).');
            end
            obj.P = P;
            
            if(ischar(HRows))
                obj.ReadAListFile(HRows);
            else
                obj.HRows = HRows;
                if isempty(HCols)
                    obj.HCols = obj.FindHCols();
                else
                    obj.HCols = HCols;
                end
                % HCols has N-M rows for DVBS2 and N-M+z rows for LDPCWiMax, P=[] for DVBS2.
                % IF THE CODE IS NOT WIMAX OR DVBS2, THIS PART SHOULD BE CHANGED.
                obj.DataLength = size(obj.HCols,1) - size(obj.P,1);
                % HRows has M rows.
                obj.CodewordLength = obj.DataLength + size(obj.HRows,1);
            end
            obj.MaxIteration = MaxIteration;
            obj.DecoderType = DecoderType;
            obj.Rate = obj.DataLength/obj.CodewordLength;
        end
        
        function Codeword = Encode( obj, DataBits )
        % Encode method for eIRA LDPC codes.
            if(nargin<2 || isempty(DataBits)), DataBits = round(rand(1,obj.DataLength)); end
            obj.DataBits = DataBits;
            Codeword = LdpcEncode(obj.DataBits, obj.HRows, obj.P);
            obj.Codeword=Codeword;
        end
        
        function [EstBits, NumError] = Decode(obj, ReceivedLLR)
        % Decoder method for message passing decoding for a block code.
        %
        % Calling syntax: [EstBits, NumError] = Decode(obj, ReceivedLLR)
        % ReceivedLLR is the received vector of bit Log-Likelihood-Ratio (LLR) for the received data (Codeword) to be decoded.
        % NumError is a column vector showing the number of code-bit errors after each iteration of decoding.
            obj.ReceivedLLR = ReceivedLLR;
            [EstBitsHat NumError] = MpDecode( -obj.ReceivedLLR, obj.HRows, obj.HCols, obj.MaxIteration, obj.DecoderType, 1, 1, obj.DataBits );
            % EstBitsHat is MaxIteration-by-N matrix of decoded code bits for each iteration of decoding.
            EstBits = EstBitsHat(obj.MaxIteration,:);
            obj.EstBits = EstBits;
            obj.NumError = NumError;
        end
        
        function HCols = FindHCols(obj, HRows)
            if(nargin>1 && ~isempty(HRows)), obj.HRows = HRows; end
            NumCol = max(max(obj.HRows)); % Determine the number of columns in H matrix.
            % It might NOT be the exact number of columns in WiMax or DVBS2 LDPC codes.
            HCols = zeros(NumCol, obj.MaxColWeight);
            RealMaxColWeight = 0;
            for Col = 1:NumCol
                [Row, Column] = find(obj.HRows == Col);
                Row = unique(Row');
                HCols(Col,1:length(Row)) = Row;
                RealMaxColWeight = max(RealMaxColWeight, length(Row));
            end
            HCols(:,RealMaxColWeight+1:end) = [];
            obj.HCols = HCols;
            obj.MaxColWeight = RealMaxColWeight;
        end
        
        function ReadAListFile(obj, HRowsPath)
            AlistFile = dlmread(HRowsPath);
            N = AlistFile(1,1);
            obj.CodewordLength = N;
            M = AlistFile(1,2);
            obj.DataLength = N - M;
            obj.MaxColWeight = AlistFile(2,1);
            MaxRowWeight = AlistFile(2,2);
            obj.HCols = AlistFile(5:N+4, 1:obj.MaxColWeight);
            obj.HRows = AlistFile(N+5:N+M+4, 1:MaxRowWeight);
        end
    end
    
end