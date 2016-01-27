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

%% Testing LinkSimulation class with an LDPC-DVBS2 channel code in CML2 (ACT):
clear classes
cd('C:\Users\Mohammad\Desktop\CMLProject\ACT\mat');
% For NORMAL frames: EffectiveRate = 1/4, 1/3, 2/5, 1/2, 3/5, 2/3, 3/4, 4/5, 5/6, 8/9, 9/10.
% For SHORT  frames: EffectiveRate = 1/4, 1/3, 2/5, 1/2, 3/5, 2/3, 3/4, 4/5, 5/6, 8/9.
% FrameSize=64800 (NORMAL frames) (Default) or 16200 (SHORT frames) for DVBS2 standard.
EffectiveRate = 2/5;    % For short frames of DVBS2 standard, the actual rate of the LDPC code might be smaller.
FrameSize = 16200;  
% MaxIteration = 30;    % Maximum number of message passing decoding iteration (Default MaxIteration=30).
% DecoderType = 0;      % Message passing decoder type:
                        % 0 sum-product (DEFAULT), 1 min-sum, 2 approximate min-sum (NOT supported yet).
% ChannelCodeObject = LDPC_DVBS2(EffectiveRate, FrameSize, MaxIteration, DecoderType);
ChannelCodeObject = LDPC_DVBS2(EffectiveRate, FrameSize);
% [HRows, HCols] = InitializeDVBS2(EffectiveRate, FrameSize);
% ChannelCodeObject = LDPCCode( HRows, HCols, [], MaxIteration, DecoderType );

M = 2;
ModulationObj = BPSK();
% DemodType = 0;  % Type of max_star algorithm that is used.
                  % 0 For linear approximation to log-MAP (DEFAULT), 1 For max-log-MAP algorithm (i.e. max*(x,y) = max(x,y))
                  % 2 For Constant-log-MAP algorithm, 3 For log-MAP, correction factor from small nonuniform table and interpolation.
                  % 4 For log-MAP, correction factor uses C function calls.
% ZeroRandFlag = 0; % A binary flag which is used when input vector DataBits is not given to Encode method:
                    % 0 Generate a vector of ALL ZEROS for encoding (Default), 1 Generate a RANDOM vector of bits for encoding.
% CodedModObj = CodedModulation(ChannelCodeObject, M, DemodType, ZeroRandFlag);
CodedModObj = CodedModulation(ChannelCodeObject, M);

SNRdB = 5;
ChannelObj = AWGN( ModulationObj, 10^(SNRdB/10) );

% For normal frames of DVBS2 standars, K=FrameSize*EffectiveRate.
% Data = round(rand(1, FrameSize*EffectiveRate));
% Data = zeros(1, FrameSize*EffectiveRate);

% DataSymbols = CodedModObj.Encode(Data); % Encode and Map Data.

% SymbolLikelihood = ChannelObj.ChannelUse(DataSymbols); % Modulate, pass through channel, and demodulate.

% EstBits = CodedModObj.Decode(SymbolLikelihood); % Demap and Decode.

SNR = 0:0.5:10;

SimParam = struct(...
    'CodedModObj', CodedModObj, ...     % Coded modulation object.
    'ChannelObj', ChannelObj, ...       % Channel object (Modulation is a property of channel).
    'SNRType', 'Es/N0 in dB', ...
    'SNR', SNR, ...      % Row vector of SNR points in dB.
    'MaxTrials', 1e6, ...      % A vector of integers (or scalar), one for each SNR point. Maximum number of trials to run per point.
    'FileName', 'BPSK_LDPC_DVBS2.mat', ...
    'SimTime', 60, ...         % Simulation time in Seconds.
    'CheckPeriod', 10, ...     % Checking time in number of Trials.
    'MaxBitErrors', 5e6*ones(size(SNR)), ...
    'MaxFrameErrors', 80*ones(size(SNR)), ...
    'minBER', 1e-5, ...
    'minFER', 1e-5 );

Link = LinkSimulation(SimParam);
SimState = Link.SingleSimulate()

