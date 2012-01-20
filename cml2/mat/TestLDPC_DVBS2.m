function SimState = TestLDPC_DVBS2(DVBS2Param)
% This function uses LinkSimulation class to simulate the performance of an LDPC-DVBS2 channel code.
%
% DVBS2Param is a structure defining simulation parameters:
% DVBS2Param = struct(...
%     'EffectiveRate', 1/2,...
%     'FrameSize', 64800,...
%     'SNRType', 'Es/N0 in dB', ...
%     'SNR', [],...             % Row vector of SNR points in dB.
%     'MaxTrials', 18000, ...   % A vector of integers (or scalar), one for each SNR point. Maximum number of trials to run per point.
%     'MaxBitErrors', 5000*ones(size(SNR)), ...
%     'MaxFrameErrors', 1000*ones(size(SNR)), ...
%     'minBER', 1e-5, ...
%     'minFER', 1e-5, ...
%     'SimTime', 300, ...       % Simulation time in Seconds.
%     'MaxIteration', 30,...    % Maximum number of message passing decoding iterations for LDPC decoding (Default MaxIteration=30).
%     'DecoderType', 0,...      % Message passing LDPC decoding algorithm: =0 (sum-product) (DEFAULT), =1 (min-sum), =2 (approximate min-sum).
%     'ModulationObj', [],...
%     'DemodType', 0,...        % Type of max_star algorithm that is used in demaping.
%                               % =0 (linear approximation to log-MAP) (DEFAULT), =1 (max-log-MAP) (i.e. max*(x,y) = max(x,y)).
%                               % =2 (constant-log-MAP), =3 (log-MAP, correction factor from small nonuniform table and interpolation).
%                               % =4 (log-MAP, correction factor uses C function calls).
%     'ZeroRandFlag', 0,...     % A binary flag which is used when input vector to the encoder DataBits is not given to Encode method of CodedModulation class.
%                               % =0 generate a vector of ALL ZEROS (Default), =1 generate a RANDOM vector of bits.
%     );
%
% For NORMAL frames: EffectiveRate = 1/4, 1/3, 2/5, 1/2, 3/5, 2/3, 3/4, 4/5, 5/6, 8/9, 9/10.
% For SHORT  frames: EffectiveRate = 1/4, 1/3, 2/5, 1/2, 3/5, 2/3, 3/4, 4/5, 5/6, 8/9.
% FrameSize=64800 (NORMAL frames) (Default) or 16200 (SHORT frames).

% First, set the path.
OldPath = SetPath();

if( ~isfield(DVBS2Param, 'EffectiveRate') || isempty(DVBS2Param.EffectiveRate) ), DVBS2Param.EffectiveRate = 1/2; end
if( ~isfield(DVBS2Param, 'FrameSize') || isempty(DVBS2Param.FrameSize) ), DVBS2Param.FrameSize = 64800; end
if( ~isfield(DVBS2Param, 'SNRType') || isempty(DVBS2Param.SNRType) ), DVBS2Param.SNRType = 'Es/N0 in dB'; end
if( ~isfield(DVBS2Param, 'MaxTrials') || isempty(DVBS2Param.MaxTrials) ), DVBS2Param.MaxTrials = 18000; end
if( ~isfield(DVBS2Param, 'MaxBitErrors') || isempty(DVBS2Param.MaxBitErrors) ), DVBS2Param.MaxBitErrors = 5000*ones(size(DVBS2Param.SNR)); end
if( ~isfield(DVBS2Param, 'MaxFrameErrors') || isempty(DVBS2Param.MaxFrameErrors) ), DVBS2Param.MaxFrameErrors = 1000*ones(size(DVBS2Param.SNR)); end
if( ~isfield(DVBS2Param, 'minBER') || isempty(DVBS2Param.minBER) ), DVBS2Param.minBER = 1e-5; end
if( ~isfield(DVBS2Param, 'minFER') || isempty(DVBS2Param.minFER) ), DVBS2Param.minFER = 1e-5; end
if( ~isfield(DVBS2Param, 'SimTime') || isempty(DVBS2Param.SimTime) ), DVBS2Param.SimTime = 300; end
if( ~isfield(DVBS2Param, 'MaxIteration') || isempty(DVBS2Param.MaxIteration) ), DVBS2Param.MaxIteration = 30; end
if( ~isfield(DVBS2Param, 'DecoderType') || isempty(DVBS2Param.DecoderType) ), DVBS2Param.DecoderType = 0; end
if( ~isfield(DVBS2Param, 'ModulationObj') || isempty(DVBS2Param.ModulationObj) ), DVBS2Param.ModulationObj = BPSK(); end
if( ~isfield(DVBS2Param, 'DemodType') || isempty(DVBS2Param.DemodType) ), DVBS2Param.DemodType = 0; end
if( ~isfield(DVBS2Param, 'ZeroRandFlag') || isempty(DVBS2Param.ZeroRandFlag) ), DVBS2Param.ZeroRandFlag = 0; end

