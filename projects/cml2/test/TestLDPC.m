%% DVBS2 IN CML2 (ACT)
cd('C:\Users\Mohammad\Desktop\CMLProject\ACT\mat');
EffectiveRate = 1/3;% For short frames of DVBS2 standard, the actual rate of the LDPC code might be smaller.
FrameSize = 64800;  % FrameSize should be either 16200 (short frame) or 64800 (normal frame) for DVBS2 standard.
MaxIteration = 10;  % Maximum number of message passing decoding iteration (Default MaxIteration=30).
DecoderType = 0;    % Message passing decoder type:
                    % 0 sum-product (DEFAULT), 1 min-sum, 2 approximate min-sum (NOT supported yet).
SNRdB = 1;
[HRows, HCols] = InitializeDVBS2(EffectiveRate, FrameSize);

CodeObj = LDPCCode( HRows, [], MaxIteration, DecoderType );
ModObj = QPSK();

% For normal frames of DVBS2 standars, K=FrameSize*EffectiveRate.
Data = round(rand(1, FrameSize*EffectiveRate));
% Data = zeros(1, FrameSize*EffectiveRate);
EncData = CodeObj.Encode(Data);
ModData = ModObj.Modulate(cast(EncData, 'uint8'));      % BPSK Modulation.

EsN0 = 10^(SNRdB/10);
variance = 1/(2*EsN0);
noise = sqrt(variance)* randn( size(ModData) );

rcvData = ModData + noise;
LLR = ModObj.Demodulate( rcvData, EsN0 );

ModDataT = -2*EncData+1;      % BPSK Modulation.
% noiseT = sqrt(variance)* randn( size(ModDataT) );
noiseT = noise;
rcvDataT = ModDataT + noiseT;
LLRT = (2/variance) * rcvDataT;

% [DecData, NumError] = CodeObj.Decode(LLR);
% 
% [DecDataT, NumErrorT] = CodeObj.Decode(-LLRT);


%% DVBS2 IN CML22 (ACT2) (EE561)
cd('C:\Users\Mohammad\Desktop\CMLProject\ACT\EE561\ee561\mat');
EffectiveRate = 1/3;% For short frames of DVBS2 standard, the actual rate of the LDPC code might be smaller.
FrameSize = 64800;  % FrameSize should be either 16200 (short frame) or 64800 (normal frame) for DVBS2 standard.
MaxIteration = 10;  % Maximum number of message passing decoding iteration (Default MaxIteration=30).
DecoderType = 0;    % Message passing decoder type:
                    % 0 sum-product (DEFAULT), 1 min-sum, 2 approximate min-sum (NOT supported yet).
DemodType=0;        % Demodulater type indicating how the max_star function is implemented within the Demapper.
                    % =0 (linear-log-MAP) (Correction function is a straght line.) (DEFAULT).
                    % =1 (max-log-MAP) (max*(x,y) = max(x,y) and correction function = 0).
                    % =2 (constant-log-MAP algorithm (Correction function is a constant.)
                    % =3 (log-MAP) (Correction factor from small nonuniform table and interpolation.)
                    % =4 (log-MAP) (Correction factor uses C function calls.)
SNRdB = 0.1;
EsN0 = 10^(SNRdB/10);
[HRows, HCols] = InitializeDVBS2(EffectiveRate, FrameSize);

CodeObj = LDPCCode( HRows, HCols, [], MaxIteration, DecoderType );
ModObj = BPSK();    % SignalProb=[1 1]. Only the constellation is created.
Mapper = Mapping( log2(ModObj.Order), DemodType );
ChannelObj = AWGN( ModObj, EsN0 );

% For normal frames of DVBS2 standars, K=FrameSize*EffectiveRate.
% Data = round(rand(1, FrameSize*EffectiveRate));
Data = zeros(1, FrameSize*EffectiveRate);

EncData = CodeObj.Encode(Data);

EncSymbols = Mapper.Map(cast(EncData, 'uint8')); % Binary symbols of 1 and 2 are generated.

SymbolLikelihood = ChannelObj.ChannelUse(EncSymbols, EsN0);

BitLikelihood = Mapper.Demap( SymbolLikelihood );


ModDataT = -2*EncData+1;      % BPSK Modulation.
noiseT = sqrt(ChannelObj.Variance)* randn( size(ModDataT) );
rcvDataT = ModDataT + noiseT;
BitLikelihoodT = (2/ChannelObj.Variance) * rcvDataT;

% [DecDataT, NumErrorT] = CodeObj.Decode(-BitLikelihoodT);
% [DecData, NumError] = CodeObj.Decode(BitLikelihood);


%% DVBS2 IN CML22 (ACT2) (EE561)
cd('C:\Users\Mohammad\Desktop\CMLProject\ACT\EE561\ee561\mat');
EffectiveRate = 1/3;% For short frames of DVBS2 standard, the actual rate of the LDPC code might be smaller.
FrameSize = 64800;  % FrameSize should be either 16200 (short frame) or 64800 (normal frame) for DVBS2 standard.
MaxIteration = 10;  % Maximum number of message passing decoding iteration (Default MaxIteration=30).
DecoderType = 0;    % Message passing decoder type:
                    % 0 sum-product (DEFAULT), 1 min-sum, 2 approximate min-sum (NOT supported yet).
DemodType=0;        % Demodulater type indicating how the max_star function is implemented within the Demapper.
                    % =0 (linear-log-MAP) (Correction function is a straght line.) (DEFAULT).
                    % =1 (max-log-MAP) (max*(x,y) = max(x,y) and correction function = 0).
                    % =2 (constant-log-MAP algorithm (Correction function is a constant.)
                    % =3 (log-MAP) (Correction factor from small nonuniform table and interpolation.)
                    % =4 (log-MAP) (Correction factor uses C function calls.)
SNRdB = 0.1;
EsN0 = 10^(SNRdB/10);

CodeObj = LDPC_DVBS2( EffectiveRate, FrameSize, MaxIteration, DecoderType );
ModObj = BPSK();    % SignalProb=[1 1]. Only the constellation is created.
Mapper = Mapping( log2(ModObj.Order), DemodType );
ChannelObj = AWGN( ModObj, EsN0 );

% For normal frames of DVBS2 standars, K=FrameSize*EffectiveRate.
% Data = round(rand(1, FrameSize*EffectiveRate));
Data = zeros(1, FrameSize*EffectiveRate);

EncData = CodeObj.Encode(Data);

EncSymbols = Mapper.Map(cast(EncData, 'uint8')); % Binary symbols of 1 and 2 are generated.

SymbolLikelihood = ChannelObj.ChannelUse(EncSymbols, EsN0);

BitLikelihood = Mapper.Demap( SymbolLikelihood );


ModDataT = -2*EncData+1;      % BPSK Modulation.
noiseT = sqrt(ChannelObj.Variance)* randn( size(ModDataT) );
rcvDataT = ModDataT + noiseT;
BitLikelihoodT = (2/ChannelObj.Variance) * rcvDataT;

% [DecDataT, NumErrorT] = CodeObj.Decode(-BitLikelihoodT);
% [DecData, NumError] = CodeObj.Decode(BitLikelihood);