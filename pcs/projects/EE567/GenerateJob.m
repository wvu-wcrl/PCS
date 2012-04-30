function [EpsilonStarDE, CodeRate, FullRank] = GenerateJob(InFullFilePath, Epsilon, JobName)
% GenerateJob generates a .mat file called JobName that contains two structures called JobParam and JobState based on the contents of the input file
% InFullFilePath.
% The generated .mat file is suitable for being uploaded to the web interface to complete the Monte-Carlo simulation of an LDPC code over binary
% erasure channel for EE567 course project at WVU.
%
% Calling syntax: GenerateJob(InFullFilePath [,Epsilon] [,JobName])
%
% InFullFilePath is the FULL (RELATIVE or ABSOLUTE) path to the file containing either JobParam (and possibly JobState) structure
% or HStruct associated with the H matrix. It must be a string (enclosed in single quotes).

if( nargin<3 || isempty(JobName) )
    JobName = ['LDPC_BEC_Ver' num2str(round(1000*rand)) '_' datestr(clock,'mmmdd_HHMM') '.mat'];
end

FileContent = load(InFullFilePath);
if isfield(FileContent, 'JobParam') % JobParam is specified.
    JobParam = FileContent.JobParam;
    if( ~isfield(JobParam, 'HStructInfo') || isempty(JobParam.HStructInfo) )
        HStructInfo = FindHInfo(JobParam.HStruct);
        JobParam.HStructInfo = HStructInfo;
    end
    if( ~isfield(JobParam, 'MaxTrials') || isempty(JobParam.MaxTrials) ), JobParam.MaxTrials = 0.25e5; end
    if( ~isfield(JobParam, 'MaxFrameErrors') || isempty(JobParam.MaxFrameErrors) ), JobParam.MaxFrameErrors = 1e3; end
    if( ~isfield(JobParam, 'MaxIteration') || isempty(JobParam.MaxIteration) ), JobParam.MaxIteration = 100; end
    if ~isfield(FileContent, 'JobState') % Jobstate is not specified.
        ZR = zeros(JobParam.MaxIteration,length(JobParam.Epsilon));
        JobState = struct(...
            'BitErrors', ZR, ...
            'FrameErrors', ZR, ...
            'Trials', ZR(1,:), ...
            'BER', ZR, ...
            'FER', ZR );
    else % Jobstate is specified.
        JobState = FileContent.JobState;
    end
elseif( isfield(FileContent, 'HStruct') || isfield(FileContent, 'H_Struct') || isfield(FileContent, 'H_struct') )
    % HStruct is specified. JobParam and Jobstate are generated.
    if isfield(FileContent, 'HStruct')
        HStruct = FileContent.HStruct;
    elseif isfield(FileContent, 'H_Struct')
        HStruct = FileContent.H_Struct;
    elseif isfield(FileContent, 'H_struct')
        HStruct = FileContent.H_struct;
    end
    HStructInfo = FindHInfo(HStruct);

    EpsilonResolution = 0.001;
    if( nargin<2 || isempty(Epsilon) )
        % Epsilon = 0.5*HStructInfo.EpsilonStarDE : EpsilonResolution : 1.5*HStructInfo.EpsilonStarDE;
        Epsilon = 0.1:0.002:0.25;
    end
    JobParam = struct(...
        'Epsilon', Epsilon, ...     % Row vector of channel erasure probabilities. ([0.10:0.002:0.25])
        'MaxTrials', 0.25e5, ...    % Maximum number of trials to run per point. A vector of integers (or a scalar), one for each Epsilon point. (0.25e5)
        'MaxFrameErrors', 1e3, ...	% Max number of frame errors. A vector of integers (or a scalar), one for each Epsilon point.
        'MaxIteration', 100, ...	% Maximum number of decoding iterations.
        'HStruct', HStruct, ...     % A structure array corresponding to the parity-check matrix.
        ...                         % H(j).loc_ones gives the location of ones in the jth row of H matrix.
        'HStructInfo', HStructInfo, ...
        'RunTime', 300, ...         % Simulation time in Seconds.
        'MaxBitErrors', 0, ...
        'CheckPeriod', 100 );       % Checking time in number of Trials.

    ZR = zeros(JobParam.MaxIteration,length(Epsilon));
    JobState = struct(...
        'BitErrors', ZR, ...
        'FrameErrors', ZR, ...
        'Trials', ZR(1,:), ...
        'BER', ZR, ...
        'FER', ZR );
else
    error('The input JOB specification file should either contain a structure called JobParam or a structure array called HStruct (or H_Struct or H_struct).')
end

save(JobName,'JobParam','JobState');

EpsilonStarDE = JobParam.HStructInfo.EpsilonStarDE;
CodeRate = JobParam.HStructInfo.CodeRate;
fprintf('\nThe maximum channel erasure probability for your given parity-check matrix is EpsilonStar = %.8f.\n\n',EpsilonStarDE);
fprintf('The rate of your given LDPC code is CodeRate = %.4f.\n\n',CodeRate);
if JobParam.HStructInfo.FullRankFlag == 1
    fprintf('Your given parity-check matrix IS FULL-RANK! The simulation can be continued.\n\n');
    FullRank = 'Yes';
else
    fprintf('Your given parity-check matrix IS NOT FULL-RANK! The simulation should be terminated.\nYou have to specify another FULL-RANK H matrix.\n');
    FullRank = 'NO';
end

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