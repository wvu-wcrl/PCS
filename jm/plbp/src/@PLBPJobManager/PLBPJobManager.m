classdef PLBPJobManager < JobManager
    
    
    methods(Static)
        function OldPath = SetCodePath(CodeRoot)
            % Determine the home directory.
            OldPath = path;
            
            addpath( fullfile(CodeRoot, 'mat') );
            % This is the location of the mex directory for this architecture.
            % addpath( fullfile( CodeRoot, 'mex', lower(computer) ) );
        end
    end
    
    
    methods
        function obj = PLBPJobManager( cfgRoot, queueCfg )
            % This is the job manager for the parallel LBP project.
            % Calling syntax: obj = PLBPJobManager( [cfgRoot] [,queueCfg] )
            % Input 'cfgRoot' is the FULL path to the configuration file of the job manager.
            % Default: cfgRoot = [filesep,'home','pcs','jm',ProjectName,'cfg',CFG_Filename]
            % ProjectName = 'plbp';
            % CFG_Filename = 'PlbpJobManager_cfg';
            % cfgRoot = '/home/pcs/jm/plbp/cfg/PlbpJobManager_cfg';
            % queueCfg = '/home/pcs/tc/cfg/pcs_short_384.cfg';
            
            % (Optional) input argument 'queueCfg' stores the full path to the queue configuration file.
            
            % Both input arguments must be defined.
            % If no specific job manager configuration file is desired, the argument must be specified as '[]'.
            
            if( nargin<1 || isempty(cfgRoot) ), cfgRoot = []; end
            if( nargin<2 || isempty(queueCfg) ), queueCfg = []; end
            
            obj@JobManager(cfgRoot, queueCfg, 'plbp');
        end
        
        
        function [JobParam, JobState, PPSuccessFlag, PPErrorMsg] = PreProcessJob(obj, JobParamIn, JobStateIn, CurrentUser, JobName)
            
            CodeRoot = CurrentUser.CodeRoot;
            JobParamIn.TaskSize = 10;
            OldPath = obj.SetCodePath(CodeRoot); % Set the path to PLBP project code directory.
            Username = obj.FindUsername(CurrentUser.UserPath);
            
            if( isfield(JobParamIn,'TaskType') && ~isempty(JobParamIn.TaskType) )
            switch JobParamIn.TaskType
                
                case{'Model'}
                    % Set the job StartTime. The StartTime of a Incremental Model-type job is when it starts preprocessing.
                    JobInfo.StartTime = clock; 
                    % [JobParam, PPSuccessFlag, PPErrorMsg] = obj.GetModelPreprocessedData(JobParamIn);
                    [JobParam, PPSuccessFlag, PPErrorMsg] = GetModelPreprocessedData(JobParamIn);
                   
                   JobState = JobStateIn;
                    
                    JobState.CompletedTasks = 0;
                    JobState.GeneratedTasks = 0;
                    
                    if(isfield(JobParamIn,'ModelTask') && strcmp(JobParamIn.ModelTask, 'Identification') == 1)
                        
                        
                        if ismac
                            ModelFileContent = load('/Users/siri/Dropbox/Research/Current/LBP/CLBP/LBP/RandomProjection/home/pcs/Model/Model.mat');
                        else
                            ModelFileContent = load('/home/pcs/projects/plbp/Model/Model.mat');
                        end
                        JobParam.TaskCount = 1;
                        JobState.GeneratedTasks = 1;
                        
                        JobState.Model = ModelFileContent.JobState.Model;
                        JobState.ClassID = ModelFileContent.JobState.ClassID;
                        JobState.Filenames = ModelFileContent.JobState.Filenames;
                        
                        % Set the task StartTime.
                        TaskInfo.StartTime = clock;
                        
                        [LBP_Pattern, TrainClassID, Filenames] = GetSubjectTemplates(JobParam.DataPath, JobParam.Mapping, JobParam.RandomProjection, JobParam.B, JobParam.R, JobParam.P);   
                        ind_cnt = size(LBP_Pattern,1);
                        cnt = size(JobState.Model,1);
                        
                        JobState.Model((cnt+1) : (cnt+ind_cnt),:) = LBP_Pattern;
                        JobState.ClassID((cnt+1) : (cnt+ind_cnt),:) = TrainClassID;
                        JobState.Filenames((cnt+1) : (cnt+ind_cnt),:) = Filenames;
                        
                        % Set the task StopTime.
                        TaskInfo.StopTime = clock;
                        
                        JobState.JobStatus = 'Done';
                        JobState.TaskInfo.StartTime = TaskInfo.StartTime;
                        JobState.TaskInfo.StopTime = TaskInfo.StopTime;
                        JobState.JobInfo.StartTime = JobInfo.StartTime;
                        
                        PPSuccessFlag = 1;
                        PPErrorMsg = 0;
                        JobState.CompletedTasks = 1;
                    end  
                    
                    % Return if failure in data file processing.
                    if PPSuccessFlag == 0
                        return;
                    end       
 
                case{'Identification'}
                    JobParamIn.TaskSize = 1180;
                    
                    % Add Data model to the job file for further processing.
                    [JobInDir, JobRunningDir, JobOutDir, JobFailedDir, SuspendedDir, TempDir, DataDir, FiguresDir] = obj.SetPaths(CurrentUser.JobQueueRoot);
                    if ismac
                        ModelFileContent = load('/Users/siri/Dropbox/Research/Current/LBP/CLBP/LBP/RandomProjection/home/pcs/Model/Model.mat');
                    else
                        ModelFileContent = load('/home/pcs/projects/plbp/Model/Model.mat');
                    end
                    
                    JobParamIn.Model = ModelFileContent.JobState.Model;
                    JobParamIn.ClassID = ModelFileContent.JobState.ClassID;
                    JobParamIn.Filenames = ModelFileContent.JobState.Filenames;
                    JobParamIn.DataImagePath = fullfile(DataDir, JobParamIn.DataFile);
                    
                    JobStateIn.Model = ModelFileContent.JobState.Model;
                    JobStateIn.ClassID = ModelFileContent.JobState.ClassID;
                    JobStateIn.Filenames = ModelFileContent.JobState.Filenames;
                    JobParamIn.Mapping = ModelFileContent.JobParam.Mapping;
                    
                    TemplateCount = size(JobParamIn.Model, 1);
                    if mod(TemplateCount, JobParamIn.TaskSize) == 0
                        JobParamIn.TaskCount = (TemplateCount/JobParamIn.TaskSize);
                    else
                        JobParamIn.TaskCount = floor(TemplateCount/JobParamIn.TaskSize) + 1;
                    end
                    
                    if( isfield(JobParamIn,'NoJMDataPreProcess') && JobParamIn.NoJMDataPreProcess==1 )
                    % if JobParamIn.TaskCount==1
                        JobParam = JobParamIn;
                        PPSuccessFlag = 1;
                        PPErrorMsg = '';
                    else
                    %   [JobParam, PPSuccessFlag, PPErrorMsg] = obj.GetPreprocessedData(JobParamIn);
                    [JobParam, PPSuccessFlag, PPErrorMsg] = GetPreprocessedData(JobParamIn);
                    end
                    
                    % Return if failure in data file processing.
                    if PPSuccessFlag == 0,
                        JobState = JobStateIn;
                        return;
                    else
                        JobState = JobStateIn;
                    end
                    JobState.CompletedTasks = 0;
                    JobState.GeneratedTasks = 0;
                    
                case{'Verification'}
                    % Set the job StartTime. The StartTime of a Verification-type job is when it starts preprocessing.
                    JobInfo.StartTime = clock;
                    
                    JobParamIn.TaskSize = 50;
                    
                    % Add Data model to the job file for further processing.
                    [JobInDir, JobRunningDir, JobOutDir, JobFailedDir, SuspendedDir, TempDir, DataDir, FiguresDir] = obj.SetPaths(CurrentUser.JobQueueRoot);
                    if ismac
                        ModelFileContent = load('/Users/siri/Dropbox/Research/Current/LBP/CLBP/LBP/RandomProjection/home/pcs/Model/Model.mat');
                    else
                        ModelFileContent = load('/home/pcs/projects/plbp/Model/Model.mat');
                    end
                    
                    JobParamIn.Model = ModelFileContent.JobState.Model;
                    JobParamIn.ClassID = ModelFileContent.JobState.ClassID;
                    JobParamIn.Filenames = ModelFileContent.JobState.Filenames;
                    JobParamIn.DataImagePath = fullfile(DataDir, JobParamIn.DataFile);
                    
                    JobParamIn.TestClassID = str2num(JobParamIn.TestClassID);
                    
                    JobStateIn.Model = ModelFileContent.JobState.Model;
                    JobStateIn.ClassID = ModelFileContent.JobState.ClassID;
                    JobStateIn.Filenames = ModelFileContent.JobState.Filenames;
                    JobParamIn.Mapping = ModelFileContent.JobParam.Mapping;
                    
                    % [JobParam, PPSuccessFlag, PPErrorMsg] = obj.GetPreprocessedData(JobParamIn);
                    [JobParam, PPSuccessFlag, PPErrorMsg] = GetPreprocessedData(JobParamIn);
                    
                    % Return if failure in data file processing.
                    if PPSuccessFlag == 0,
                        JobState = JobStateIn;
                        return;
                    else
                        JobState = JobStateIn;
                    end
                    JobState.CompletedTasks = 0;
                    JobState.GeneratedTasks = 0;
                    
                    Counter = 1;
                    Msg = sprintf( 'Generating %d NEW TASK files corresponding to JOB %s of user %s and RUNNING them locally by the JOB MANAGER at %s.\n\n',...
                        Counter, JobName(1:end-4), Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
                    PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                    ClaimedSubject = find(JobParam.ClassID==JobParam.TestClassID);
                    
%                     JobState.TestTemplate = obj.GetTestTemplate(JobParam.DataImagePath, JobParam.RandomProjection, JobParam.B, JobParam.Mapping, JobParam.R, JobParam.P, CurrentUser.FunctionPath);
%                     JobState.TestTemplate = GetTestTemplate(JobParam.DataImagePath, JobParam.RandomProjection, JobParam.B, JobParam.Mapping, JobParam.R, JobParam.P, CurrentUser.FunctionPath);
%                     JobState.TrainModel = JobParam.Model(ClaimedSubject,:);
%                     JobState.TrainClassID = repmat(JobParam.TestClassID, size(ClaimedSubject,1), 1);
%                     JobState.TrainFilenames = JobParam.Filenames(ClaimedSubject,:);
%                     JobState.TestClassID = JobParam.TestClassID;
    
                    TaskMaxRunTime = 10;
                    NumNewTasks = JobParam.TaskCount;
                    CurrentUser.MaxRunTime = 10;
                    CurrentUser.FunctionName = 'EuclideanDistance';
                    
                    TaskInputParam.TrainModel = JobParam.Model(ClaimedSubject,:);
                    TaskInputParam.ClassID = repmat(JobParam.TestClassID, size(ClaimedSubject,1), 1);
                    TaskInputParam.Filenames = JobParam.Filenames(ClaimedSubject,:);
                    % TaskInputParam.TestTemplate = obj.GetTestTemplate(JobParam.DataImagePath, JobParam.RandomProjection, JobParam.B, JobParam.Mapping, JobParam.R, JobParam.P, CurrentUser.FunctionPath);
                    TaskInputParam.TestTemplate = GetTestTemplate(JobParam.DataImagePath, JobParam.RandomProjection, JobParam.B, JobParam.Mapping, JobParam.R, JobParam.P, CurrentUser.FunctionPath);
                    TaskInputParam.TestClassID = JobParam.TestClassID;
                    
                    % Set the task StartTime.
                    TaskInfo.StartTime = clock;
                    CurDir = pwd;
                    if ismac
                        cd(CurrentUser.FunctionPath);
                    else
                        temp_len = size(CurrentUser.FunctionPath, 2);
                        TempFuncPath = ['/' CurrentUser.FunctionPath(3:temp_len)];
                        cd(TempFuncPath);
                    end
                    TaskState = EuclideanDistance(TaskInputParam);
                    cd(CurDir);
                    % Set the task StopTime.
                    TaskInfo.StopTime = clock;
                    
                    Count = JobState.CompletedTasks + 1;
                    JobState.CompletedTasks = Count;
                    if JobState.CompletedTasks >= 1
                        cnt = size(TaskState.Distance, 1);
                        if ~isfield(JobState, 'G2TDist')
                            p_cnt = 0;
                        else
                            p_cnt = size(JobState.G2TDist, 1);
                        end
                        
                        JobState.G2TDist((p_cnt+1):(p_cnt+cnt),:) = TaskState.Distance;
                        JobState.G2TClassID((p_cnt+1):(p_cnt+cnt),:) = TaskInputParam.ClassID;
                        JobState.G2TFilenames((p_cnt+1):(p_cnt+cnt),:) = TaskInputParam.Filenames(1:cnt,:);
                        
                        [JobState.Distance(Count,:), index] = min(TaskState.Distance);   % Find Nearest Neighbor.
                        JobState.MatchClassID(Count,:) = TaskInputParam.ClassID(index);
                        JobState.MatchFilename(Count,:) = TaskInputParam.Filenames(index);
                    end
                    
                    if JobState.CompletedTasks >= JobParam.TaskCount
                        [JobState.MinDist, ind] = min(JobState.Distance);
                        JobState.MinDist_ClassID = JobState.MatchClassID(ind);
                        JobState.MinDist_Filename = JobState.MatchFilename(ind);
                        
                        if JobParam.TestClassID == JobState.MinDist_ClassID
                        % if strcmp(JobParam.TestClassID, num2str(JobState.MinDist_ClassID))
                            JobState.Match = 'Yes';
                        else
                            JobState.Match = 'No';
                        end
                    end
                    
                    JobState.JobStatus = 'Done';
                    JobState.TaskInfo.StartTime = TaskInfo.StartTime;
                    JobState.TaskInfo.StopTime = TaskInfo.StopTime;
                    JobState.JobInfo.StartTime = JobInfo.StartTime;
                    
%                     TaskInputParam = obj.CalcTaskInputParam(JobParam, JobState, NumNewTasks);
%                     if ~isempty(TaskInputParam)
%                         % save new task file.
%                         CurrentUser.TaskID = obj.SaveTaskInFiles(TaskInputParam, CurrentUser, JobName, TaskMaxRunTime);
%                         JobState.GeneratedTasks = JobState.GeneratedTasks + 1;
%                     end
            end
            
            else
                JobParam = JobParamIn;
                JobState = JobStateIn;
                PPSuccessFlag = 0;
                PPErrorMsg = sprintf( ['The JobParam structure in job file %s of user %s does not contain a TaskType field.\n',...
                    'The TaskType should be specified as one of these options: Model, Identification, or Verification.\n\n'], JobName(1:end-4), Username );
                PrintOut(PPErrorMsg, 0, obj.JobManagerParam.LogFileName);
            end
            
            path(OldPath);
        end
        
        
        function [FinalTaskID, JobState] = DivideJob2Tasks(obj, JobParam, JobState, UserParam, NumNewTasks, JobName, TaskMaxRunTime)
            % Divide the JOB into multiple TASKs.
            % Calling syntax: [FinalTaskID, JobState] = obj.DivideJob2Tasks(JobParam, JobState, UserParam, NumNewTasks, JobName [,TaskMaxRunTime]);
            if( nargin<7 || isempty(TaskMaxRunTime) )
                if( isfield(JobParam, 'MaxRunTime') && (JobParam.MaxRunTime ~= -1) )
                    TaskMaxRunTime = JobParam.MaxRunTime;
                else
                    TaskMaxRunTime = UserParam.MaxRunTime;
                end
            end
            FinalTaskID = UserParam.TaskID;
            
            % [HomeRoot, Username, Extension, Version] = fileparts(UserParam.UserPath);
            % [Dummy, Username] = fileparts(UserParam.UserPath);
            Username = obj.FindUsername(UserParam.UserPath);
            
            if JobState.GeneratedTasks < JobParam.TaskCount
                if NumNewTasks > 0
                    % Calculate TaskInputParam vector for NumNewTasks new input tasks.
                    switch JobParam.TaskType
                        
                        case{'Model'}
                            Counter = JobParam.TaskCount;
                            
                            Msg = sprintf( 'Generating %d NEW TASK files corresponding to JOB %s of user %s and saving them to its TaskIn directory at %s.\n\n',...
                                Counter, JobName(1:end-4), Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
                            PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                            
                            JobState.Mapping = JobParam.Mapping;
                            JobState.N = JobParam.N;
                            JobState.RandomProjection = JobParam.RandomProjection;
                            JobState.B = JobParam.B;
                            JobState.R = JobParam.R;
                            JobState.P = JobParam.P;
                            
                            TaskMaxRunTime = 10;
                            NumNewTasks = JobParam.TaskCount;
                            UserParam.MaxRunTime = 10;
                            UserParam.FunctionName = 'LBPPatterns';
                            
                            for j = 1:Counter
                                CurMin = ((j - 1) * JobParam.TaskSize) + 1;
                                if j < Counter
                                    CurMmax = (j * JobParam.TaskSize);
                                elseif j == Counter
                                    CurMmax = JobParam.SubjectCount;
                                end
                                
                                JobState.TaskSubjectDirPath = JobParam.SubjectDirPath(CurMin:CurMmax,:);
                                
                                TaskInputParam = obj.CalcTaskInputParam(JobParam, JobState, NumNewTasks);
                                
                                if ~isempty(TaskInputParam)
                                    % Save new task file.
                                    UserParam.TaskID = obj.SaveTaskInFiles(TaskInputParam, UserParam, JobName, TaskMaxRunTime);
                                    JobState.GeneratedTasks = JobState.GeneratedTasks + 1;
                                end
                            end
                            
                            if JobState.GeneratedTasks >= JobParam.TaskCount
                                JobState.JobFileUpdateRequest = 1;
                            end
                            
                        case{'Identification'}
                            Counter = JobParam.TaskCount;
                            
                            % Msg = sprintf( 'Generating %d NEW TASK files corresponding to JOB %s of user %s and saving them to its TaskIn directory at %s.\n\n',...
                            %     Counter, JobName(1:end-4), Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
                            % PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                            
                            TemplateCount = size(JobParam.Model, 1);
                            
                            if ~( isfield(JobParam,'NoJMDataPreProcess') && JobParam.NoJMDataPreProcess==1 )
                            % if JobParam.TaskCount~=1
                            %     JobState.TestTemplate = obj.GetTestTemplate(JobParam.DataImagePath, ...
                            %         JobParam.RandomProjection, JobParam.B, JobParam.Mapping, JobParam.R, JobParam.P, UserParam.FunctionPath);
                            JobState.TestTemplate = GetTestTemplate(JobParam.DataImagePath, ...
                                JobParam.RandomProjection, JobParam.B, JobParam.Mapping, JobParam.R, JobParam.P, UserParam.FunctionPath);
                            end
                            
                            TaskMaxRunTime = 10;
                            NumNewTasks = JobParam.TaskCount;
                            UserParam.MaxRunTime = 10;
                            UserParam.FunctionName = 'EuclideanDistance';
                            
                            for j = 1 : Counter
                                CurMin = ((j - 1) * JobParam.TaskSize) + 1;
                                if j <  Counter
                                    CurMmax = (j * JobParam.TaskSize);
                                elseif j == Counter
                                    CurMmax = TemplateCount;
                                end
                                
                                JobState.TrainModel = JobParam.Model(CurMin:CurMmax,:);
                                JobState.TrainClassID = JobParam.ClassID(CurMin:CurMmax,:);
                                JobState.TrainFilenames = JobParam.Filenames(CurMin:CurMmax,:);
                                % JobState.TestClassID = str2num(JobParam.TestClassID);
                                
                                TaskInputParam = obj.CalcTaskInputParam(JobParam, JobState, NumNewTasks);
                                if ~isempty(TaskInputParam)
                                    % Save new task file.
                                    TaskInputParam.JobParam.FunctionPath = UserParam.FunctionPath;
                                    UserParam.TaskID = obj.SaveTaskInFiles(TaskInputParam, UserParam, JobName, TaskMaxRunTime);
                                    JobState.GeneratedTasks = JobState.GeneratedTasks + 1;
                                end
                            end
                            
                            if JobState.GeneratedTasks >= JobParam.TaskCount
                                JobState.JobFileUpdateRequest = 1;
                            end
                    end
                    
                    FinalTaskID = UserParam.TaskID;
                else    % TaskInDir of the current user is full. No new tasks will be generated.
                    Msg = sprintf('No new task is generated for user %s since its TaskIn directory is full.\n', Username);
                    PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                end
            end
        end
        
        
        function [JobDirectory, JobNameCell] = SelectInRunningJob(obj, JobInDir, JobRunningDir, MaxRunningJobs, SuccessMsgIn, SuccessMsgRunning, NoJobMsg)
            % Pick a job from JobIn or JobRunning directory and return its directory and its name.
            %
            % Calling syntax: [JobDirectory, JobNameCell] = obj.SelectInRunningJob(JobInDir, JobRunningDir, MaxRunningJobs [,SuccessMsgIn] [,SuccessMsgRunning] [,NoJobMsg])
            % MaxRunningJobs is a POSITIVE maximum number of simultaneously-running jobs.
            DIn = dir( fullfile(JobInDir,'*.mat') );
            DRunning = dir( fullfile(JobRunningDir,'*.mat') );
            
            if( length(DRunning) >= MaxRunningJobs )
                % Pick a running job AT RANDOM.
                % JobDirectory = JobRunningDir;
                % JobFileIndex = randi( [1 length(DRunning)], [1 1] );
                % Construct the filename.
                % JobName = DRunning(JobFileIndex).name;
                % if( nargin>=6 && ~isempty(SuccessMsgRunning) )
                %     Msg = [SuccessMsgRunning sprintf('Selected JOB name: %s.\n', JobName(1:end-4))];
                %     PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                % end
                JobDirectory = [];
                JobNameCell = {};
                % if( nargin>=7 && ~isempty(NoJobMsg) )
                %     PrintOut(NoJobMsg, 0, obj.JobManagerParam.LogFileName);
                % end
                % JobNameCell{1} = JobName;
            else
                if ~isempty(DIn)
                    % Pick the OLDEST new job.
                    JobDirectory = JobInDir;
                    [Dummy, DateIndx] = sort( [DIn(:).datenum], 'ascend' );
                    if length(DateIndx) < 50
                        JobFileIndex = DateIndx;
                    else
                        JobFileIndex = DateIndx(1:50);
                    end
                    JobNameCell = cell(1,length(JobFileIndex));
                    for JobNum=1:length(JobFileIndex)
                        % Construct the filename.
                        JobName = DIn(JobFileIndex(JobNum)).name;
                        % if( nargin>=5 && ~isempty(SuccessMsgIn) )
                        %     Msg = [SuccessMsgIn sprintf('Selected JOB name: %s.\n', JobName(1:end-4))];
                        %     PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                        % end
                        Msg = sprintf('\nSelected JOB name: %s.\n', JobName(1:end-4));
                        PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                        JobNameCell{JobNum} = JobName;
                    end
                elseif ~isempty(DRunning)
                    % Pick a running job AT RANDOM.
                    % JobDirectory = JobRunningDir;
                    % JobFileIndex = randi( [1 length(DRunning)], [1 1] );
                    % Construct the filename.
                    % JobName = DRunning(JobFileIndex).name;
                    % if( nargin>=6 && ~isempty(SuccessMsgRunning) )
                    %     Msg = [SuccessMsgRunning sprintf('Selected JOB name: %s.\n', JobName(1:end-4))];
                    %     PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                    % end
                    % JobNameCell{1} = JobName;
                    JobDirectory = [];
                    JobNameCell = {};
                else
                    JobDirectory = [];
                    JobNameCell = {};
                    if( nargin>=7 && ~isempty(NoJobMsg) )
                        PrintOut(NoJobMsg, 0, obj.JobManagerParam.LogFileName);
                    end
                end
            end
        end
        
        
        TaskInputParam = CalcTaskInputParam(obj, JobParam, JobState, NumNewTasks)
        
        
        JobState = UpdateJobState(obj, JobStateIn, TaskState, JobParam)
        
        
        [StopFlag, JobInfo, varargout] = DetermineStopFlag(obj, JobParam, JobState, JobInfo, JobName, Username, FiguresDir)
        
        
        % [JobParam, PPSuccessFlag, PPErrorMsg] = GetModelPreprocessedData(obj, JobParam)
        
        
        FinalTaskID = SaveTaskInFiles(obj, TaskInputParam, UserParam, JobName, TaskMaxRunTime)
        
        
        function NumProcessUnit = FindNumProcessUnits(obj, TaskState)
            NumProcessUnit = size(TaskState.InputParam.TrainModel, 1);
        end
        
        
        function TaskOutFileIndex = FindFinishedTask2Read(obj, NumTaskOut)
            % Pick finished task files at random.
            if NumTaskOut<10
                TaskOutFileIndex = 1:NumTaskOut;
            else
                % TaskOutFileIndex = randi( [1 NumTaskOut], [1 1] );
                TaskOutFileIndex = 1:10;
            end
        end
        
    end
    
    
    methods(Static)
        % [JobParam, PPSuccessFlag, PPErrorMsg] = GetModelPreprocessedData(JobParam)
        
        
        % [JobParam, PPSuccessFlag, PPErrorMsg] = GetPreprocessedData(JobParam)
        
        
        % Q = OrthonormalMatrixUniform(n, Seed)
        
        
        % Q = OrthonormalMatrix(n, seed)
        
        
        % P = RandomPermutationMatrixUniform(n, Seed)
        
        
        % P = RandomPermutationMatrix(n, seed)
        
        
        % TestTemplate = GetTestTemplate(Filename, RandomProjection, B, Mapping, R, P, UserCodeRoot)
    end
end