ModOrder = DVBS2Param.ModulationObj.Order;

if ischar(DVBS2Param.EffectiveRate)
    ChannelCodeObject = LDPCCode( DVBS2Param.EffectiveRate, [], DVBS2Param.MaxIteration, DVBS2Param.DecoderType );
else
    ChannelCodeObject = LDPC_DVBS2(DVBS2Param.EffectiveRate, DVBS2Param.FrameSize, DVBS2Param.MaxIteration, DVBS2Param.DecoderType);
end

CodedModObj = CodedModulation(ChannelCodeObject, ModOrder, DVBS2Param.DemodType, DVBS2Param.ZeroRandFlag);

SNRdB = 5;
ChannelObj = AWGN( DVBS2Param.ModulationObj, 10^(SNRdB/10) );

SimParam = struct(...
    'CodedModObj', CodedModObj, ...         % Coded modulation object.
    'ChannelObj', ChannelObj, ...           % Channel object (Modulation is a property of channel).
    'SNRType', DVBS2Param.SNRType, ...
    'SNR', DVBS2Param.SNR, ...              % Row vector of SNR points in dB.
    'MaxTrials', DVBS2Param.MaxTrials, ...  % A vector of integers (or scalar), one for each SNR point. Maximum number of trials to run per point.
    'SimTime', DVBS2Param.SimTime, ...      % Simulation time in Seconds.
    'CheckPeriod', 500, ...                 % Checking time in number of Trials.
    'MaxBitErrors', DVBS2Param.MaxBitErrors, ...
    'MaxFrameErrors', DVBS2Param.MaxFrameErrors, ...
    'minBER', DVBS2Param.minBER, ...
    'minFER', DVBS2Param.minFER );

Link = LinkSimulation(SimParam);
SimState = Link.SingleSimulate();

SimState.NumCodewords = Link.SimParam.CodedModObj.NumCodewords;
SimState.DataLength = Link.SimParam.CodedModObj.ChannelCodeObject.DataLength;

RemovePath(OldPath);

end


function OldPath = SetPath()
% Determine the home directory.
OldPath = path;
% Pos = regexp(OldPath,pathsep);
% HomeDir = OldPath(1:Pos(1)-1);
HomeDir = fullfile(filesep,'rhome','pcs','projects','cml2');

addpath( fullfile(HomeDir, 'mat') );

% This is the location of the mex directory for this architecture.
switch computer
    case 'PCWIN'	% MS Windows on x86.
        addpath( strcat( HomeDir, '\mex\pcwin') );
    case 'GLNX86'	% Linux on x86.
        addpath( strcat( HomeDir, '/mex/glnx86') );
    case 'MACI'     % Apple Mac OS X on x86.
        addpath( strcat( HomeDir, '/mex/maci') );
    case 'PCWIN64'	% Microsoft Windows on x64.
        addpath( strcat( HomeDir, '\mex\pcwin64') );
    case 'GLNXA64'	% Linux on x86_64.
        addpath( strcat( HomeDir, '/mex/glnxa64') );
    case 'SOL64'	% Sun Solaris on SPARC.
        addpath( strcat( HomeDir, '/mex/sol64') );
    case 'MACI64'	% Apple Mac OS X on x86_64.
        addpath( strcat( HomeDir, '/mex/maci64') );
end
end


function RemovePath(OldPath)
path(OldPath);
end