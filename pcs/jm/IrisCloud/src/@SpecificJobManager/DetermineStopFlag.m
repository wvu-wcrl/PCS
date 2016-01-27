% DetermineStopFlag.m
% Determine if job is complete, if so, set flag to stop new task creation.
% 
%
% Inputs
%  obj          Specific job manager object.
%  JobParam     JobParam structure read from user's input file.
%  JobState     JobState structure containing current job state.
%  JobInfo      Structure containing job execution information.
%  JobName      Job name.
%  Username     WCRL cluster username of executing user.
%  FiguresDir   Path to user's figure directory.
%
% Outputs
%  StopFlag     Boolean indicating whether to stop job (1=yes, 0=no).
%  JobInfo      JobInfo structure updated after execution of this method.
%  varargout    Variable length return argument. By definition,
%                 varargout{1} = JobParam
%                 varargout{2} = JobState
%
%     Last updated on 9/7/2015
%
%     Copyright (C) 2015, Terry Ferrett and Matthew C. Valenti.
%     For full copyright information see the bottom of this file.


function [StopFlag, JobInfo, varargout] = ...
    DetermineStopFlag(obj, JobParam, JobState, JobInfo, JobName, Username,...
    FiguresDir)

% The criteria for IrisCloud job stoppage is to stop when the matching
%  score takes a value other than the initial value.
%  The initial value is defined as -9.99.
if (JobState.MatchingScore ~= -9.99)
    StopFlag = 1;    
    UpdateStats(JobParam);    
else
    StopFlag=0;
end

% Pass structures JobParam and JobState from input to output.
varargout{1}=JobParam;
varargout{2}=JobState;

end



% Function to update IrisCloud algorithm usage statistics.
% This function
%   1. Reads the algorithm table from disk
%   2. Increments the execution count for the algorithm used by this job
%   3. Saves updated algorithm table to disk
function UpdateStats(JobParam)

% Define path to algorithm table (later make specific job parameter).
TblPath = '/home/pcs/jm/IrisCloud/Usage/AlgorithmTable.mat';
g=load(TblPath);

% Locate selected algorithm in table and increment its execution count.
AlgorithmName = JobParam.AlgorithmParams.AlgorithmName;
Table = g.Table;
Table = iaec( Table, AlgorithmName );
  % iaec - increment algorithm execution count

% Save updated table to disk.
save(TblPath,'Table');
 
end



% increment algorithm execution count (iaec)
function Table = iaec( Table, AlgorithmName )

n=2;
while n~=0
    t = strcmp( Table{n,3}, AlgorithmName );
    if (t==1)
        Table{n,5} = Table{n,5} + 1;        
        n=0;
    else
        n=n+1;
    end
end

end


