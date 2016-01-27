function [StopFlag, JobInfo, varargout] = DetermineStopFlag(obj, JobParam, JobState, JobInfo, JobName, Username, FiguresDir)
% Determine if the global stopping criteria have been reached/met. Moreover, determine and echo progress of running JobName.
% Furthermore, update Results file.
% Calling syntax: [StopFlag, JobInfo [,JobParam] [,JobState]] = obj.DetermineStopFlag(JobParam, JobState, JobInfo [,JobName] [,Username] [,FiguresDir])

if JobState.CompletedTasks == JobParam.TaskCount
    StopFlag = 1;
    switch JobParam.TaskType
        
        case{'Identification'}
            Results = struct( 'MinDist',num2str(JobState.MinDist(1)),...
                'MinDist_ClassID',JobState.MinDist_ClassID{1});
            % 'MinDist_ClassID',num2str(JobState.MinDist_ClassID),...
            % 'MinDist_Filename',fliplr( strtok( fliplr(char(JobState.MinDist_Filename{1})), filesep ) ) );
            JobInfo = obj.UpdateJobInfo( JobInfo, 'Results', Results );
            
            % JobInfo.Results.MinDist = num2str(JobState.MinDist);
            % JobInfo.Results.MinDist_ClassID = num2str(JobState.MinDist_ClassID);
            % JobInfo.Results.MinDist_Filename = JobState.MinDist_Filename{1};
            % JobInfo.Results.MinDist_Filename = fliplr( strtok( fliplr(char(JobState.MinDist_Filename{1})), filesep ) );
            
            cnt = size(JobState.MinDist_Filename, 1);
            for i = 1 : cnt
                FigureFilename = fliplr( strtok( fliplr(char(JobState.MinDist_Filename{i})),filesep ) );
                FigureFilePath = fullfile(FiguresDir, FigureFilename);
                
                FullFileName = fliplr(strtok(fliplr(JobName),filesep ));
                FileName = strtok(FullFileName,'.');
                FileExt = fliplr(strtok(fliplr(FullFileName),'.' ));
                
                NewFigureFilename = [FileName '_Figure' num2str(i) '.jpg'];
                NewFigureFilePath = fullfile(FiguresDir, NewFigureFilename);
                
                if ismac
                    MinDistFilename = JobState.MinDist_Filename{i};
                else
                    TempFilename = JobState.MinDist_Filename{i};
                    cnt = size(TempFilename, 2);
                    if TempFilename(2) == 'r'
                        MinDistFilename = [ TempFilename(1) TempFilename(3:cnt) ]
                    else
                        MinDistFilename = TempFilename
                    end
                end
                
                
                if (strcmp(FileExt, 'jgp') == 0 || strcmp(FileExt, 'jpeg') == 0)
                    A = imread(MinDistFilename);
                    imwrite(A, NewFigureFilePath);
                else
                    if ismac
                        obj.CopyFile(char(JobState.MinDist_Filename{i}), FiguresDir);
                    else
                        
                        obj.CopyFile(MinDistFilename, FiguresDir);
                    end
                    obj.MoveFile(FigureFilePath, NewFigureFilePath);
                end
                
                
                %                 if ismac
                %                     obj.CopyFile(char(JobState.MinDist_Filename{1}), FiguresDir);
                %                 else
                %                     obj.CopyFile(MinDistFilename, FiguresDir);
                %                 end
                %                 obj.MoveFile(FigureFilePath, NewFigureFilePath);
            end
            
            
        case{'Verification'}
            Results = struct( 'MinDist',num2str(JobState.MinDist), 'MinDist_ClassID',num2str(JobState.MinDist_ClassID),...
                'MinDist_Filename',fliplr( strtok( fliplr(char(JobState.MinDist_Filename{1})),filesep ) ), 'Match',JobState.Match );
            
            JobInfo = obj.UpdateJobInfo( JobInfo, 'Results', Results );
            
            % JobInfo.Results.MinDist = num2str(JobState.MinDist);
            % JobInfo.Results.MinDist_ClassID = num2str(JobState.MinDist_ClassID);
            % JobInfo.Results.MinDist_Filename = JobState.MinDist_Filename{1};
            % JobInfo.Results.MinDist_Filename = fliplr( strtok( fliplr(char(JobState.MinDist_Filename{1})),filesep ) );
            % JobInfo.Results.Match = JobState.Match;
            
        case{'Model'}
            if ismac
                save '/Users/siri/Dropbox/Research/Current/LBP/CLBP/LBP/RandomProjection/home/pcs/Model/Model.mat' JobParam JobState;
            else
                save '/home/pcs/projects/plbp/Model/Model.mat' JobParam JobState;
            end
        otherwise
    end
else
    StopFlag = 0;
end

if StopFlag == 1
    PrintJobStopMsg(JobName, Username, obj.JobManagerParam.LogFileName );
end

varargout{1} = JobParam;
varargout{2}= JobState;
end


function PrintJobStopMsg( JobName, Username, LogFileName )
if( nargin >= 3 && ~isempty(JobName) && ~isempty(Username) && ~isempty(LogFileName) )
    StopMsg = sprintf('\n\nRunning job %s for user %s is STOPPED completely.\n\n', JobName(1:end-4), Username );
    PrintOut(StopMsg, 0, LogFileName);
end
end