classdef BICM < Modulation
% Last BICM class updated on July 25, 2010.
    
    properties
        % Data is a row vector to be encoded, (potentially) interleaved, and modulated (The length of Data has to be an integer multiple (N) of LOG2(Order).)
        % The length of the Data should be equal to the Datalength of the Channel_Code object input.
        Codeword            % Encoded codeword of Data using Channel_Code.
        InterleavedCodeword % Interleaved version of Codeword using IntPattern as the interleaving pattern.
        Channel_Code        % Channel code object used in the encoding and decoding operations of the BICM class.
        Interleaver=0       % TYPE of the interleaver OR the specific interleaver pattern to be used in the interleaving operation of the codewords.
                    % =-1 No interleaving is used.
                    % =0  Random interleaver (DEFAULT)
                    % =1  Interleaver according to the Consultative Committee for Space Data Systems (CCSDS) specifications
                    %     In this case, the number of input information bits (DataLength) for the SECOND convolutional code of the Binary Turbo Code has to be one 
                    %     of the 4 following integers: K2 = 3568, 7136, 7184 or 8920.
                    % =2  Interleaver according to the UMTS-LTE specifications
                    %     In this case, the number of input information bits (DataLength) for the SECOND convolutional code of the Binary Turbo Code has to be one 
                    %     of the 188 following integers: K2 = 40:8:512 OR 528:16:1024 OR 1056:32:2048 OR 2112:64:6144.
                    % =3  Interleaver according to the UMTS specifications
                    % If the length of this Property (Interleaver) is greater than ONE, it has to be in the form of a vector whose length is the same as the number of
                    % input information bits (DataLength) for the second convolutional code and describes the intended interleaving pattern.
                    
        IntPattern      % The vector of interleaver pattern whose integer multiple of length is obj.DataLength bits.
        Iteration=1     % Maximum number of the iterations of the BICM demodulation/decoding. (Default: noniterative decoding and demodulation)
                        % BICM-ID is supported only for Convolutional and PCCC Turbo (including UMTS Turbo) codes.
                        % BICM_ID is NOT supported for HSDPA, Wimax tailbiting CTC, BTC, and LDPC codes. Thus, always Iteration=1 for them.
    end
    
    methods
        
        function obj = BICM( SignalSet, Channel_Code, varargin )
        % Class constructor: obj = BICM( SignalSet, Channel_Code, [,Iteration] [,Interleaver] )
            obj@Modulation(SignalSet);
            obj.Channel_Code = Channel_Code;
            if (length(varargin)>=1)
                obj.Interleaver = varargin{1};
                if (length(varargin)>=2)
                    obj.Iteration = varargin{2};
                end
            end
            
            if obj.Interleaver ~= -1
                obj.IntPattern = InterleaverPattern(obj, obj.Interleaver);
            end
        end
        
        
        function Pattern = InterleaverPattern(obj, InterleaverType)
        % Pattern is the vector of interleaver pattern whose integer multiple of length is obj.DataLength bits.
            if (length(InterleaverType) == 1)

                switch InterleaverType
                    case 0
                        Pattern = randperm(obj.Channel_Code.DataLength)-1;
                    case 1
                        Pattern = CreateCcsdsInterleaver(obj.Channel_Code.DataLength);
                    case 2
                        Pattern = CreateLTEInterleaver(obj.Channel_Code.DataLength);
                    case 3
                        Pattern = CreateUmtsInterleaver(obj.Channel_Code.DataLength);
                    otherwise
                        error('The type of the interleaver used in the BICM has to be one of the integers between -1 and 3, inclusively.', 'Invalid Interleaver Type');
                end

            else
                Pattern = InterleaverType;
            end
        end
        
        
        % Modulate Method
        function ModulatedSignal = Modulate(obj, Data)
            obj.Codeword = obj.Channel_Code.Encode( Data );
            if obj.Interleaver ~= -1
                obj.InterleavedCodeword = obj.Codeword( obj.IntPattern+1 );
            else
                obj.InterleavedCodeword = obj.Codeword;
            end
            ModulatedSignal = Modulate@Modulation(obj, cast( obj.InterleavedCodeword, 'uint8' ));
            obj.Data=Data;
        end
        
        
        function BitLikelihood = Demodulate(obj, RecievedSignal, varargin)
        % Demodulate Method: BitLikelihood=Demodulate(RecievedSignal [,EsN0], [,FadingCoef] [,DemodType])
            obj.RecievedSignal=RecievedSignal;
            obj.FadingCoef=ones(1,length(obj.RecievedSignal)); % Fading Coefficients for AWGN Channel
            if (length(varargin)>=1)
                obj.EsN0 = varargin{1};
                if (length(varargin)>=2)
                    obj.FadingCoef=varargin{2};
                    if (length(varargin)>=3)
                        obj.DemodType = varargin{3};
                    end
                end
            elseif (obj.EsN0<0)
                error('In order to demodulate RecievedSignal, EsN0 of the channel has to be specified in LINEAR units.');
            end

            obj.SymbolLikelihood = VectorDemod(obj.RecievedSignal, obj.SignalSet, obj.EsN0);
            
            % Initialize errors vector.
            obj.Channel_Code.NumError = zeros(obj.Iteration,1);

            % Initialize the extrinsic soft demapper input.
            Input_Demap_C = zeros( 1, size(obj.SymbolLikelihood,2) * log2(obj.Order) );

            for BICM_Iter = 1:obj.Iteration
                % Soft demapping first.
                if ( strcmpi(obj.Type, 'BPSK') )
                    BitLikelihood = obj.SymbolLikelihood;
                    Input_Decoder_C = BitLikelihood;
                else
                    BitLikelihood = obj.Mapper.Demap( obj.SymbolLikelihood, obj.DemodType, Input_Demap_C );size(BitLikelihood), obj.Channel_Code.CodewordLength
                    Input_Decoder_C = BitLikelihood( 1:obj.Channel_Code.CodewordLength );
                end
                
                % Deinterleave (if needed).
                if obj.Interleaver ~= -1
                    Input_Decoder_C( obj.IntPattern+1 ) = Input_Decoder_C;
                end
                
                % Decode.
                if BICM_Iter==1
                    [EstBits, Output_Decoder_C, Output_Decoder_U] = obj.Channel_Code.Decode( Input_Decoder_C );
                else
                    [EstBits, Output_Decoder_C, Output_Decoder_U] = obj.Channel_Code.Decode( Input_Decoder_C, Input_Decoder_U );
                end
                
                % Count errors.
                ErrorPositions = xor( EstBits, obj.Data );
                obj.Channel_Code.NumError(BICM_Iter) = sum( ErrorPositions );

                % Exit if all the errors are corrected (or if the Viterbi decoder is used for convolutional decoding).
                if ( ( obj.Channel_Code.NumError(BICM_Iter)==0) || isempty(Output_Decoder_C) )
                    return;
                end

                % Determine new Input_Decoder_U.
                Input_Decoder_U = Output_Decoder_U;

                % Turn Bit LLR into extrinsic information for the soft demapper.
                Input_Demap_C = Output_Decoder_C - Input_Decoder_U;

                % Interleave (if needed).
                if obj.Interleaver ~= -1
                    Input_Demap_C = Input_Demap_C( obj.IntPattern+1 );
                end
            end

            % The following if statement was commented on July 16, 2010.
%             if ( strcmpi(obj.Type, 'BPSK') )
%                 BitLikelihood = obj.SymbolLikelihood;
%             else
% OLDER VERSION                BitLikelihood = Somap(obj.SymbolLikelihood, obj.DemodType); % Extrinsic information is considered to be all zero (DEFAULT).
% OLD VERSION                BitLikelihood = Demap(obj.SymbolLikelihood, obj.DemodType); % Extrinsic information is considered to be all zero (DEFAULT).
                BitLikelihood = obj.Mapper.Demap( obj.SymbolLikelihood, obj.DemodType ); % Extrinsic information is considered to be all zero (DEFAULT).
%             end
            obj.BitLikelihood=BitLikelihood;
        end
    end    
end