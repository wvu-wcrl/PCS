function [EpsilonStarDE, CodeRate, FullRank] = GenerateJob(HStruct, JobFileName, Epsilon_JobParam)
% GenerateJob generates a .mat file called 'JobFileName' that contains two structures called JobParam and JobState based on its inputs.
% The generated .mat file is suitable for being uploaded to WCRL web interface to complete the Monte-Carlo simulation of an LDPC code over binary
% erasure channel for EE567 course project at WVU.
%
% Calling syntax: [EpsilonStarDE, CodeRate, FullRank] = GenerateJob(HStruct [,JobFileName] [,Epsilon_JobParam])
%
% Inputs
%       HStruct         A structure array corresponding to the parity-check matrix.
%                       H(j).loc_ones gives the location of ones in the jth row of H matrix.
%       JobFileName     (OPTIONAL) Name of the .mat job file that the user wants this function to generate.
%       Epsilon_JobParam    This OPTIONAL input can be either a vector or a structure.
%                           If it is a VECTOR, it specifies the vector of Epsilon points (channel erasure probabilities).
%                           If it is a STRUCTURE, it specifies the JobParam structure with the following fields:
%                           Epsilon,MaxTrials,MaxFrameErrors,MaxIteration,MaxRunTime. All of these fields are OPTIONAL.
%
% Outputs
%       EpsilonStarDE   Theoretical maximum channel erasure probability for the given parity-check matrix based on Density Evolution.
%       CodeRate
%       FullRank        A flag which is either YES or NO depending on whether the parity-check matrix is full-rank or not.

HStructInfo = FindHInfo(HStruct);

EpsilonStarDE = HStructInfo.EpsilonStarDE;
CodeRate = HStructInfo.CodeRate;
fprintf('\nThe maximum channel erasure probability for your given parity-check matrix is EpsilonStar = %.8f.\n\n',EpsilonStarDE);
fprintf('The rate of your given LDPC code is CodeRate = %.4f.\n\n',CodeRate);
if HStructInfo.FullRankFlag == 1
    fprintf('Your given parity-check matrix IS FULL-RANK! The simulation can be continued.\n\n');
    FullRank = 'Yes';
else
    fprintf('Your given parity-check matrix IS NOT FULL-RANK! The simulation should be terminated.\nYou have to specify another FULL-RANK H matrix.\n');
    FullRank = 'NO';
    return;
end

if( nargin<2 || isempty(JobFileName) )
    JobFileName = ['LDPC_BEC_Ver' num2str(round(1000*rand)) '_' datestr(clock,'mmmdd_HHMM') '.mat'];
end

if( nargin<3 || isempty(Epsilon_JobParam) )
    % EpsilonResolution = 0.001;
    % Epsilon = 0.5*HStructInfo.EpsilonStarDE : EpsilonResolution : 1.5*HStructInfo.EpsilonStarDE;
    Epsilon = 0.1:0.002:0.25;
    JobParamFlag = 1; % We need to generate the JobParam structure.

elseif( isstruct(Epsilon_JobParam) )% JobParam is specified in Epsilon_JobParam as a STRUCTURE.
    JobParam = Epsilon_JobParam;
    JobParam.HStruct = HStruct;
    JobParam.HStructInfo = HStructInfo;
    if( ~isfield(JobParam, 'Epsilon') || isempty(JobParam.Epsilon) ), JobParam.Epsilon = 0.1:0.002:0.25; end
    if( ~isfield(JobParam, 'MaxTrials') || isempty(JobParam.MaxTrials) ), JobParam.MaxTrials = 0.25e5; end
    if( ~isfield(JobParam, 'MaxFrameErrors') || isempty(JobParam.MaxFrameErrors) ), JobParam.MaxFrameErrors = 1e3; end
    if( ~isfield(JobParam, 'MaxIteration') || isempty(JobParam.MaxIteration) ), JobParam.MaxIteration = 100; end
    if( ~isfield(JobParam, 'MaxRunTime') || isempty(JobParam.MaxRunTime) ), JobParam.MaxRunTime = 300; end
    if( ~isfield(JobParam, 'MaxBitErrors') || isempty(JobParam.MaxBitErrors) ), JobParam.MaxBitErrors = 0; end
    if( ~isfield(JobParam, 'CheckPeriod') || isempty(JobParam.CheckPeriod) ), JobParam.CheckPeriod = 200; end
    JobParamFlag = 0; % We do NOT need to generate the JobParam structure.

elseif( isvector(Epsilon_JobParam) )% Epsilon is specified in Epsilon_JobParam as a VECTOR.
    Epsilon = Epsilon_JobParam;
    JobParamFlag = 1; % We need to generate the JobParam structure.
else
    error(['GenerateJob:InvalidInput','The OPTIONAL THIRD input to the function could either be ',...
        'a VECTOR containing EPSILON points or a STRUCTURE containing JobParam.']);
end

if JobParamFlag == 1
    JobParam = struct(...
        'Epsilon', Epsilon, ...     % Row vector of channel erasure probabilities. ([0.10:0.002:0.25])
        'MaxTrials', 0.25e5, ...    % Max number of trials to run per point. A vector of integers (or a scalar), one for each Epsilon point. (0.25e5)
        'MaxFrameErrors', 1e3, ...	% Max number of frame errors. A vector of integers (or a scalar), one for each Epsilon point.
        'MaxIteration', 100, ...	% Max number of decoding iterations.
        'HStruct', HStruct, ...     % A structure array corresponding to the parity-check matrix.
        ...                         % H(j).loc_ones gives the location of ones in the jth row of H matrix.
        'HStructInfo', HStructInfo, ...
        'MaxRunTime', 300, ...      % Maximum simulation time in Seconds.
        'MaxBitErrors', 0, ...
        'CheckPeriod', 200 );       % Checking time in number of Trials.
end

ZR = zeros(JobParam.MaxIteration,length(JobParam.Epsilon));
JobState = struct(...
    'BitErrors', ZR, ...
    'FrameErrors', ZR, ...
    'Trials', ZR(1,:), ...
    'BER', ZR, ...
    'FER', ZR );

save(JobFileName,'JobParam','JobState');

end

function HStructInfo = FindHInfo(HStruct)
CodewordLength = max([HStruct(:).loc_ones]);
DataLength = CodewordLength - length(HStruct);
[EpsilonThresholdStar, FullRank, CodeRate] = HstructEval( HStruct );
HStructInfo = struct( ...
    'DataLength', DataLength, ...
    'CodewordLength', CodewordLength, ...
    'CodeRate', CodeRate, ...
    'FullRankFlag', FullRank, ...
    'EpsilonStarDE', EpsilonThresholdStar );
end