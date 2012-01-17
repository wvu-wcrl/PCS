%% Testing BinaryUncodedModulation class:
clear all
MM = CreateModulation([-1 1]);
C = AWGN( MM, 20 );
D = BinaryUncodedModulation(2, 4);

M = D.Encode([0 0 1 1])
SymbolLikelihood = C.ChannelUse(M)
EstBits = D.Decode(SymbolLikelihood)

%% Testing the speed of randp vs gDiscrPdfRnd functions for small blocks:
clear all
K = 2000; N = 10;
T_RandP = zeros(K,1);
T_gDiscrPdfRnd = zeros(K,1);
for m=1:K
    tic; R = randp([1 3 2],N,1); T_RandP(m) = toc;
    tic; R = gDiscrPdfRnd([1 3 2],N,1); T_gDiscrPdfRnd(m) = toc;
end
T_RandP_Avg = mean(T_RandP)
T_gDiscrPdfRnd_Avg = mean(T_gDiscrPdfRnd)

%% Testing the speed of randp vs MATLAB's built-in rand functions for large blocks:
clear all
K = 20; N = 100000;
T_RandP = zeros(K,1);
T_Rand = zeros(K,1);
for m=1:K
    tic; R = randp([1 1],N,1); T_RandP(m) = toc;
    tic; R = (rand(N,1)>0.5); T_Rand(m) = toc;
end
T_RandP_Avg = mean(T_RandP)
T_Rand_Avg = mean(T_Rand)

%% Testing UncodedModulation class for a small block:
clear all
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

%% Testing UncodedModulation class for a large block and finding the error rate:
clear all
clc
SymbolProb = [0.2 0.2 0.3 0.3];
SignalSet = [-1 -1  1  1
    -1  1 -1  1];
SNRdB = 5;
BlockLength = 10000;

MM = CreateModulation(SignalSet, SymbolProb);
C = AWGN( MM, 10^(SNRdB/10) );
D = UncodedModulation(4, 10*SymbolProb, BlockLength);
hist(D.DataSymbols, [1:length(D.SymbolProb)]);

M = D.Encode();
SymbolLikelihood = C.ChannelUse(M);
[EstBits, EstSymbols] = D.Decode(SymbolLikelihood);
[NumBitError, NumSymbolError] = D.ErrorCount(SymbolLikelihood)

%% Testing BinaryUncodedModulation class for a small block:
clear all
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

%% Testing BinaryUncodedModulation class for a large block and finding the error rate:
clear all
clc
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

%% Testing BinaryUncodedModulation class with QPSK class for a large block and finding the error rate:
clear all
clc
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

%% Testing LinkSimulation class:
clear all
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

%% Comparing union bound on SER with exact average SER and simulated SER for 16-QAM.
clear all
NoSignals = 16;
SymbolProb = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
%  SymbolProb = [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4];
MM = QAM(NoSignals, SymbolProb);
SNRdB = -5:0.5:25;
UpperSymbolBoundValue = LinkSimulation.UnionBoundSymbol( MM.SignalSet, 10.^(SNRdB/10), SymbolProb/sum(SymbolProb) )

%%% Exact average symbol error probability for QAM.
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
    'SNR', [-5:0.5:25], ...            % Row vector of SNR points in dB.
    'MaxTrials', 10000, ...      % A vector of integers (or scalar), one for each SNR point. Maximum number of trials to run per point.
    'FileName', 'BPSKAWGN.mat', ...
    'SimTime', 300, ...       % Simulation time in Seconds.
    'CheckPeriod', 50, ...    % Checking time in number of Trials.
    'MaxBitErrors', 10000*ones(size([-5:0.5:25])), ...
    'MaxSymErrors', 10000*ones(size([-5:0.5:25])), ...
    'minBER', 1e-6, ...
    'minSER', 1e-6 );

Link = LinkSimulation(SimParam);
Link.SingleSimulate();

semilogy(SNRdB, UpperSymbolBoundValue, 'r', SNRdB, QAM_ExactPs, '--k', SNRdB, Link.SimState.SER, '-.')

%% Testing InversePsUB and InversePbUB functions for 16-QAM:
clear all
NoSignals = 16;
MM = QAM(NoSignals);
SNRdB = -5:0.5:35;
EsN0 = 10.^(SNRdB/10);
Ps = PsUB( MM.SignalSet, EsN0 );

