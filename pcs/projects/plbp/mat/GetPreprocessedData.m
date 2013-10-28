function [JobParam, PPSuccessFlag, PPErrorMsg] = GetPreprocessedData(JobParam)

switch JobParam.TaskType
    case{'Identification'}
        TemplateCount = size(JobParam.Model, 1);
        if mod(TemplateCount, JobParam.TaskSize) == 0
            JobParam.TaskCount = (TemplateCount/JobParam.TaskSize);
        else
            JobParam.TaskCount = floor(TemplateCount/JobParam.TaskSize) + 1;
        end
    case{'Verification'}
        JobParam.TaskCount = 1;
end


if JobParam.TaskCount ~= 0
    PPSuccessFlag = 1;
    PPErrorMsg = '';
else
    PPSuccessFlag = 0;
    PPErrorMsg = 'Preprocessing the job file failed.\n';
end

end
