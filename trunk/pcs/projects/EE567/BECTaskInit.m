function TaskState = BECTaskInit(BECParam)
% This function uses BECLinkSimulation class to simulate the performance of a binary erasure channel communication system.
%
% BECParam is a structure defining simulation parameters.
% BECParam = struct(...
%     'HStruct', [], ...        % A structure array corresponding to the parity-check matrix.
%      ...                      % H(j).loc_ones gives the location of ones in the jth row of H matrix.
%     'Epsilon', [],...         % Row vector of Epsilon points.
%     'MaxTrials', 1e9, ...     % A vector of integers (or scalar), one for each Epsilon point. Maximum number of trials to run per point.
%     'MaxBitErrors', 0, ...
%     'MaxFrameErrors', 100*ones(size(Epsilon)), ...
%     'RunTime', 300, ...       % Simulation time in Seconds.
%     'MaxIteration', 100,...   % Maximum number of decoding iterations for LDPC decoding (Default MaxIteration=100).
%     'RandSeed',1000*sum(clock));  % New seed for the random generator of current worker.

% First, set the path.
OldPath = SetPath();

if( ~isfield(BECParam, 'MaxTrials') || isempty(BECParam.MaxTrials) ), BECParam.MaxTrials = 1e6; end
if( ~isfield(BECParam, 'MaxBitErrors') || isempty(BECParam.MaxBitErrors) ), BECParam.MaxBitErrors = 0; end
if( ~isfield(BECParam, 'MaxFrameErrors') || isempty(BECParam.MaxFrameErrors) ), BECParam.MaxFrameErrors = 1000; end
if( ~isfield(BECParam, 'RunTime') || isempty(BECParam.RunTime) ), BECParam.RunTime = 300; end
if( ~isfield(BECParam, 'MaxIteration') || isempty(BECParam.MaxIteration) ), BECParam.MaxIteration = 100; end
if( ~isfield(BECParam, 'RandSeed') || isempty(BECParam.RandSeed) ), BECParam.RandSeed = 1000*sum(clock); end

CheckPeriod = 100;   % Checking time in number of Trials to see if the time is up.

TaskParam = struct(...
    'HStruct', BECParam.HStruct, ...     % A structure array corresponding to the parity-check matrix.
    ...                                  % H(j).loc_ones gives the location of ones in the jth row of H matrix.
    'Epsilon', BECParam.Epsilon, ...     % Row vector of Epsilon points.
    'MaxTrials', BECParam.MaxTrials, ... % A vector of integers (or scalar), one for each Epsilon point. Maximum number of trials to run per point.
    'RunTime', BECParam.RunTime, ...     % Simulation time in Seconds.
    'CheckPeriod', CheckPeriod, ...      % Checking time in number of Trials.
    'MaxBitErrors', BECParam.MaxBitErrors, ...
    'MaxFrameErrors', BECParam.MaxFrameErrors, ...
    'MaxIteration', BECParam.MaxIteration, ... % Maximum number of decoding iterations.
    'RandSeed', BECParam.RandSeed);

Link = BECLinkSimulation(TaskParam);
TaskState = Link.SingleSimulate();

TaskState.NumCodewords = 1;
TaskState.DataLength = Link.CodewordLength;

RemovePath(OldPath);

end


function OldPath = SetPath()
OldPath = path;
addpath( fullfile(filesep,'rhome','pcs','projects','EE567') );
end


function RemovePath(OldPath)
path(OldPath);
end