maxPs = 1e-6;
[minEsN0dB1, minEsN01] = InversePsUB( MM.SignalSet, maxPs )
[minEsN0dB2, minEsN02] = InversePbUB( MM.SignalSet, maxPs )


%  SNRFirst = -10;
%  SNRLast = 10;
%  Ind = [];
%  while(isempty(Ind))
%  Ind = find( PsUB( MM.SignalSet, 10.^(SNRFirst:SNRLast/10)) - maxPs < 0, 1, 'first');
%  SNRFirst = 2*SNRFirst;
%  SNRLast = 2*SNRLast;
%  end
%  [SNR_Goal, P, Flag] = fzero(Ps, 10^(SNRdB(Ind)/10), optimset('Display','iter'))

%% Testing LinkSimulation class with an LDPC-DVBS2 channel code:
clear classes

% For NORMAL frames: EffectiveRate = 1/4, 1/3, 2/5, 1/2, 3/5, 2/3, 3/4, 4/5, 5/6, 8/9, 9/10.
% For SHORT  frames: EffectiveRate = 1/4, 1/3, 2/5, 1/2, 3/5, 2/3, 3/4, 4/5, 5/6, 8/9.
% FrameSize=64800 (NORMAL frames) (Default) or 16200 (SHORT frames).
EffectiveRate = 2/5;
FrameSize = 16200;
% MaxIteration = 30;
% DecoderType = 0;
% ChannelCodeObject = LDPC_DVBS2(EffectiveRate, FrameSize, MaxIteration, DecoderType);
ChannelCodeObject = LDPC_DVBS2(EffectiveRate, FrameSize);

M = 2;
ModulationObj = BPSK();
% DemodType = 0;
% ZeroRandFlag = 0;
% CodedModObj = CodedModulation(ChannelCodeObject, M, DemodType, ZeroRandFlag);
CodedModObj = CodedModulation(ChannelCodeObject, M);

SNRdB = 5;
ChannelObj = AWGN( ModulationObj, 10^(SNRdB/10) );

SNR = 0:0.5:10;

SimParam = struct(...
    'CodedModObj', CodedModObj, ...     % Coded modulation object.
    'ChannelObj', ChannelObj, ...       % Channel object (Modulation is a property of channel).
    'SNRType', 'Es/N0 in dB', ...
    'SNR', SNR, ...      % Row vector of SNR points in dB.
    'MaxTrials', 2000, ...      % A vector of integers (or scalar), one for each SNR point. Maximum number of trials to run per point.
    'FileName', 'BPSK_LDPC_DVBS2.mat', ...
    'SimTime', 300, ...         % Simulation time in Seconds.
    'CheckPeriod', 500, ...     % Checking time in number of Trials.
    'MaxBitErrors', 5000*ones(size(SNR)), ...
    'MaxFrameErrors', 5000*ones(size(SNR)), ...
    'minBER', 1e-5, ...
    'minFER', 1e-5 );

Link = LinkSimulation(SimParam);
Link.SingleSimulate();

%% Testing TestLDPC_DVBS2 function as a UNIT TASK:
clear classes

SNRdB = -5:0.5:5;
DVBS2Param = struct(...
    'EffectiveRate', 1/2,...
    'FrameSize', 64800,...
    'SNR', SNRdB,...             % Row vector of SNR points in dB.
    'MaxIteration', 30,...    % Maximum number of message passing decoding iterations for LDPC decoding (Default MaxIteration=30).
    'DecoderType', 0,...      % Message passing LDPC decoding algorithm: =0 (sum-product) (DEFAULT), =1 (min-sum), =2 (approximate min-sum).
    'ModulationObj', QPSK(),...
    'DemodType', 0,...        % Type of max_star algorithm that is used in demaping.
    'ZeroRandFlag', 0,...     % A binary flag which is used when input vector to the encoder DataBits is not given to Encode method of CodedModulation class.
    'OutputFileName', 'QPSK_DVBS2.mat');

TaskUnit = struct(...
    'FunctionName', 'TestLDPC_DVBS2',...
    'FunctionPath', 'C:\Users\Mohammad\Desktop\CMLProject\ACT\mat',...
    'InputParam', DVBS2Param);

