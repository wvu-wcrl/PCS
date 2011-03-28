MM = CreateModulation([-1 1]);
C = AWGN( MM, 20 );
D = UncodedModulation(2, 4);

M = D.Encode([0 0 1 1])
SymbolLikelihood = C.ChannelUse(M)
EstBits = D.Decode(SymbolLikelihood)

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
clc
SymbolProb = [0.2 0.2 0.3 0.3];
SignalSet = [-1 -1  1  1
             -1  1 -1  1];
SNRdB = 5;
BlockLength = 10;
         
MM = CreateModulation(SignalSet, SymbolProb);
C = AWGN( MM, 10^(SNRdB/10) );
D = UncodedModulation(4, 10*SymbolProb, BlockLength);

M = D.Encode()
DataBits = D.DataBits
SymbolLikelihood = C.ChannelUse(M);
[EstBits, EstSymbols] = D.Decode(SymbolLikelihood)
[NumBitError, NumSymbolError] = D.ErrorCount(SymbolLikelihood)

%%
clc
SymbolProb = [0.2 0.2 0.3 0.3];
SignalSet = [-1 -1  1  1
             -1  1 -1  1];
SNRdB = 5;
BlockLength = 10000;
         
MM = CreateModulation(SignalSet, SymbolProb);
C = AWGN( MM, 10^(SNRdB/10) );
D = UncodedModulation(4, 10*SymbolProb, BlockLength);

M = D.Encode();
hist(D.DataSymbols, [1:length(D.SymbolProb)]);
SymbolLikelihood = C.ChannelUse(M);
[EstBits, EstSymbols] = D.Decode(SymbolLikelihood);
[NumBitError, NumSymbolError] = D.ErrorCount(SymbolLikelihood)

%%
clc
SymbolProb = [0.2 0.2 0.3 0.3];
SignalSet = [-1 -1  1  1
             -1  1 -1  1];
SNRdB = 5;
BlockLength = 10;

MM = CreateModulation(SignalSet, SymbolProb);
C = AWGN( MM, 10^(SNRdB/10) );
D = BinaryUncodedModulation(4, BlockLength);

M = D.Encode()
DataBits = D.DataBits
SymbolLikelihood = C.ChannelUse(M);
[EstBits, EstSymbols] = D.Decode(SymbolLikelihood)
[NumBitError, NumSymbolError] = D.ErrorCount(SymbolLikelihood)

%%
SymbolProb = [0.2 0.2 0.3 0.3];
SignalSet = [-1 -1  1  1
             -1  1 -1  1];
SNRdB = 5;
BlockLength = 1000;

MM = CreateModulation(SignalSet, SymbolProb);
C = AWGN( MM, 10^(SNRdB/10) );
D = BinaryUncodedModulation(4, BlockLength);

M = D.Encode();
SymbolLikelihood = C.ChannelUse(M);
[EstBits, EstSymbols] = D.Decode(SymbolLikelihood);
[NumBitError, NumSymbolError] = D.ErrorCount(SymbolLikelihood)

%%
SymbolProb = [0.2 0.2 0.3 0.3];
SNRdB = 10;
BlockLength = 10000;

MM = QPSK(SymbolProb);
C = AWGN( MM, 10^(SNRdB/10) );
D = BinaryUncodedModulation(4, BlockLength);

M = D.Encode();
SymbolLikelihood = C.ChannelUse(M);
[EstBits, EstSymbols] = D.Decode(SymbolLikelihood);
[NumBitError, NumSymbolError] = D.ErrorCount(SymbolLikelihood)

%%
% Exact average symbol error probability for QAM.
% Distance is the same matrix generated in UnionBoundSymbol method of AWGN class.
DistanceA = Distance;
DistanceA(Distance == 0) = Inf;
D = min( min(DistanceA) )
Q1 = 0.5 * ( 1 - erf( sqrt(EsN0)*D / 2 ) );
QAM = 4*(1 - 1/sqrt(NoSignals)) * Q1 * (1 - (1 - 1/sqrt(NoSignals)) * Q1)