%% Testing CodedModTaskInit function as a UNIT TASK:
clear classes
ModulationObj = QPSK();
SNRdB = -5:0.5:5;
DVBS2Param = struct(...
    'EffectiveRate', 1/2,...
    'FrameSize', 64800,...
    'SNR', SNRdB,...          % Row vector of SNR points in dB.
    'MaxIteration', 30,...    % Maximum number of message passing decoding iterations for LDPC decoding (Default MaxIteration=30).
    'DecoderType', 0,...      % Message passing LDPC decoding algorithm: =0 (sum-product) (DEFAULT), =1 (min-sum), =2 (approximate min-sum).
    'ModulationObj', ModulationObj,...
    'DemodType', 0,...        % Type of max_star algorithm that is used in demaping.
    'ZeroRandFlag', 0,...     % A binary flag which is used when input vector to the encoder DataBits is not given to Encode method of CodedModulation class.
    'OutputFileName', 'QPSK_DVBS2.mat');

TaskUnit = struct(...
    'FunctionName', 'CodedModTaskInit',...
    'FunctionPath', 'C:\Users\Mohammad\Desktop\CMLProject\ACT\mat',...
    'InputParam', DVBS2Param);

OutputFileName = 'DVBS2_LDPC_1by2L_QPSK.mat';
cd(TaskUnit.FunctionPath);
SimState = feval( TaskUnit.FunctionName, TaskUnit.InputParam );
save(OutputFileName, 'SimState');

%% Testing CodedModTaskInit function as a UNIT TASK:
clear classes
ModulationObj = QPSK();
SNRdB = -3:0.5:3;
CodedModParam = struct(...
    'CodeType', 3,...        % Type of the channel code used.
    ...                       % =1 (DVBS2 LDPC code), =2 (WiMax LDPC code).
    ...                       % =3 (General LDPC code specified by its parity-check matrix in alist format saved in a file).
    'AListFilePath', 'C:\Users\Mohammad\Desktop\CMLProject\ACT\DataFiles\EdwardRatzerCodeA.txt',...   
    ...                       % FULL path to alist file containing the parity-check matrix of LDPC code.
    'EffectiveRate', 1/2,...  % Effective rate of LDPC code for DVBS2 and WiMax standards.
    'FrameSize', 64800,...    % Size of the code (number of code bits).
    'WiMaxLDPCInd', [],...    % Selects either code ’A’ or code ’B’ for rates 2/3 and 3/4 of WiMax LDPC codes.
    ...                       % =0 (code rate type ’A’), =1 (code rate type ’B’), =[empty array] (all other code rates).
    'SNRType', 'Eb/N0 in dB', ...
    'SNR', SNRdB,...          % Row vector of SNR points in dB.
    'MaxTrials', 1e9, ...     % A vector of integers (or scalar), one for each SNR point. Maximum number of trials to run per point.
    'MaxBitErrors', 5e10*ones(size(SNRdB)), ...
    'MaxFrameErrors', 100*ones(size(SNRdB)), ...
    'minBER', 1e-5, ...
    'minFER', 1e-5, ...
    'SimTime', 30, ...        % Simulation time in Seconds.
    'MaxIteration', 50,...    % Maximum number of message passing decoding iterations for LDPC decoding (Default MaxIteration=30).
    'DecoderType', 0,...      % Message passing LDPC decoding algorithm: =0 (sum-product) (DEFAULT), =1 (min-sum), =2 (approximate min-sum).
    'ModulationObj', ModulationObj,...
    'DemodType', 0,...        % Type of max_star algorithm that is used in demaping.
    ...                       % =0 (linear approximation to log-MAP) (DEFAULT), =1 (max-log-MAP) (i.e. max*(x,y) = max(x,y)).
    ...                       % =2 (constant-log-MAP), =3 (log-MAP, correction factor from small nonuniform table and interpolation).
    ...                       % =4 (log-MAP, correction factor uses C function calls).
    'ZeroRandFlag', 0);       % A binary flag which is used when input vector to the encoder DataBits is not given to Encode method of CodedModulation class.
                              % =0 generate a vector of ALL ZEROS (Default), =1 generate a RANDOM vector of bits.

SimState = CodedModTaskInit(CodedModParam)


%% Testing CodedModJobManager: Job Definition.
clear classes

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
    'SimTime', 30, ...                     % Simulation time in Seconds.
    'CheckPeriod', 5, ...                 % Checking time in number of Trials.
    'MaxBitErrors', 5000*ones(size(SNRdB)), ...
    'MaxFrameErrors', 1000*ones(size(SNRdB)), ...
    'minBER', 1e-5, ...
    'minFER', 1e-5 );
% Link = LinkSimulation(SimParam);
% SimStateT = Link.SingleSimulate();

