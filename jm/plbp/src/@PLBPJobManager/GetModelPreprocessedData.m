function [JobParam, PPSuccessFlag, PPErrorMsg] = GetModelPreprocessedData(obj, JobParam)

%[JobParam.SubjectCount, JobParam.SubjectDirPath] = obj.GetSubjectCount(JobParam.InputDir);
[JobParam.SubjectCount, JobParam.SubjectDirPath] = obj.GetSubjectCount(JobParam.DataPath);

if mod(JobParam.SubjectCount, JobParam.TaskSize) == 0
    JobParam.TaskCount = JobParam.SubjectCount/JobParam.TaskSize;
else
    JobParam.TaskCount = floor(JobParam.SubjectCount/JobParam.TaskSize) + 1;
end

JobParam.R = 1;
JobParam.P = 2;
% JobParam.P = 26;

JobParam.Mapping = Getmapping(JobParam.P, 'riu2');
Seed = sum(double(JobParam.Key));
n = (JobParam.P + 2)/2;

% Orthonormal matrix.
Q = obj.OrthonormalMatrix(n, Seed);

% RandomPermutation matrix.
Seed = prod(double(JobParam.Key));
P1 = obj.RandomPermutationMatrix(n, Seed);

% Blinding vector.
JobParam.N = 2*n;
rand('twister',Seed);
B = rand(JobParam.N,1);

% Orthonormal matrix and RandomPermutation matrix.
JobParam.RandomProjection = Q*P1;
JobParam.B = B;

if JobParam.TaskCount ~= 0
    PPSuccessFlag = 1;
    PPErrorMsg = '';
else
    PPSuccessFlag = 0;
    PPErrorMsg = 1;
end
end


function [UserCount, SubjectDirPath] = GetSubjectCount(obj, InputDir)
% input_dir = 'C:\Material\Research\Current\image_data';
UserCount = 0;
Directories = dir(InputDir);
count = numel(Directories);
for Cont = 3:count % Ignore . and .. directories.
    if Directories(Cont).isdir == 1
        DirPath = fullfile(InputDir, Directories(Cont).name);
        len = size(DirPath, 2);
        PseudoDirPath = ['/r' DirPath(2:len)];
        SubjectDirectories = dir(DirPath);
        SubjectCount = numel(SubjectDirectories);
        for j = 3:SubjectCount % Ignore . and .. directories.
            if SubjectDirectories(Cont).isdir == 1
                UserCount = UserCount + 1;
                if ismac %In mac
                    SubjectDirPath(UserCount,:) = {fullfile(DirPath, SubjectDirectories(j).name)};
                else %In not pc
                    SubjectDirPath(UserCount,:) = {fullfile(PseudoDirPath, SubjectDirectories(j).name)};
                end
            end
        end
    end
end
end