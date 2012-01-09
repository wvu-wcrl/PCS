classdef TurboCode < ChannelCode
% The methods of this class perform the operations of Binary Turbo Encoding and Decoding of a sequence of data bits or a vector of received bit Log-Likelihood Ratios (LLR),
% respectively.
       
    properties
        % Codeword will contain multiple rows if the DataBits vector is longer than the Interleaver. If the DataLength is an integer  multiple of the
        % Interleaver length, then multiple codewords are returned one per row of the Codeword matrix.
        % NumError is a column vector containing the number of errors per iteration for ALL the codewords.
        
        G1          % The first binary generator matrix for the first convolutional code
        Type1=0     % Type of the first convolutional code
                    % 0 for Recursive Systematic Convolutional (RSC) codes (DEFAULT)
                    % 1 for Non-Systematic Convolutional (NSC) codes
                    % 2 for tail-biting NSC code
                    
        G2          % The second binary generator matrix for the second convolutional code
        Type2=0     % Type of the second convolutional code
        
        Interleaver % TYPE of the interleaver OR the specific interleaver pattern to be used in the Binary Turbo Code
                    % =0 Random interleaver
                    % =1 Interleaver according to the Consultative Committee for Space Data Systems (CCSDS) specifications
                    %    In this case, the number of input information bits (DataLength) for the SECOND convolutional code of the Binary Turbo Code has to be one 
                    %    of the 4 following integers: K2 = 3568, 7136, 7184 or 8920.
                    % =2 Interleaver according to the UMTS-LTE specifications
                    %    In this case, the number of input information bits (DataLength) for the SECOND convolutional code of the Binary Turbo Code has to be one 
                    %    of the 188 following integers: K2 = 40:8:512 OR 528:16:1024 OR 1056:32:2048 OR 2112:64:6144.
                    % =3 Interleaver according to the UMTS specifications
                    % If the length of this Property (Interleaver) is greater than ONE, it has to be in the form of a vector whose length is the same as the number of
                    % input information bits (DataLength) for the second convolutional code and describes the intended interleaving pattern.
                    
        IntPattern      % The vector of interleaver pattern whose integer multiple of length is obj.DataLength bits.
                    
        PuncturePatt    % The specific puncturing pattern to be used in the Binary Turbo Code for all the codeword bits EXCEPT the TAIL
                        
        TailPunc        % Specific puncturing pattern to be used in the Binary Turbo Code JUST for the TAIL
        
        DecoderType=0   % Type of the decoder to be used in the decoding process of the Binary Turbo Code
                        % =0 For linear-log-MAP algorithm (Correction function is a straght line) (DEFAULT).
                        % =1 For max-log-MAP algorithm (max*(x,y) = max(x,y) and correction function is equal to zero.)
                        % =2 For Constant-log-MAP algorithm (Correction function is a constant).
                        % =3 For log-MAP algorithm in which the correction factor is selected from small nonuniform table and interpolation.
                        % =4 For log-MAP algorithm in which the correction factor uses C function calls.
        
        Iteration=8     % Number of turbo decoding iterations
    end
    
    
    properties(SetAccess = protected)
        Code1       % The first convolutional code object used in the Binary Turbo Code
        Code2       % The second convolutional code object used in the Binary Turbo Code
        N1          
        V1          % Constraint length of the first convolutional code, i.e. m+1
        N2          
        V2          % Constraint length of the second convolutional code
        NumberCodeword  % Number of codewords
        LInterleaver    % Length of the interleaver pattern
        DataMatrix  % If obj.DataLengh>InterleaverLength, DataBits is arranged in a matrix which has InterleaverLength columns.
        ExtBitInf       % Extrinsic information of the code bits generated during the decoding process
    end
    
    
    methods
        
        function obj = TurboCode(G1, G2, Interleaver, PuncturePatt, TailPunc, DataLength, DecoderType, Iteration, Type1, Type2)
        % Class Constructor: Binary generator matrices and types of both of the convolutional codes, interleaver type or pattern, puncturing
        % pattern for both codeword bits and tail bits and also, length of DataBits to be encoded must be specified.
        % Calling Syntax: obj = TurboCode(G1, G2, Interleaver, PuncturePatt, TailPunc, DataLength [,DecoderType] [,Iteration] [,Type1] [,Type2])
            
            [obj.N1, obj.V1] = size(G1); % Determining the size of the first convolutional code generator.
            [obj.N2, obj.V2] = size(G2);
            % In the future, we will allow constituent codes with different constraint lengths to be used in the Binary Turbo Codes.
            if ( obj.V1 ~= obj.V2 )
                error( 'TurboCode:ConstituentMismatch', 'The constraint lengths of the two PCCC constituent codes must be IDENTICAL. Please choose two generator matrices for the two constituent codes with the same number of COLUMNS.' );
            end
            
            if(nargin>=7 && ~isempty(DecoderType)), obj.DecoderType = DecoderType; end
            if(nargin>=8 && ~isempty(Iteration)), obj.Iteration = Iteration; end
            if(nargin>=9 && ~isempty(Type1)), obj.Type1 = Type1; end
            if(nargin>=10 && ~isempty(Type2)), obj.Type2 = Type2; end
            obj.G1=G1;
            obj.Code1 = ConvCode(obj.G1, DataLength, obj.Type1, obj.DecoderType);
            obj.G2=G2;
            obj.Code2 = ConvCode(obj.G2, DataLength, obj.Type2, obj.DecoderType);
            
            obj.Interleaver=Interleaver;
            obj.PuncturePatt=PuncturePatt;
            obj.TailPunc=TailPunc;
            obj.DataLength=DataLength;
            
            obj.IntPattern = obj.InterleaverPattern(obj.Interleaver);
            
            % Checking Interleaver Length against DataLength
            obj.LInterleaver = length(obj.IntPattern);
            if ( rem(obj.DataLength, obj.LInterleaver) ~= 0 )
                error( 'TurboCode:DataLength_Interleaver_Mismatch', 'The length of data to be encoded needs to be an INTEGER multiple of the interleaver length.' );
            end
            
            % Setting the code Rate and CodewordLength
            Codeword = obj.Encode( zeros(1, obj.DataLength) );
            obj.CodewordLength = size(Codeword, 2);
            obj.Rate = obj.DataLength/obj.CodewordLength;
        end
        
        function Pattern = InterleaverPattern(obj, InterleaverType)
        % Pattern is the vector of interleaver pattern whose integer multiple of length is obj.DataLength bits.
            if (length(InterleaverType) == 1)
                switch InterleaverType
                    case 0
                        Pattern = randperm(obj.DataLength)-1;
                    case 1
                        Pattern = CreateCcsdsInterleaver(obj.DataLength);
                    case 2
                        Pattern = CreateLTEInterleaver(obj.DataLength);
                    case 3
                        Pattern = CreateUmtsInterleaver(obj.DataLength);
                    otherwise
                        error( 'TurboCode:InvalidInterleaverType', 'The type of the interleaver used in the Binary Turbo Codes has to be one of the integers between 0 and 3, inclusively.' );
                end
            else
                Pattern = InterleaverType;
            end
        end
        
        function Codeword = Encode(obj, DataBits)
            if(nargin<2 || isempty(DataBits)), DataBits = round(rand(1,obj.DataLength)); end
            if rem( length(DataBits), obj.LInterleaver ) ~= 0
                error( 'TurboCodeEncode:DataLength', 'The length of the binary input DataBits to be encoded by this object has to be an integer multiple of DataLength.' );
            end
            
            obj.DataBits = DataBits;
            obj.NumberCodeword = length(obj.DataBits)/obj.LInterleaver;
            obj.DataMatrix = reshape( obj.DataBits, obj.LInterleaver, obj.NumberCodeword )';
            
            for i=1:obj.NumberCodeword
                % Encoding in Parallel
                T=obj.DataMatrix(i,:);
                UpperOutput = obj.Code1.Encode (T);
                LowerOutput = obj.Code2.Encode (T(obj.IntPattern+1));
                                
                % Converting Coded Outputs to Matrices (each row is from one row of the generator)
                UpperReshaped = reshape( UpperOutput, obj.N1, length(UpperOutput)/obj.N1 );
                LowerReshaped = reshape( LowerOutput, obj.N2, length(LowerOutput)/obj.N2 );
                
                % Parallel Concatenation of Codeword Parts
                UnPuncturedWord = [UpperReshaped
                    LowerReshaped];
                
                % Puncture function deletes bits at the output of encoder according to the specified puncutring pattern.
                Codeword(i,:) = Puncture(UnPuncturedWord, obj.PuncturePatt, obj.TailPunc);
            end
            
            obj.Codeword = Codeword;
        end
        
        function [EstBits, ExtBitInf, UpperInUNext] = Decode(obj, ReceivedLLR, UpperU)
        % Calling syntax: [EstBits, ExtBitInf, UpperInUNext] = Decode(obj, ReceivedLLR [,UpperU])
        % ReceivedLLR could have multiple rows if DataBits is longer than IntPattern.
        % UpperU: OPTIONAL a priori information about systematic data bits.
        % ExtBitInf: Extrinsic information of the code bits generated during the decoding process.
            obj.ReceivedLLR = ReceivedLLR;
            
            % Initializing Error Counter
            NErrors = zeros(obj.Iteration, 1);
            UpperInU = zeros( obj.NumberCodeword, length(obj.DataBits)/obj.NumberCodeword );
            if(nargin>=3 && ~isempty(UpperU)), UpperInU = UpperU; end
            
            % Loop Over Each ReceivedLLR Frame
            for i=1:obj.NumberCodeword
                % Depuncture and Split Each ReceivedLLR Frame
                DepuncOutput = Depuncture(obj.ReceivedLLR(i,:), obj.PuncturePatt, obj.TailPunc);
                UpperInC = reshape( DepuncOutput(1:obj.N1,:), 1, obj.N1*length(DepuncOutput) );
                LowerInC = reshape( DepuncOutput(obj.N1+1:obj.N1+obj.N2,:), 1, obj.N2*length(DepuncOutput) );
                
                % Decoding Process
                for TurboIter=1:obj.Iteration
                    % fprintf( 'Turbo Iteration = %d\n', TurboIter );
                    % Pass Through Upper Decoder
                    % UpperOutputU and UpperOutputC are the LLRs of the DataBits and Code Bits.
                    [Useless UpperOutputC UpperOutputU] = obj.Code1.Decode( UpperInC, UpperInU(i,:) );
                    
                    % Interleaving and Extracting Extrinsic Information
                    T = UpperOutputU - UpperInU(i,:);
                    LowerInU = T(obj.IntPattern+1);
                    
                    % Pass Through Lower Decoder
                    [Useless LowerOutputC LowerOutputU] = obj.Code2.Decode( LowerInC, LowerInU );
                    
                    % Counting the Number of Eerrors
                    Temp1(obj.IntPattern+1)=(LowerOutputU>0);
                    DetectedData(i,:) = Temp1;
                    ErrorPosition = xor( DetectedData(i,:), obj.DataMatrix(i,:) );
                    TNError = sum(ErrorPosition);
                    
                    % Exit If All Errors Are Corrected                    
                    if (TNError==0)
                        break;
                    else
                        NErrors(TurboIter) = TNError + NErrors(TurboIter);
                        % Interleave and Extract Extrinsic Information
                        Temp2(obj.IntPattern+1) = LowerOutputU-LowerInU;
                        UpperInU(i,:) = Temp2;
                        UpperInUNext(i,:) = UpperInU(i,:);
                    end
                end
                
                % Combining OutputC, Puncturing It and Converting It to Matrices (each row is from one row of the generator).
                UpperReshaped = reshape( UpperOutputC, obj.N1, length(UpperOutputC)/obj.N1 );
                LowerReshaped = reshape( LowerOutputC, obj.N2, length(LowerOutputC)/obj.N2 );
                
                % Parallel Concatenation
                UnPuncturedWord = [UpperReshaped
                    LowerReshaped];
                
                % Repuncturing (ExtBitInf is the extrinsic information of the code bits.)
                ExtBitInf(i,:) = Puncture( UnPuncturedWord, obj.PuncturePatt, obj.TailPunc );
            end
            
            EstBits = reshape( DetectedData', 1, length(obj.DataBits) );
            obj.EstBits = EstBits;
            obj.ExtBitInf = ExtBitInf;
            % NumError is a column vector containing the number of errors per iteration for ALL the codewords.
            obj.NumError = NErrors;
        end
    end
end