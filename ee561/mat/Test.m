MM = CreateModulation([-1 1]);
C = AWGN( MM, 20 );
D = UncodedModulation(2, 4);

M = Encode(D, [0 0 1 1])
SymbolLikelihood = ChannelUse(C, M)
EstBits = Decode(D, SymbolLikelihood)

%%
K = 2000; N = 10;
T_RandP = zeros(K,1);
T_gDiscrPdfRnd = zeros(K,1);
for m=1:K
    tic; R = randp([1 3 2],N,1); T_RandP(m) = toc;
    tic; R = gDiscrPdfRnd([1 3],N,1); T_gDiscrPdfRnd(m) = toc;
end
T_RandP_Avg = mean(T_RandP)
T_gDiscrPdfRnd_Avg = mean(T_gDiscrPdfRnd)

%%
K = 20; N = 100000;
T_RandP = zeros(K,1);
T_Rand = zeros(K,1);
for m=1:K
    tic; R = randp([1 1],N,1); T_RandP(m) = toc;
    tic; R = (rand(N,1)>0.5); T_Rand(m) = toc;
end
T_RandP_Avg = mean(T_RandP)
T_Rand_Avg = mean(T_gDiscrPdfRnd)

%%
SymbolProb = [0.2 0.2 0.3 0.3];
SignalSet = [-1 -1  1  1
             -1  1 -1  1];
SNRdB = 5;
BlockLength = 10;
         
MM = CreateModulation(SignalSet, SymbolProb);
C = AWGN( MM, 10^(SNRdB/10) );
D = UncodedModulation(4, 10*SymbolProb, BlockLength);

M = Encode(D)
DataBits = D.DataBits
SymbolLikelihood = ChannelUse(C, M);
[EstBits, EstSymbols] = Decode(D, SymbolLikelihood)
[NumBitError, NumSymbolError] = ErrorCount(D, SymbolLikelihood)

%%
SymbolProb = [0.2 0.2 0.3 0.3];
SignalSet = [-1 -1  1  1
             -1  1 -1  1];
SNRdB = 5;
BlockLength = 10000;
         
MM = CreateModulation(SignalSet, SymbolProb);
C = AWGN( MM, 10^(SNRdB/10) );
D = UncodedModulation(4, 10*SymbolProb, BlockLength);

M = Encode(D);
hist(D.DataSymbols, [1:length(D.SymbolProb)]);
SymbolLikelihood = ChannelUse(C, M);
[EstBits, EstSymbols] = Decode(D, SymbolLikelihood);
[NumBitError, NumSymbolError] = ErrorCount(D, SymbolLikelihood)

%%
SymbolProb = [0.2 0.2 0.3 0.3];
SignalSet = [-1 -1  1  1
             -1  1 -1  1];
SNRdB = 5;
BlockLength = 10;

MM = CreateModulation(SignalSet, SymbolProb);
C = AWGN( MM, 10^(SNRdB/10) );
D = BinaryUncodedModulation(4, BlockLength);

M = Encode(D)
DataBits = D.DataBits
SymbolLikelihood = ChannelUse(C, M);
[EstBits, EstSymbols] = Decode(D, SymbolLikelihood)
[NumBitError, NumSymbolError] = ErrorCount(D, SymbolLikelihood)

%%
SymbolProb = [0.2 0.2 0.3 0.3];
SignalSet = [-1 -1  1  1
             -1  1 -1  1];
SNRdB = 5;
BlockLength = 10000;

MM = CreateModulation(SignalSet, SymbolProb);
C = AWGN( MM, 10^(SNRdB/10) );
D = BinaryUncodedModulation(4, BlockLength);

M = Encode(D);
SymbolLikelihood = ChannelUse(C, M);
[EstBits, EstSymbols] = Decode(D, SymbolLikelihood);
[NumBitError, NumSymbolError] = ErrorCount(D, SymbolLikelihood)

%%
SymbolProb = [0.2 0.2 0.3 0.3];
SNRdB = 5;
BlockLength = 10000;

MM = QPSK(SymbolProb);
C = AWGN( MM, 10^(SNRdB/10) );
D = BinaryUncodedModulation(4, BlockLength);

M = Encode(D);
SymbolLikelihood = ChannelUse(C, M);
[EstBits, EstSymbols] = Decode(D, SymbolLikelihood);
[NumBitError, NumSymbolError] = ErrorCount(D, SymbolLikelihood)