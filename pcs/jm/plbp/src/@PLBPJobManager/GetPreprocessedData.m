function [JobParam PPSuccessFlag PPErrorMsg] = GetPreprocessedData(obj, JobParam)

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

JobParam.R = 1;
JobParam.P = 2;
% JobParam.P = 26;

% JobParam.Mapping = Getmapping(JobParam.P,'riu2');
Seed = sum(double(JobParam.Key));
n = (JobParam.P + 2)/2;

% Orthonormal matrix.
Q = obj.OrthonormalMatrix(n, Seed);

% RandomPermutation matrix.
Seed = prod(double(JobParam.Key));
P1 = obj.RandomPermutationMatrix(n, Seed);

% Blinding vector.
JobParam.N = 2*n;
rand('twister',Seed)
B = rand(JobParam.N,1);

% Orthonormal matrix and RandomPermutation matrix.
JobParam.RandomProjection = Q*P1;

JobParam.B = B;

if JobParam.TaskCount ~= 0
    PPSuccessFlag = 1;
    PPErrorMsg = '';
else
    PPSuccessFlag = 0;
    PPErrorMsg = 'Preprocessing the job file failed.\n';
end

end