function [StopFlag, JobInfo, varargout] = ...
  DetermineStopFlag(obj, JobParam, JobState, JobInfo, JobName, Username, FiguresDir)
% Determine when the process should end by checking if the Matching Score
% initialized is still same. If matching score is changed then process
% should stop
if (JobState.MatchingScore ~= -9.99)
    StopFlag =1;
    
    UpdateStats(JobParam);
    
else
    StopFlag=0;
end

varargout{1}=JobParam;
varargout{2}=JobState;

end
% Veeru will write
function UpdateStats(JobParam)
n=1;
g=load('AlgorithmTable.mat');

while n~=0
t=strcmp(g.Table{n,3},JobParam.InputParam.AlgorithmParams.AlgorithmName);
if (t==1)
Counter=(str2double(g.Table{n,5}))+1;

g.Table{n,5}=int2str(Counter);
Table=g.Table;
n=0;
else
n=n+1;
end
end
save('AlgorithmTable.mat','Table');


end



