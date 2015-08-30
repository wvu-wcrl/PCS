function TaskInputParam = CalcTaskInputParam(obj, JobParam, JobState, NumNewTasks)
% checking and switching on the user type
switch JobParam.InputParam.UserType
    case{'EndUser'}
        TaskInputParam.ImageOnePath=JobParam.InputParam.ImageOnePath;
        TaskInputParam.ImageTwoPath=JobParam.InputParam.ImageTwoPath;
        TaskInputParam.AlgorithmParams=JobParam.InputParam.AlgorithmParams;
        TaskInputParam.UserType = JobParam.InputParam.UserType;
        TaskInputParam.JobState = JobState;
    case {'Developer'}
        
    otherwise
end
end