ZR = zeros(MaxIteration,length(SNRdB));
SimState = struct(...
    'BitErrors', ZR, ...
    'FrameErrors', ZR, ...
    'Trials', ZR(1,:), ...
    'BER', ZR, ...
    'FER', ZR );

mfanaeiJobDir = 'C:\Users\Mohammad\Desktop\CMLProject\ACT\TestJobManager\mfanaei\Projects\CodedMod\JobIn';
save( fullfile(mfanaeiJobDir, 'FanaeiJob1.mat'), 'SimParam', 'SimState');

% tFerrettJobDir = 'C:\Users\Mohammad\Desktop\CMLProject\ACT\TestJobManager\tferrett\Projects\CodedMod\JobIn';
% save( fullfile(tFerrettJobDir, 'FerrettJob1.mat'), 'SimParam', 'SimState');

%% Plotting Trials vs. Time Figure for Cluster Performance Assessment:

% close all
clear classes

FileContent = load('FanaeiJob28_01_F_eTimeTrial.mat');
Job_eTimeTrial = FileContent.eTimeTrial;
% Job_eTimeTrial(:,all(all(Job_eTimeTrial==0,1),3),:) = [];

TimeTrialNode1 = Job_eTimeTrial(:,:,1);
TimeTrialNode1(:,all(TimeTrialNode1==0,1),:) = [];
TimeTrialNode2 = Job_eTimeTrial(:,:,6);
TimeTrialNode2(:,all(TimeTrialNode2==0,1),:) = [];

ClusterTrialsumNode1 = cumsum(TimeTrialNode1(3,:),2);
ClusterTrialsumNode2 = cumsum(TimeTrialNode2(3,:),2);

NodeNum = size(Job_eTimeTrial,3);
TimeVec = [];
for Node=1:NodeNum
    TimeVec = unique([TimeVec Job_eTimeTrial(1,:,Node)]);
end

Trials = zeros(NodeNum,length(TimeVec));
for VecPos=2:length(TimeVec)
    for Node = 1:NodeNum
        TrialValue = Job_eTimeTrial(3, (Job_eTimeTrial(1,:,Node)>TimeVec(VecPos-1) & Job_eTimeTrial(1,:,Node)<=TimeVec(VecPos)) ,Node);
        if ~isempty(TrialValue)
            Trials(Node,VecPos) = TrialValue;
        end
    end
end

TrialsSum = cumsum(Trials,2);
TrialsCluster = sum(TrialsSum,1);

NoPCTrial = 5;
PCContent = load('UniAwgn_4PAMv55Cluster.mat');
% PCContent = load('UniAwgn_4PAMv61_PC.mat');
PC_Time = PCContent.elapsed_time;
PC_Trial = PCContent.block_array;
PC_Tsum = cumsum(PC_Time(1:NoPCTrial),2);
PC_Trialsum = cumsum(PC_Trial(1:NoPCTrial),2);

% TimeVec = 0:0.1:max(max(ClusterTTsumNode1(1,:),ClusterTTsumNode2(1,:)));
% Trial1 = interp1(ClusterTTsumNode1(1,:),ClusterTTsumNode1(2,:),TimeVec,'spline');
% Trial2 = interp1(ClusterTTsumNode2(1,:),ClusterTTsumNode2(2,:),TimeVec,'spline');
% Trial12 = Trial1+Trial2;

figure
% plot(TimeVec,Trial12,':b', PC_Tsum,PC_Trialsum,'-.k', ClusterTTsumNode1(1,:),ClusterTTsumNode1(2,:),'b', ...
%     ClusterTTsumNode2(1,:),ClusterTTsumNode2(2,:),'--r', 'Linewidth', 2)
stairs(TimeVec,TrialsCluster,':k', 'Linewidth', 2), hold on, box on
stairs(TimeTrialNode2(1,:),ClusterTrialsumNode2,'-.r', 'Linewidth', 2)
stairs(TimeTrialNode1(1,:),ClusterTrialsumNode1,':b', 'Linewidth', 2)
stairs([0 PC_Tsum],[0 PC_Trialsum],'m', 'Linewidth', 2)
set(gca,'FontSize',12,'FontName','Times New Roman')
xlabel('Time (Seconds)','FontSize',12,'FontName','Times New Roman'), ylabel('Trials Completed','FontSize',12,'FontName','Times New Roman')
xlim([0, 1000])
% axis([ xa xb ya yb])
Legend = legend('Cluster with 15 Nodes/216 Cores','1 Fast Node (24 Cores Effective) on Cluster','1 Slow Node (8 Cores) on Cluster', 'PC');
set(Legend,'FontSize',12,'FontName','Times New Roman');
gtext({'Fast Node Specifications (6 Nodes)','12-core Xeon X5660 processors @ 2.80 GHz with hyper-threading', '24 cores effective with 24 GB memory'...
    '144 cores subtotal with 144 GB memory'},'FontSize',12,'FontName','Times New Roman')