cd(TaskUnit.FunctionPath);
SimState = feval( TaskUnit.FunctionName, TaskUnit.InputParam );
save(TaskUnit.OutputFileName, 'SimState');

%% Testing CodedModJobManager: Job Definition.

% User 1 Data

ModulationObj = QPSK();
ModOrder = ModulationObj.Order;

EffectiveRate = 1/2;
FrameSize = 64800;
MaxIteration = 30;
DecoderType = 0;
ChannelCodeObject = LDPC_DVBS2(EffectiveRate, FrameSize, MaxIteration, DecoderType);

DemodType = 0;
ZeroRandFlag = 0;
CodedModObj = CodedModulation(ChannelCodeObject, ModOrder, DemodType, ZeroRandFlag);

SNRdB = 5;
ChannelObj = AWGN( ModulationObj, 10^(SNRdB/10) );

SNRdB = -5:0.5:5;
SimParam = struct(...
    'CodedModObj', CodedModObj, ...         % Coded modulation object.
    'ChannelObj', ChannelObj, ...           % Channel object (Modulation is a property of channel).
    'SNRType', 'Es/N0 in dB', ...
    'SNR', SNRdB, ...                       % Row vector of SNR points in dB.
    'MaxTrials', 18000, ...                 % A vector of integers (or scalar), one for each SNR point. Maximum number of trials to run per point.
    'SimTime', 240, ...                     % Simulation time in Seconds.
    'CheckPeriod', 500, ...                 % Checking time in number of Trials.
    'MaxBitErrors', 5000*ones(size(SNRdB)), ...
    'MaxFrameErrors', 1000*ones(size(SNRdB)), ...
    'minBER', 1e-5, ...
    'minFER', 1e-5 );

ZR = zeros(size(SNRdB));
SimState = struct(...
    'BitErrors', ZR, ...
    'FrameErrors', ZR, ...
    'Trials', ZR, ...
    'BER', ZR, ...
    'FER', ZR );

mfanaeiJobDir = 'C:\Users\Mohammad\Desktop\CMLProject\ACT\TestJobManager\mfanaei\Projects\CodedMod\JobIn';
save( fullfile(mfanaeiJobDir, 'FanaeiJob1.mat'), 'SimParam', 'SimState');

% User 2 Data

ModulationObj = QPSK();
ModOrder = ModulationObj.Order;

EffectiveRate = 1/2;
FrameSize = 64800;
MaxIteration = 30;
DecoderType = 0;
ChannelCodeObject = LDPC_DVBS2(EffectiveRate, FrameSize, MaxIteration, DecoderType);

DemodType = 0;
ZeroRandFlag = 0;
CodedModObj = CodedModulation(ChannelCodeObject, ModOrder, DemodType, ZeroRandFlag);

SNRdB = 5;
ChannelObj = AWGN( ModulationObj, 10^(SNRdB/10) );

SNRdB = -5:0.5:5;
SimParam = struct(...
    'CodedModObj', CodedModObj, ...         % Coded modulation object.
    'ChannelObj', ChannelObj, ...           % Channel object (Modulation is a property of channel).
    'SNRType', 'Es/N0 in dB', ...
    'SNR', SNRdB, ...                       % Row vector of SNR points in dB.
    'MaxTrials', 18000, ...                 % A vector of integers (or scalar), one for each SNR point. Maximum number of trials to run per point.
    'SimTime', 240, ...                     % Simulation time in Seconds.
    'CheckPeriod', 500, ...                 % Checking time in number of Trials.
    'MaxBitErrors', 5000*ones(size(SNRdB)), ...
    'MaxFrameErrors', 1000*ones(size(SNRdB)), ...
    'minBER', 1e-5, ...
    'minFER', 1e-5 );

ZR = zeros(size(SNRdB));
SimState = struct(...
    'BitErrors', ZR, ...
    'FrameErrors', ZR, ...
    'Trials', ZR, ...
    'BER', ZR, ...
    'FER', ZR );

mfanaeiJobDir = 'C:\Users\Mohammad\Desktop\CMLProject\ACT\TestJobManager\tferrett\Projects\CodedMod\JobIn';
save( fullfile(mfanaeiJobDir, 'FanaeiJob1.mat'), 'SimParam', 'SimState');