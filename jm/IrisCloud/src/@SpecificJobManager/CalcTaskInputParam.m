function TaskInputParam = CalcTaskInputParam(obj, JobParam, JobState, NumNewTasks)
% checking and switching on the user type
switch JobParam.UserType
    case{'EndUser'}
        TaskInputParam.ImageOnePath=JobParam.InputParam.ImageOnePath;
        TaskInputParam.ImageTwoPath=JobParam.InputParam.ImageTwoPath;
        TaskInputParam.AlgorithParams=JobParam.AlgorithmParams;
        TaskInputParam.JobState = JobState;
    case {'Developer'}
        
    otherwise
end
end
