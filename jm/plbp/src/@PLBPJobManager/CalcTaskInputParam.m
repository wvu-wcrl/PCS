function TaskInputParam = CalcTaskInputParam(obj, JobParam, JobState, NumNewTasks)
% Calculate TaskInputParam based on the number of gallery images.
% TaskInputParam is an either 1-by-1 or NumNewTasks-by-1 vector of structures each one of them containing one Task's InputParam structure.

switch JobParam.TaskType
    case {'Identification'}
        TaskInputParam.TrainModel = JobState.TrainModel;
        TaskInputParam.ClassID = JobState.TrainClassID;
        TaskInputParam.Filenames = JobState.TrainFilenames;
        if( isfield(JobState,'TestTemplate') && ~isempty(JobState.TestTemplate) )
            TaskInputParam.TestTemplate = JobState.TestTemplate;
        else
            TaskInputParam.JobParam = JobParam;
            TaskInputParam.JobState = JobState;
        end
        % TaskInputParam.TestClassID = JobState.TestClassID;
    case {'Verification'}
        TaskInputParam.TrainModel = JobState.TrainModel;
        TaskInputParam.ClassID = JobState.TrainClassID;
        TaskInputParam.Filenames = JobState.TrainFilenames;
        TaskInputParam.TestTemplate = JobState.TestTemplate;
        TaskInputParam.TestClassID = JobState.TestClassID;
    case {'Model'}
        TaskInputParam.SubjectDirPaths = JobState.TaskSubjectDirPath;
        TaskInputParam.Mapping = JobState.Mapping;
        TaskInputParam.N = JobState.N;
        TaskInputParam.RandomProjection = JobState.RandomProjection;
        TaskInputParam.B = JobState.B;
        TaskInputParam.R = JobState.R;
        TaskInputParam.P = JobState.P;
    otherwise
end
end