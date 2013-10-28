function [JobParam, PPSuccessFlag, PPErrorMsg] = GetModelPreprocessedData(JobParam)

[JobParam.SubjectCount, JobParam.SubjectDirPath] = GetSubjectCount(JobParam.DataPath);

if mod(JobParam.SubjectCount, JobParam.TaskSize) == 0
    JobParam.TaskCount = JobParam.SubjectCount/JobParam.TaskSize;
else
    JobParam.TaskCount = floor(JobParam.SubjectCount/JobParam.TaskSize) + 1;
end

if JobParam.TaskCount ~= 0
    PPSuccessFlag = 1;
    PPErrorMsg = '';
else
    PPSuccessFlag = 0;
    PPErrorMsg = 1;
end
end


function [UserCount, SubjectDirPath] = GetSubjectCount(InputDir)
UserCount = 0;
% SubjectDirPath = [];
SubjectDirPath = {};
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
                else 
                    SubjectDirPath(UserCount,:) = {fullfile(PseudoDirPath, SubjectDirectories(j).name)};
                end
            end
        end
    end
end
end