gtext({'Slow Node Specifications (9 Nodes)','8-core Xeon L5410 processors @ 2.33 GHz with 8 GB memory', '72 cores subtotal with 72 GB memory'},'FontSize',12,'FontName','Times New Roman')
gtext({'PC Specifications','2 quad-core Intel Q9550 processors @ 2.83 GHz', '3.25 GB memory'},'FontSize',12,'FontName','Times New Roman')


%% Testing Lines of LinkSimulation and CodedModulation Classes:
clear classes

cd( 'C:\Users\Mohammad\Desktop\CMLProject\ACT\mat' );

ModulationObj = QPSK();
ModOrder = ModulationObj.Order;

EffectiveRate = 1/2;
FrameSize = 64800;
MaxIteration = 30;
DecoderType = 0;
ChannelCodeObject = LDPC_DVBS2(EffectiveRate, FrameSize, MaxIteration, DecoderType);

DemodType = 0;
ZeroRandFlag = 1;
CodedModObj = CodedModulation(ChannelCodeObject, ModOrder, DemodType, ZeroRandFlag);

SNRdB = 5;
ChannelObj = AWGN( ModulationObj, 10^(SNRdB/10) );

clear ModulationObj ChannelCodeObject ModOrder EffectiveRate FrameSize MaxIteration DecoderType DemodType ZeroRandFlag

SNRdB = 2;
EbN0 = 10.^(SNRdB/10);
EsN0 = EbN0 * CodedModObj.ChannelCodeObject.Rate;
Variance = 1/(2*EsN0);

DataSymbols = CodedModObj.Encode(); % DataSymbols is of type int32.
% keyboard

% SymbolLikelihood = ChannelObj.ChannelUse(DataSymbols, EsN0);
% SymbolLikelihoodCast = ChannelObj.ChannelUse(cast(DataSymbols,'double'), EsN0);

ModulatedSignal = ChannelObj.Modulate(DataSymbols);
ModulatedSignalCast = ChannelObj.Modulate(cast(DataSymbols,'double'));
% keyboard

Noise = sqrt(Variance) * randn(size(ChannelObj.ModulationObj.SignalSet,1) , size(ModulatedSignal,2));
RecievedSignal = Noise + ModulatedSignal;
RecievedSignalCast = Noise + ModulatedSignalCast;
clear Noise
% keyboard

SymbolLikelihood = ChannelObj.Demodulate(RecievedSignal);
SymbolLikelihoodCast = ChannelObj.Demodulate(RecievedSignalCast);
% keyboard



% Extrinsic information is considered to be all zero (DEFAULT).
ExtrinsicInfo = zeros( 1, size(SymbolLikelihood,2)*log2(size(SymbolLikelihood,1)) );

BitLikelihood = CodedModObj.Mapper.Demap( SymbolLikelihood, ExtrinsicInfo );
% Find EstBits which includes padded bits and codeword bits affected by them.
% keyboard

[EstBits, NumBitError] = MpDecode( -cast(BitLikelihood,'double'), ...
    CodedModObj.ChannelCodeObject.HRows, ...
    CodedModObj.ChannelCodeObject.HCols, ...
    CodedModObj.ChannelCodeObject.MaxIteration, ...
    CodedModObj.ChannelCodeObject.DecoderType, 1, 1, CodedModObj.ChannelCodeObject.DataBits );
% Assume that the code is systematic.
NumCodewordError = (NumBitError>0);



% [NumBitError, NumCodewordError] = CodedModObj.ErrorCount(SymbolLikelihood);
% [NumBitErrorCast, NumCodewordErrorCast] = CodedModObj.ErrorCount(SymbolLikelihoodCast);

% fprintf('Without Cast\n');
% NumBitError'
% NumCodewordError'

% fprintf('\nWith Cast\n');
% NumBitErrorCast'
% NumCodewordErrorCast'