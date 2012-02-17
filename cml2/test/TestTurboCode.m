DataLength = 512;
Data = round(rand(1,DataLength));

G1 = [1 0 1 1;1 1 0 1];
PuncturePatt = [1 1;1 1;0 0;1 1];
TailPunc = ones(4,3);
DecoderType = 0;            % SISO decoding algorithm using linear-log-MAP (Correction function is a straght line) (DEFAULT).
Iteration = 8;
% UMTS turbo code will be defined as follows:

A = TurboCode(G1, G1, 3, PuncturePatt, TailPunc, DataLength, DecoderType, Iteration);

EncData = A.Encode(Data);

ModData = 2*EncData-1;      % BPSK Modulation.

EsN0 = 2;
variance = 1/(2*EsN0);
noise = sqrt(variance)* randn( size(ModData) );

rcvData = ModData + noise;
LLR = (2/variance) * rcvData;

DecData = A.Decode(LLR);

ErrorPos = DecData~=Data;
NumError = sum(ErrorPos);