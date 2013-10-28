function OutputParam = EuclideanDistance(InputParam)

if( ~isfield(InputParam,'TestTemplate') || isempty(InputParam.TestTemplate) )
    % addpath( fullfile( filesep, 'rhome', 'pcs', 'jm', 'CodedMod', 'src' ) );
    % addpath( fullfile( filesep, 'rhome', 'pcs', 'jm', 'plbp', 'src' ) );
    % [InputParam.JobParam, PPSuccessFlag, PPErrorMsg] = PLBPJobManager.GetPreprocessedData(InputParam.JobParam);
    if isfield(InputParam,'JobParam') && ~isempty(InputParam.JobParam)
        [InputParam.JobParam, PPSuccessFlag, PPErrorMsg] = GetPreprocessedData(InputParam.JobParam);
    end
    JobParam = InputParam.JobParam;
    sprintf('TaskCount:%d R:%d P: %d N:%d BRows:%d RPRows:%d RPColumns:%d\n',...
         JobParam.TaskCount, JobParam.R, JobParam.P, JobParam.N, size(JobParam.B,1),size(JobParam.RandomProjection,1) ,size(JobParam.RandomProjection,2))
    % error('TaskCount:%d R:%d P: %d N:%d BRows:%d RPRows:%d RPColumns:%d',...
    %     JobParam.TaskCount, JobParam.R, JobParam.P, JobParam.N, size(JobParam.B,1),size(JobParam.RandomProjection,1) ,size(JobParam.RandomProjection,2))
%     try
%         % InputParam.JobState.TestTemplate = PLBPJobManager.GetTestTemplate(JobParam.DataImagePath, ...
%         %     JobParam.RandomProjection, JobParam.B, JobParam.Mapping, JobParam.R, JobParam.P, JobParam.FunctionPath);
%         InputParam.JobState.TestTemplate = GetTestTemplate(JobParam.DataImagePath, ...
%             JobParam.RandomProjection, JobParam.B, JobParam.Mapping, JobParam.R, JobParam.P, JobParam.FunctionPath);
%         InputParam.TestTemplate = InputParam.JobState.TestTemplate;
%     catch
        JobParam.DataImagePath = [filesep 'r' JobParam.DataImagePath(2:end)];
        % InputParam.JobState.TestTemplate = PLBPJobManager.GetTestTemplate(JobParam.DataImagePath, ...
        %     JobParam.RandomProjection, JobParam.B, JobParam.Mapping, JobParam.R, JobParam.P, JobParam.FunctionPath);
        InputParam.JobState.TestTemplate = GetTestTemplate(JobParam.DataImagePath, ...
            JobParam.RandomProjection, JobParam.B, JobParam.Mapping, JobParam.R, JobParam.P, JobParam.FunctionPath);
        InputParam.TestTemplate = InputParam.JobState.TestTemplate;
        % error('TestTemplateR:%d TestTemplateC:%d',size(InputParam.TestTemplate,1),size(InputParam.TestTemplate,2))
        sprintf('TestTemplateR:%d TestTemplateC:%d\n',size(InputParam.TestTemplate,1),size(InputParam.TestTemplate,2))
%     end
        if isfield(InputParam,'JobParam') && ~isempty(InputParam.JobParam)
            InputParam = rmfield(InputParam,{'JobParam','JobState'})
        end
end

X = InputParam.TrainModel;
Y = InputParam.TestTemplate;
m = size(X,1);
n = size(Y,1);
XX = sum(X.*X, 2);
YY = sum(Y'.*Y', 1);
A = XX(:,ones(1,n));
B = YY(ones(1,m),:);
C = 2*X*Y';
OutputParam.Distance = XX(:,ones(1,n)) + YY(ones(1,m),:) - 2*X*Y';
OutputParam.InputParam = InputParam;
sprintf('DistanzeL:%d\n',length(OutputParam.Distance))
end