%%
SymbolProb = [0.2 0.2 0.3 0.3];
SignalSet = [-1 -1  1  1
             -1  1 -1  1];
SNRdB = 5;
BlockLength = 10000;

MM = CreateModulation(SignalSet, SymbolProb);
ChannelObj = AWGN( MM, 10^(SNRdB/10) );
CodedModObj = UncodedModulation(4, 10*SymbolProb, BlockLength);

SimParam = struct(...
            'CodedModObj', CodedModObj, ...    % Coded modulation object.
            'ChannelObj', ChannelObj, ...     % Channel object (Modulation is a property of channel).
            'SNRType', 'Es/N0 in dB', ...
            'SNR', [5:0.5:15], ...            % Row vector of SNR points in dB.
            'MaxTrials', 2000, ...      % A vector of integers (or scalar), one for each SNR point. Maximum number of trials to run per point.
            'FileName', 'BPSKAWGN.mat', ...
            'SimTime', 300, ...       % Simulation time in Seconds.
            'CheckPeriod', 500, ...    % Checking time in number of Trials.
            'MaxBitErrors', 5000*ones(size([0:0.5:10])), ...
            'MaxSymErrors', 5000*ones(size([0:0.5:10])), ...
            'minBER', 1e-5, ...
            'minSER', 1e-5 );
 
 Link = LinkSimulation(SimParam);
 Link.SingleSimulate();
 
 %%
 NoSignals = 16;
 SymbolProb = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
%  SymbolProb = [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4];
 MM = QAM(NoSignals, SymbolProb);
 SNRdB = -5:0.5:15;
 UpperSymbolBoundValue = LinkSimulation.UnionBoundSymbol( MM.SignalSet, 10.^(SNRdB/10), SymbolProb )
 
 % Exact average symbol error probability for QAM.

 % Distance is the same matrix generated in UnionBoundSymbol method of AWGN class.
Distance = AWGN.GetSignalDistance(MM.SignalSet);
DistanceA = Distance;
DistanceA(Distance == 0) = Inf;
D = min( min(DistanceA) );
QAM_ExactPs = zeros(1, length(SNRdB));
for m = 1:length(SNRdB)
Q1 = 0.5 * ( 1 - erf( sqrt(10.^(SNRdB(m)/10))*D / 2 ) );
QAM_ExactPs(m) = 4*(1 - 1/sqrt(NoSignals)) * Q1 * (1 - (1 - 1/sqrt(NoSignals)) * Q1);
end
QAM_ExactPs


BlockLength = 10240;

ChannelObj = AWGN( MM, 10^(SNRdB(1)/10) );
CodedModObj = UncodedModulation(16, 10*SymbolProb, BlockLength);

SimParam = struct(...
            'CodedModObj', CodedModObj, ...    % Coded modulation object.
            'ChannelObj', ChannelObj, ...     % Channel object (Modulation is a property of channel).
            'SNRType', 'Es/N0 in dB', ...
            'SNR', [-5:0.5:15], ...            % Row vector of SNR points in dB.
            'MaxTrials', 5000, ...      % A vector of integers (or scalar), one for each SNR point. Maximum number of trials to run per point.
            'FileName', 'BPSKAWGN.mat', ...
            'SimTime', 300, ...       % Simulation time in Seconds.
            'CheckPeriod', 50, ...    % Checking time in number of Trials.
            'MaxBitErrors', 5000*ones(size([-5:0.5:15])), ...
            'MaxSymErrors', 5000*ones(size([-5:0.5:15])), ...
            'minBER', 1e-6, ...
            'minSER', 1e-6 );
 
 Link = LinkSimulation(SimParam);
 Link.SingleSimulate();
 
 semilogy(SNRdB, UpperSymbolBoundValue, 'r', SNRdB, QAM_ExactPs, 'k', SNRdB, Link.SimState.BER)