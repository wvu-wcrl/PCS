classdef JobManager < handle
    
    properties
        JobManagerParam
        UserList = []
    end
    
    properties(SetAccess = protected)
        NodeID_Times = []   % NodeID_Times is a vector structure with two fields:
                            % NodeID and NumNodeTaskInfo (how many times that specific node has generated TaskInfo (run simulations)).
                            % The length of this structure is equal to the number of active nodes (NumNode).
        eTimeTrial = []     % eTimeTrial is a 3-by-MaxRecentTaskInfo-by-NumNode matrix.
        % Its first row contains the time calculated globally from the start of the job manager until receiving curret consumed task from TaskOut directory.
        % Its second row contains elapsed times in current task at the worker and its third row contains the number of trials completed during the eTime at the worker.
    end
    
    
    methods(Static)
        function OldPath = SetCodePath(CodeRoot)
            % Determine the home directory.
            OldPath = path;
            
            addpath( fullfile(CodeRoot, 'mat') );
            % This is the location of the mex directory for this architecture.
            addpath( fullfile( CodeRoot, 'mex', lower(computer) ) );
        end
        
        
        function [JobInDir, JobRunningDir, JobOutDir, TempDir] = SetPaths(JobQueueRoot)
            % Build required directories under user's JobQueueRoot.
            JobInDir = fullfile(JobQueueRoot,'JobIn');
            JobRunningDir = fullfile(JobQueueRoot,'JobRunning');
            JobOutDir = fullfile(JobQueueRoot,'JobOut');
            TempDir = fullfile(JobQueueRoot,'Temp');
            % TaskInDir = fullfile(TasksRoot,'TaskIn');
            % TaskOutDir = fullfile(TasksRoot,'TaskOut');
        end
        
        
        function NumNewTasks = FindNumNewTasks(UserParam)
            NumNewTasks = 0;
            % TaskInDir = fullfile(UserParam.TasksRoot,'TaskIn');
            TaskInDir = UserParam.TaskInDir;
            
            % Sense the load of the task input queue (TaskIn directory) of current user.
            DTaskIn = dir( fullfile(TaskInDir,'*.mat') );
            CurrentTaskLoad = length(DTaskIn);

            if CurrentTaskLoad <= UserParam.MaxInputTasks % If CurrentTaskLoad>MaxInputTasks, NO NEW TASKs will be generated.
                % As long as CurrentTaskLoad is less than MaxInputTasks, always generate at least one task.
                % If CurrentTaskLoad is less than TaskGenDecelerate, generate MaxTaskGenStep (or TaskGenDecelerate-CurrentTaskLoad) tasks at a time.
                NumNewTasks = max( min( UserParam.MaxTaskGenStep, UserParam.TaskGenDecelerate-CurrentTaskLoad ), 1);
            end
        end
    end
    
    
    methods
        
        function obj = JobManager(cfgRoot)
            % Calling syntax: obj = JobManager([cfgRoot])
            % Optional input cfgRoot is the FULL path to the configuration file of the job manager.
            % Default: cfgRoot = [filesep,'home','pcs','jm',ProjectName,'cfg',CFG_Filename]
            if( nargin<1 || isempty(cfgRoot) ), cfgRoot = []; end
            obj.JobManagerParam = obj.InitJobManager(cfgRoot);
            obj.UserList = obj.InitUsers();
            Msg = sprintf( '\n\n\nThe list of ACTIVE users is extracted at %s.\n\nThere are %d ACTIVE users in the system.\n\n',...
                datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM'), length(obj.UserList) );
            PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
        end
        
        
        function RunJobManager(obj)
            % Main function that runs the whole Job Manager.
            
            % Echo out starting time of running the Job Manager.
            Msg = sprintf( '\nThe JOB MANAGER for the current project started at %s.\n\n', datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
            PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
            
            RunningJobManager = 1;
            RunningUsers = 1;
            
            JMGlobalTimer = tic;   % Global timer of job manager to keep track of timing information of finished tasks.
            
            while RunningJobManager
                
                Check4NewUser = 0;
                Msg = sprintf( '\n\n\nThe list of all ACTIVE users is extracted and updated at %s.\n', datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
                PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                obj.UserList = obj.InitUsers();
                nActiveUsers = length(obj.UserList);
                Msg = sprintf( 'There are %d ACTIVE users in the system.\n\n\n', nActiveUsers );
                PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                
                if nActiveUsers>0
                    
                    while RunningUsers
                        Check4NewUser = Check4NewUser + 1;
                        for User = 1:nActiveUsers
                            CurrentUser = obj.UserList{User};
                            % [HomeRoot, Username, Extension, Version] = fileparts(CurrentUser.UserPath);
                            [Dummy, Username] = fileparts(CurrentUser.UserPath);
                            % [JobInDir, JobRunningDir, JobOutDir, TaskInDir, TaskOutDir, TempDir] = obj.SetPaths(CurrentUser.JobQueueRoot, CurrentUser.TasksRoot);
                            [JobInDir, JobRunningDir, JobOutDir, TempDir] = obj.SetPaths(CurrentUser.JobQueueRoot);
                            TaskInDir = CurrentUser.TaskInDir;
                            TaskOutDir = CurrentUser.TaskOutDir;
                            
                            %******************************************************************
                            % MONITOR THE JOB INPUT AND JOB RUNNING QUEUES/DIRECTORIES OF CURRENT USER.
                            %******************************************************************
                            
                            % Look to see if there are any old .mat files in JobRunningDir and new .mat files in JobInDir.
                            SuccessMsgRunning = sprintf( '\nCONTINUING simulation for user %s at %s by FURTHER generation of its tasks.\n\n', ...
                                Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
                            SuccessMsgIn = sprintf( '\nLAUNCHING simulation for user %s NEW job at %s.\n\n', ...
                                Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
                            NoJobMsg = sprintf( '\nNo new tasks for user %s was generated at %s. Both JobIn and JobRunning directories are emty of job files.\n\n', ...
                                Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
                            [JobDirectory, JobName] = obj.SelectInRunningJob(JobInDir, JobRunningDir, CurrentUser.MaxRunningJobs, SuccessMsgIn, SuccessMsgRunning, NoJobMsg);
                            
                            if ~isempty(JobName)
                                % Try to load the selected input job.
                                SuccessMsg = sprintf( 'Input job file %s for user %s is loaded at %s.\n\n',...
                                    JobName(1:end-4), Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
                                ErrorMsg = sprintf( ['Type-ONE Error (Job Load Error): Input job file %s of user %s could not be loaded. It will be deleted automatically.\n',...
                                        'Input job should be a .mat file containing two MATLAB structures named JobParam and JobState.'], JobName(1:end-4), Username );
                                [JobContent, SuccessFlag] = obj.LoadFile(fullfile(JobDirectory,JobName), 'JobParam', 'JobState', SuccessMsg, ErrorMsg);
                                if SuccessFlag == 1
                                    JobParam = JobContent.JobParam;
                                    JobState = JobContent.JobState;
                                else
                                    % Selected input job file was bad. Issue an error and exit loading loop.
                                    Msg = sprintf( ['ErrorType=1\r\nErrorMsg=Job Load Error: Input job file %s could not be loaded. It will be deleted automatically.',...
                                        'Input job should be a .mat file containing two MATLAB structures named JobParam and JobState.'], JobName(1:end-4) );
                                    % SuccessFlagResults = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], Msg, 'w+');
                                    obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], Msg, 'w+');
                                end
                                
                                % Delete or copy (to JobRunning directory) the selected input job file from JobIn directory.
                                if strcmpi( JobDirectory, JobInDir )
                                    if SuccessFlag ==1
                                        % Pre-process the job read from the JobIn directory.
                                        [JobParam, JobState] = obj.PreProcessJob(JobParam, JobState, CurrentUser.CodeRoot);
                                        
                                        % Put a copy of the selected input job into JobRunning directory and delete it from JobIn directory.
                                        try
                                            save( fullfile(JobRunningDir,JobName), 'JobParam', 'JobState' );
                                            SuccessMsg = sprintf( 'Input job file %s of user %s is moved from its JobIn to its JobRunning directory.\n', JobName(1:end-4), Username );
                                            PrintOut(SuccessMsg, obj.JobManagerParam.vqFlag, obj.JobManagerParam.LogFileName);
                                            obj.DeleteFile( fullfile(JobInDir,JobName) );
                                        catch
                                            save( fullfile(obj.JobManagerParam.TempJMDir,JobName), 'JobParam', 'JobState' );
                                            SuccessMsg = sprintf( 'Input job file %s of user %s is moved from its JobIn to its JobRunning directory by OS.\n', JobName(1:end-4), Username );
                                            % If could not move the selected input job file from JobIn to JobRunning directory, just issue a warning.
                                            ErrorMsg = sprintf( ['Type-ONE Warning (Job Moving Warning): Input job file %s of user %s could not be moved from the user JobIn to its JobRunning directory.\n',...
                                                'The user can delete the .mat job file manually.'], JobName(1:end-4), Username );
                                            mvSuccess = obj.MoveFile(fullfile(obj.JobManagerParam.TempJMDir,JobName), JobRunningDir, SuccessMsg, ErrorMsg);
                                            if mvSuccess == 0
                                                Msg = sprintf( ['WarningType=1\r\nWarningMsg=Input job file %s could not be moved from JobIn to JobRunning directory.',...
                                                    'The user can delete the .mat job file manually.'], JobName(1:end-4) );
                                                % SuccessFlagResults = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], Msg, 'a+');
                                                obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], Msg, 'a+');
                                            else
                                                obj.DeleteFile( fullfile(JobInDir,JobName) );
                                            end
                                        end                                        
                                        
                                    else
                                        T = obj.JobManagerParam.vqFlag;
                                        obj.JobManagerParam.vqFlag = 0;
                                        SuccessMsg = sprintf( 'Input job file %s of user %s is deleted.\n', JobName(1:end-4), Username );
                                        % If could not delete the selected input job file from JobIn directory, just issue a warning.
                                        ErrorMsg = sprintf( ['Type-TWO Warning (Job Delete Warning): Input job file %s of user %s could not be deleted from the user JobIn directory.\n',...
                                            'The user can delete the .mat job file manually.'], JobName(1:end-4), Username );
                                        obj.DeleteFile( fullfile(JobInDir,JobName), SuccessMsg, ErrorMsg );
                                        obj.JobManagerParam.vqFlag = T;
                                        % Msg = sprintf( ['WarningType=2\r\nWarningMsg=Input job file %s could not be deleted from JobIn directory.',...
                                        %     'The user can delete the .mat job file manually.'], JobName(1:end-4) );
                                        % SuccessFlagResults = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], Msg, 'a+');
                                        % obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], Msg, 'a+');
                                    end
                                end
                                
                                if SuccessFlag == 1
                                    % Determine the running time for each task.
                                    if strcmpi( JobDirectory, JobInDir )
                                        TaskMaxRunTime = CurrentUser.InitialRunTime;
                                    elseif strcmpi( JobDirectory, JobRunningDir )
                                        if isfield(JobParam, 'MaxRunTime')
                                            TaskMaxRunTime = JobParam.MaxRunTime;
                                        else
                                            TaskMaxRunTime = CurrentUser.MaxRunTime;
                                        end
                                    end
                                    
                                    % Divide the JOB into multiple TASKs.
                                    CurrentUser.TaskID = obj.DivideJob2Tasks(JobParam, JobState, CurrentUser, JobName, TaskMaxRunTime);
                                end
                                % Done!
                                Msg = sprintf( '\n\nDividing Input/Running job to tasks for user %s is done at %s. Waiting for its next job or next job division! ...\n\n',...
                                    Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
                                PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                            end
                            
                            %******************************************************************
                            % MONITOR THE TASK OUTPUT QUEUE/DIRECTORY OF CURRENT USER.
                            %******************************************************************
                            
                            % Look to see if there are any .mat files in TaskOut directory.
                            DTaskOut = dir( fullfile(TaskOutDir,[obj.JobManagerParam.ProjectName '_*.mat']) );
                            
                            if ~isempty(DTaskOut)
                                % Pick a finished task file at random.
                                TaskOutFileIndex = randint( 1, 1, [1 length(DTaskOut)]);
                                
                                % Construct the finished task filename and the corresponding JobName.
                                TaskOutFileName = DTaskOut(TaskOutFileIndex).name;
                                JobName = [TaskOutFileName( regexpi(TaskOutFileName, [obj.JobManagerParam.ProjectName '_'],'end')+1 : ...
                                    regexpi(TaskOutFileName, '_Task_') - 1) '.mat'];
                                
                                % Try to load the selected output task file.
                                SuccessMsg = sprintf( 'Output finished task file %s of user %s is loaded at %s.\n',...
                                    TaskOutFileName(1:end-4), Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
                                ErrorMsg = sprintf( ['Type-THREE Warning (Output Task Load Warning): Output task file %s of user %s could not be loaded and will be deleted automatically.\n',...
                                    'Output task should be a .mat file containing two MATLAB structures named TaskParam and TaskState.'], TaskOutFileName(1:end-4), Username );
                                % Msg = sprintf( ['WarningType=3\r\nWarningMsg=Output task file %s could not be loaded and will be deleted automatically.',...
                                %     'Output task should be a .mat file containing two MATLAB structures named TaskParam and TaskState.'], TaskOutFileName(1:end-4) );
                                % SuccessFlagResults = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], Msg, 'a+');
                                % obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], Msg, 'a+');
                                [TaskContent, TaskSuccess] = obj.LoadFile(fullfile(TaskOutDir,TaskOutFileName), 'TaskParam', 'TaskState', SuccessMsg, ErrorMsg, 'TaskInfo');
                                
                                if ~isempty(TaskContent)
                                    CurrentTime = toc(JMGlobalTimer); % Keep track of the global time at which the finished task is loaded.
                                    
                                    TaskInputParam = TaskContent.TaskParam.InputParam;
                                    TaskState = TaskContent.TaskState;
                                    TaskInfo = TaskContent.TaskInfo;
                                    % TaskInfo.Trials = TaskState.Trials(end,:);
                                    
                                    % Update completed TRIALS and required elapsed time for the corresponding NODE that has finished the task. Save Timing Info.
                                    [NodeID_Times, eTimeTrial] = obj.ExtractETimeTrial( TaskInfo, CurrentTime );
                                    try
                                        save( fullfile(TempDir,[JobName(1:end-4) '_eTimeTrial.mat']), 'eTimeTrial', 'NodeID_Times' );
                                        SuccessMsg = sprintf( 'Timing information for the NODE that has finished the task is saved for task %s and user %s.\n', TaskOutFileName(1:end-4), Username );
                                        PrintOut(SuccessMsg, obj.JobManagerParam.vqFlag, obj.JobManagerParam.LogFileName);
                                    catch
                                        save( fullfile(obj.JobManagerParam.TempJMDir,[JobName(1:end-4) '_eTimeTrial.mat']), 'eTimeTrial', 'NodeID_Times' );
                                        SuccessMsg = sprintf( 'Timing information for the NODE that has finished the task is saved for task %s and user %s by OS.\n', TaskOutFileName(1:end-4), Username );
                                        obj.MoveFile(fullfile(obj.JobManagerParam.TempJMDir,[JobName(1:end-4) '_eTimeTrial.mat']), TempDir, SuccessMsg);
                                    end
                                end
                                
                                % Delete the selected output task file from TaskOut directory.
                                % if TaskSuccess == 1
                                    SuccessMsg = sprintf( 'The selected output task file %s of user %s is deleted from its TaskOut directory.\n', TaskOutFileName(1:end-4), Username );
                                    % If could not delete output task file, just issue a warning.
                                    ErrorMsg = sprintf( ['Type-FOUR Warning (Output Task Delete Warning): Output task file %s of user %s could not be deleted',...
                                        'from user TaskOut directory.\nThe user can delete the .mat output task file manually.\n'], TaskOutFileName(1:end-4), Username );
                                    obj.DeleteFile( fullfile(TaskOutDir,TaskOutFileName), SuccessMsg, ErrorMsg );
                                    % Msg = sprintf( ['WarningType=4\r\nWarningMsg=Output task file %s could not be deleted from TaskOut directory.',...
                                    %     'The user can delete the .mat output task file manually.'], TaskOutFileName(1:end-4) );
                                    % SuccessFlagResults = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], Msg, 'a+');
                                    % obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], Msg, 'a+');
                                    PrintOut({'' ; '-'}, obj.JobManagerParam.vqFlag, obj.JobManagerParam.LogFileName);
                                % end
                                
                                % Try to load the correspoding JOB file from the user's JobRunning or JobOut directory (if it is there).

                                % If the corresponding job file in JobRunning or JobOut directory was bad or nonexistent, kick out of its loading loop.
                                % This is a method of KILLING a job.
                                successJR = 0;
                                if(TaskSuccess == 1)
                                    ErrorMsg = sprintf( ['Type-TWO Error (Invalid/Nonexistent Running or Output Job Error):',...
                                        'The corresponding job file %s of user %s could not be loaded/does not exist from/in JobRunning or JobOut directory.\n',...
                                        'All corresponding task files will be deleted from TaskIn and TaskOut directories.\n',...
                                        'Job files in JobRunning and JobOut directories should be .mat files containing two MATLAB structures named JobParam and JobState.'],...
                                        JobName(1:end-4), Username );
                                    JobDirectory = obj.FindRunningOutJob(JobRunningDir, JobOutDir, JobName, ErrorMsg);

                                    if ~isempty(JobDirectory)
                                        if strcmpi(JobDirectory,JobOutDir)
                                            Msg = sprintf( 'Finished JOB %s of user %s is updated in its JobOut directory.\n\n', JobName(1:end-4), Username );
                                            PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                                            strMsg = 'JobOut';
                                        elseif strcmpi(JobDirectory,JobRunningDir)
                                            strMsg = 'JobRunning';
                                        end

                                        SuccessMsg = sprintf( ['The corresponding job file %s of user %s is loaded from its ', strMsg, ' directory.\n'], JobName(1:end-4), Username );
                                        [JobContent, successJR] = obj.LoadFile(fullfile(JobDirectory,JobName), 'JobParam', 'JobState', SuccessMsg, ErrorMsg);
                                        if(successJR == 1)
                                            JobParam = JobContent.JobParam;
                                            JobState = JobContent.JobState;
                                            % Update JobState if the received output Task has done some trials.
%                                             if sum(TaskState.Trials(end,:))~=0
					      JobState = obj.UpdateJobState(JobState, TaskState, JobParam);
%                                             else
%                                                 Msg = sprintf( 'Task %s of user %s had done NO TRIALS.\n', TaskOutFileName(1:end-4), Username );
%                                                 PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
%                                             end
                                        end
                                    end

                                    if( (~isempty(JobDirectory) && successJR == 0) || isempty(JobDirectory) )
                                        % The corresponding job file in JobRunning or JobOut directory was bad or nonexistent. Kick out of its loading loop.
                                        % This is a method of KILLING a job.
                                        Msg = sprintf( ['ErrorType=2\r\nErrorMsg=The corresponding job file %s could not be loaded from JobRunning or JobOut directory',...
                                            'and will be deleted automatically. All corresponding task files will be deleted from TaskIn and TaskOut directories.',...
                                            'Job files in JobRunning and JobOut directories should be .mat files containing two MATLAB structures named JobParam and JobState.'],...
                                            JobName(1:end-4) );
                                        % SuccessFlagResults = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], Msg, 'w+');
                                        obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], Msg, 'w+');

                                        % Destroy/Delete any other input and output task files associated with this job from TaskIn and TaskOut directories.
                                        obj.DeleteFile( fullfile(TaskInDir, [obj.JobManagerParam.ProjectName '_' JobName(1:end-4) '_Task_*.mat']) );
                                        obj.DeleteFile( fullfile(TaskOutDir,[obj.JobManagerParam.ProjectName '_' JobName(1:end-4) '_Task_*.mat']) );
                                    end
                                end

                                if successJR == 1
                                    % Look to see if there are any more related finished .mat task files with the loaded JOB file in TaskOut directory.
                                    DTaskOut = dir( fullfile(TaskOutDir,[obj.JobManagerParam.ProjectName '_' JobName(1:end-4) '_Task_*.mat']) );
                                    
                                    for TaskOutFileIndex = 1:length(DTaskOut) % Pick finished task files one by one in order of listing.
                                        % Construct the filename.
                                        TaskOutFileName = DTaskOut(TaskOutFileIndex).name;
                                        
                                        % Try to load the selected output task file.
                                        SuccessMsg = sprintf( '\nOutput finished task file %s of user %s is loaded at %s.\n', ...
                                            TaskOutFileName(1:end-4), Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
                                        ErrorMsg = sprintf( ['Type-THREE Warning (Output Task Load Warning): Output task file %s of user %s could not be loaded and will be deleted automatically.\n',...
                                            'Output task should be a .mat file containing two MATLAB structures named TaskParam and TaskState.'], TaskOutFileName(1:end-4), Username );
                                        % Msg = sprintf( ['WarningType=3\r\nWarningMsg=Output task file %s could not be loaded and will be deleted automatically.',...
                                        %     'Output task should be a .mat file containing two MATLAB structures named TaskParam and TaskState.'], TaskOutFileName(1:end-4) );
                                        % SuccessFlagResults = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], Msg, 'a+');
                                        % obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], Msg, 'a+');
                                        [TaskContent, TaskSuccess] = obj.LoadFile(fullfile(TaskOutDir,TaskOutFileName), 'TaskParam', 'TaskState', SuccessMsg, ErrorMsg, 'TaskInfo');
                                        
                                        if ~isempty(TaskContent)
                                            CurrentTime = toc(JMGlobalTimer); % Keep track of the global time at which the finished task is loaded.
                                            
                                            TaskInputParam = TaskContent.TaskParam.InputParam;
                                            TaskState = TaskContent.TaskState;
                                            TaskInfo = TaskContent.TaskInfo;
                                            % TaskInfo.Trials = TaskState.Trials(end,:);
                                            
                                            % Update JobState if the received Task has done some trials.
%                                             if sum(TaskState.Trials(end,:))~=0
					      JobState = obj.UpdateJobState(JobState, TaskState, JobParam);
%                                             else
%                                                 Msg = sprintf( 'Task %s of user %s had done NO TRIALS.\n', TaskOutFileName(1:end-4), Username );
%                                                 PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
%                                             end
                                            
                                            % Update completed TRIALS and required elapsed time for the corresponding NODE that has finished the task. Save Timing Info.
                                            [NodeID_Times, eTimeTrial] = obj.ExtractETimeTrial( TaskInfo, CurrentTime );
                                            try
                                                save( fullfile(TempDir,[JobName(1:end-4) '_eTimeTrial.mat']), 'eTimeTrial', 'NodeID_Times' );
                                                SuccessMsg = sprintf( 'Timing information for the NODE that has finished the task is saved for task %s and user %s.\n', TaskOutFileName(1:end-4), Username );
                                                PrintOut(SuccessMsg, obj.JobManagerParam.vqFlag, obj.JobManagerParam.LogFileName);
                                            catch
                                                save( fullfile(obj.JobManagerParam.TempJMDir,[JobName(1:end-4) '_eTimeTrial.mat']), 'eTimeTrial', 'NodeID_Times' );
                                                SuccessMsg = sprintf( 'Timing information for the NODE that has finished the task is saved for task %s and user %s by OS.\n', TaskOutFileName(1:end-4), Username );
                                                obj.MoveFile(fullfile(obj.JobManagerParam.TempJMDir,[JobName(1:end-4) '_eTimeTrial.mat']), TempDir, SuccessMsg);
                                            end
                                        end
                                        
                                        % Delete the selected output task file from TaskOut directory.
                                        % if TaskSuccess == 1
                                            SuccessMsg = sprintf( 'The selected output task file %s of user %s is deleted from its TaskOut directory.\n', TaskOutFileName(1:end-4), Username );
                                            % If could not delete output task file, just issue a warning.
                                            ErrorMsg = sprintf( ['Type-FOUR Warning (Output Task Delete Warning): Output task file %s of user %s ',...
                                                'could not be deleted from user TaskOut directory.\nThe user can delete the .mat output task file manually.\n'],...
                                                TaskOutFileName(1:end-4), Username );
                                            obj.DeleteFile( fullfile(TaskOutDir,TaskOutFileName), SuccessMsg, ErrorMsg );
                                            % Msg = sprintf( ['WarningType=4\r\nWarningMsg=Output task file %s could not be deleted from TaskOut directory.',...
                                            %     'The user can delete the .mat output task file manually.'], TaskOutFileName(1:end-4) );
                                            % SuccessFlagResults = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], Msg, 'a+');
                                            % obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], Msg, 'a+');

                                            PrintOut({'' ; '-'}, obj.JobManagerParam.vqFlag, obj.JobManagerParam.LogFileName);
                                            if( rem(TaskOutFileIndex,CurrentUser.TaskInFlushRate)==0 )
                                                PrintOut('\n', 0, obj.JobManagerParam.LogFileName);
                                            end
                                        % end
                                        
                                        % Wait briefly before looping for reading the next finished task file from TaskOut directory.
                                        pause( 0.1*CurrentUser.PauseTime );
                                    end
                                    
                                    Msg = sprintf( '\n\n\nConsolidating finished tasks associated with job %s for user %s is DONE at %s!\n\n\n',...
                                        JobName, Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
                                    PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                                    
                                    if( ~isempty(JobDirectory) && strcmpi(JobDirectory,JobRunningDir) ) % The job is loaded from JobRunning directory.
                                        % Determine if the global stopping criteria have been reached/met. Moreover, determine and echo progress of running JobName.
                                        % Furthermore, update Results file.
                                        [StopFlag, JobParam] = obj.DetermineStopFlag(JobParam, JobState, JobName, Username, JobRunningDir);
                                        
                                        if ~StopFlag    % If simulation of the job JobName is NOT done, resubmit another round of tasks.
                                            % Save the result in JobRunning queue/directory.
                                            try
                                                save( fullfile(JobRunningDir,JobName), 'JobParam', 'JobState' );
                                                SuccessMsg = sprintf( 'The corresponding job file %s of user %s is updated in the JobRunning directory.\n', JobName(1:end-4), Username );
                                                PrintOut(SuccessMsg, 0, obj.JobManagerParam.LogFileName);
                                            catch
                                                save( fullfile(obj.JobManagerParam.TempJMDir,JobName), 'JobParam', 'JobState' );
                                                obj.MoveFile(fullfile(obj.JobManagerParam.TempJMDir,JobName), JobRunningDir);
                                                SuccessMsg = sprintf( 'The corresponding job file %s of user %s is updated in the JobRunning directory by OS.\n', JobName(1:end-4), Username );
                                                PrintOut(SuccessMsg, 0, obj.JobManagerParam.LogFileName);
                                            end
                                            
                                            % Limit the simulation maximum runtime of each task.
                                            if isfield(JobParam, 'MaxRunTime')
                                                TaskMaxRunTime = JobParam.MaxRunTime;
                                            else
                                                TaskMaxRunTime = CurrentUser.MaxRunTime;
                                            end
                                            
                                            % Divide the JOB into multiple TASKs.
                                            CurrentUser.TaskID = obj.DivideJob2Tasks(JobParam, JobState, CurrentUser, JobName, TaskMaxRunTime);
                                            
                                        else % If simulation of this job is done, save the result in JobOut queue/directory.
                                            try
                                                save( fullfile(JobOutDir,JobName), 'JobParam', 'JobState' );
                                                SuccessMsg = sprintf( 'The FINISHED job file %s of user %s is moved to JobOut directory.\n', JobName(1:end-4), Username );
                                                PrintOut(SuccessMsg, 0, obj.JobManagerParam.LogFileName);
                                            catch
                                                save( fullfile(obj.JobManagerParam.TempJMDir,JobName), 'JobParam', 'JobState' );
                                                obj.MoveFile(fullfile(obj.JobManagerParam.TempJMDir,JobName), JobOutDir);
                                                SuccessMsg = sprintf( 'The FINISHED job file %s of user %s is moved to JobOut directory by OS.\n', JobName(1:end-4), Username );
                                                PrintOut(SuccessMsg, 0, obj.JobManagerParam.LogFileName);
                                            end
                                            % Move all pdf files containing figures to JobOut directory.
                                            if ~isempty( dir(fullfile(JobRunningDir,[JobName(1:end-4) '*.pdf'])) )
                                                obj.MoveFile(fullfile(JobRunningDir,[JobName(1:end-4) '*.pdf']), JobOutDir);
                                            end
                                            % ChmodStr = ['chmod 666 ' FileName];   % Allow everyone to read and write to the file, FileName.
                                            % system( ChmodStr );
                                            
                                            % Remove the finished job from JobRunning queue/directory.
                                            obj.DeleteFile( fullfile(JobRunningDir,JobName) );
                                            msgStatus = sprintf( 'Done' );
                                            % SuccessFlagStatus = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Status.txt'], msgStatus, 'w+');
                                            obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Status.txt'], msgStatus, 'w+');
                                            % obj.DeleteFile( fullfile(JobRunningDir,[JobName(1:end-4) '_Results.txt']) );
                                            % obj.DeleteFile( fullfile(JobRunningDir,[JobName(1:end-4) '_Status.txt']) );
                                            
                                            % More Cleanup Needed: Any tasks associated with this job should be deleted from TaskIn directory.
                                            obj.DeleteFile( fullfile(TaskInDir,[obj.JobManagerParam.ProjectName '_' JobName(1:end-4) '_Task_*.mat']) );
                                        end
                                        
                                    elseif( ~isempty(JobDirectory) && strcmpi(JobDirectory,JobOutDir) ) % The job is loaded from JobOut directory.
                                        % Cleanup: Any tasks associated with this job should be deleted from TaskIn directory.
                                        obj.DeleteFile( fullfile(TaskInDir,[obj.JobManagerParam.ProjectName '_' JobName(1:end-4) '_Task_*.mat']) );
                                        
                                        % Save the updated final result for the job in JobOut directory.
                                        try
                                            save( fullfile(JobOutDir,JobName), 'JobParam', 'JobState' );
                                        catch
                                            save( fullfile(obj.JobManagerParam.TempJMDir,JobName), 'JobParam', 'JobState' );
                                            obj.MoveFile(fullfile(obj.JobManagerParam.TempJMDir,JobName), JobOutDir);
                                        end
                                    end
                                end
                            end
                            
                            Msg = sprintf( '\n\n\nSweeping JobIn, JobRunning, and TaskOut directories of user %s is finished at %s.\n\n\n',...
                                Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
                            PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                            % Wait briefly before looping for the next active user.
                            pause( CurrentUser.PauseTime );
                            obj.UserList{User} = CurrentUser;
                        end
                        if(Check4NewUser >= obj.JobManagerParam.Check4NewUserPeriod), break; end
                    end
                else % If there is no ACTIVE user in the system, pause briefly before looking for new users again.
                    pause(obj.JobManagerParam.JMPause);
                end
            end
        end
        
        
        function JobManagerParam = InitJobManager(obj, cfgFullFile)
            % Initialize job manager's parameters in JobManagerParam structure.
            %
            % Calling syntax: JobManagerParam = obj.InitJobManager([cfgFullFile])
            % Optional input cfgFullFile is the FULL path to the configuration file of the job manager.
            % JobManagerParam fields:
            %       ProjectName,HomeRoot,TempJMDir,Check4NewUserPeriod,JMPause,UserCfgFilename,LogFileName,vqFlag,MaxRecentTaskInfo.
            %
            % Version 1, 02/07/2011, Terry Ferrett.
            % Version 2, 01/11/2012, Mohammad Fanaei.
            % Version 3, 02/13/2012, Mohammad Fanaei.
            
            % Named constants.
            JobManagerParam = struct;
            if( nargin<2 || isempty(cfgFullFile) )
                JobManagerParam.ProjectName = input(['\nWhat is the name of the current project for which this Job Manager is running?\n',...
                    'This will be used to locate the configuration file of this Job Manager.\n\n'],'s');
                if ispc
                    cfgRoot = input('\nWhat is the FULL path to the FOLDER in which the CONFIGURATION file of this Job Manager is located?\n\n','s');
                else
                    cfgRoot = fullfile(filesep,'home','pcs','jm',JobManagerParam.ProjectName,'cfg');
                end
                CFG_Filename = input('\nWhat is the name of the CONFIGURATION file for this Job Manager?\nExample: <ProjectName>JobManager_cfg\n\n','s');
                % Find CFG_Filename file, i.e. job manager's configuration file.
                cfgFullFile = fullfile(cfgRoot, CFG_Filename);
            end
            
            cfgFileDir = dir(cfgFullFile);
            
            if( ~isempty(cfgFileDir) )
                heading1 = '[GeneralSpec]';
                
                % Read the name of the current project for which this job manager is running.
                out = util.fp(cfgFullFile, heading1, 'ProjectName'); out = out{1}{1};
                if( isempty(out) && (~isfield(JobManagerParam,'ProjectName') || isempty(JobManagerParam.ProjectName)) )
                    JobManagerParam.ProjectName = input('\nWhat is the name of the current project for which this Job Manager is running?\n\n','s');
                elseif( ~isempty(out) )
                    JobManagerParam.ProjectName = out;
                end
                
                % Read root directory in which the job manager looks for users of the system.
                out = util.fp(cfgFullFile, heading1, 'HomeRoot'); out = out{1}{1};
                if isempty(out)
                    if ispc, out = input('\nWhat is the FULL path to the HOME ROOT in which the Job Manager should look for system USERS?\n\n','s');
                    else out = [filesep 'home'];
                    end
                end
                JobManagerParam.HomeRoot = out;
                
                % Read temporary directory in which the job manager saves intermediate files before moving them to their ultimate destination.
                % This folder solves the problem of write permissions in directories of users.
                out = util.fp(cfgFullFile, heading1, 'TempJMDir'); out = out{1}{1};
                if isempty(out)
                    if ispc
                        out = input(['\nWhat is the FULL path to the TEMPORARY folder (TempJMDir) in which the Job Manager saves intermediate files\n',...
                            'before moving them to their ultimate destinations?\n\n'],'s');
                    else
                        out = fullfile(JobManagerParam.HomeRoot,'pcs','jm',JobManagerParam.ProjectName,'Temp');
                    end
                end
                JobManagerParam.TempJMDir = out;
                
                % Read period by which the job manager looks for newly-added users to the system.
                out = util.fp(cfgFullFile, heading1, 'Check4NewUserPeriod'); out = out{1}{1};
                if( isempty(out) ), out = '50'; end
                JobManagerParam.Check4NewUserPeriod = str2double(out);
                
                % Read job manager's pause time to wait before looking for new users when there is no active user in the system.
                out = util.fp(cfgFullFile, heading1, 'JMPause'); out = out{1}{1};
                if( isempty(out) ), out = '60'; end
                JobManagerParam.JMPause = str2double(out);
                
                % Read name of configuration file for each user, which stores location of JOB queues for each project (among other information).
                out = util.fp(cfgFullFile, heading1, 'UserCfgFilename'); out = out{1}{1};
                if( isempty(out) )
                    out = input(['\nWhat is the name of CONFIGURATION file for USERs?\n%',...
                        'The job manager looks for this file in the users home directories to find active users.\nExam%ple: <ProjectName>_cfg\n\n'],'s');
                end
                JobManagerParam.UserCfgFilename = out;
                
                
                heading2 = '[LogSpec]';
                
                % Read job manager's log filename.
                out = util.fp(cfgFullFile, heading2, 'LogFileName'); out = out{1}{1};
                if( isempty(out) ), out = '0'; end
                if strcmp(out, '0'), out = str2double(out); end
                JobManagerParam.LogFileName = out;
                
                % Read verbose/quiet mode of intermediate message logging.
                % If vqFlag=0 (verbose mode), all detailed intermediate messages are printed out.
                % If vqFlag=1 (quiet mode), just important intermediate messages are printed out.
                out = util.fp(cfgFullFile, heading2, 'vqFlag'); out = out{1}{1};
                if( isempty(out) ), out = '0'; end
                JobManagerParam.vqFlag = str2double(out);
                
                
                heading3 = '[eTimeTrialSpec]';
                
                % Read maximum number of recent trial numbers and processing times of each worker node saved for billing purposes.
                out = util.fp(cfgFullFile, heading3, 'MaxRecentTaskInfo'); out = out{1}{1};
                if( isempty(out) ), out = '5'; end
                JobManagerParam.MaxRecentTaskInfo = str2double(out);
            else
                if( ~isfield(JobManagerParam,'ProjectName') || isempty(JobManagerParam.ProjectName) )
                    JobManagerParam.ProjectName = input('\nWhat is the name of the current project for which this Job Manager is running?\n\n','s');
                end
                if ispc, JobManagerParam.HomeRoot = input('\nWhat is the FULL path to the HOME ROOT in which the Job Manager should look for system USERS?\n\n','s');
                else JobManagerParam.HomeRoot = [filesep 'home'];
                end
                if ispc
                    JobManagerParam.TempJMDir = input(['\nWhat is the FULL path to the TEMPORARY folder (TempJMDir) in which the Job Manager saves\n',...
                        'intermediate files before moving them to their ultimate destinations?\n\n'],'s');
                else
                    JobManagerParam.TempJMDir = fullfile(JobManagerParam.HomeRoot,'pcs','jm',JobManagerParam.ProjectName,'Temp');
                end
                JobManagerParam.Check4NewUserPeriod = 50;
                JobManagerParam.LogFileName = 0;
                % if ispc
                %     JobManagerParam.LogFileName = input('\nWhat is the FULL path (including File Name) to the LOG file for this Job Manager?\n\n','s');
                % else
                %     LogFileName = input('\nWhat is the name of the LOG file for this Job Manager?\n\n','s');
                %     JobManagerParam.LogFileName = fullfile(filesep,'rhome','pcs','jm',JobManagerParam.ProjectName,'log',LogFileName);
                % end
                JobManagerParam.vqFlag = 0;
                JobManagerParam.MaxRecentTaskInfo = 5;
            end
        end
        
        
	    function UserList = InitUsers(obj)
            % Initialize users' states in UserList structure.
            %
            % Calling syntax: UserList = obj.InitUsers()
            % UserList fields for EACH user:
            %       UserPath(Full Path),CodeRoot,JobQueueRoot,TaskInDir,TaskOutDir,(TasksRoot),FunctionName,FunctionPath,MaxInputTasks,
            %       TaskGenDecelerate,MaxTaskGenStep,TaskInFlushRate,MaxRunningJobs,InitialRunTime,MaxRunTime,PauseTime,TaskID.
            %
            % Version 1, 02/07/2011, Terry Ferrett.
            % Version 2, 01/11/2012, Mohammad Fanaei.
            
            % Named constants.
            HomeRoot = obj.JobManagerParam.HomeRoot;
            if( ~isfield(obj.JobManagerParam,'UserCfgFilename') || isempty(obj.JobManagerParam.UserCfgFilename) )
                obj.JobManagerParam.UserCfgFilename = input(['\nWhat is the name of CONFIGURATION file for USERs?\n',...
                    'The job manager looks for this file in the users home directories to find active users.\nExample: <ProjectName>_cfg\n\n'],'s');
            end
            CFG_Filename = obj.JobManagerParam.UserCfgFilename;
            
            % Perform a directory listing in HomeRoot to list ALL possible users.
            UserDirs = [];
            if iscell(HomeRoot)
                RootInd = [];
                for ll = 1:length(HomeRoot)
                    UserDirs = [UserDirs ; dir(HomeRoot{ll})];
                    RootInd = [RootInd ; ll*ones(size(dir(HomeRoot{ll})))];
                end
            else
                UserDirs = dir(HomeRoot);
            end
            
            UserList = obj.UserList;
            n = length(UserDirs);        % Number of directories found in HomeRoot.
            UserCount = length(UserList);% Counter to track number of ACTIVE users.
            
            for k = 1:n
                % Find CFG_Filename file, i.e. project configuration file of each user.
                if iscell(HomeRoot)
                    UserPath = fullfile(HomeRoot{RootInd(k)}, UserDirs(k).name);
                else
                    UserPath = fullfile(HomeRoot, UserDirs(k).name);
                end
                cfgFile = fullfile(UserPath, CFG_Filename);
                cfgFileDir = dir(cfgFile);
                
                UserFoundFlag = zeros(UserCount,1);
                for u = 1:UserCount
                    UserFoundFlag(u) = strcmpi( UserList{u}.UserPath, UserPath );
                end
                
                % If CFG_Filename (project configuration file) exists AND user is NOT already listed in UserList, read CFG_Filename.
                if( ~isempty(cfgFileDir) && (sum(UserFoundFlag)==0) )
                    UserCount = UserCount + 1;
                    
                    % Add FULL path to this user to active users list.
                    UserList{UserCount}.UserPath = UserPath;
                    
                    
                    heading1 = '[GeneralSpec]';
                    
                    % Read name and FuLL path to user's actual CODE directory.
                    % All of the code required to run user's simulations resides under this directory.
                    out = util.fp(cfgFile, heading1, 'CodeRoot'); out = out{1}{1};
                    UserList{UserCount}.CodeRoot = out;
                    
                    % Read name and FULL path to user's job queue root directory. JobIn, JobRunning, and JobOut directories are under this full path.
                    out = util.fp(cfgFile, heading1, 'JobQueueRoot'); out = out{1}{1};
                    % out = cell2mat([out{:}]);
                    if isempty(out)
                        out = fullfile(UserPath,'Projects',obj.JobManagerParam.ProjectName);
                    % else
                    % This line was commented on 08/01/2012 since this field was modified in the configuration file to not have ' at its beginning and end.
                    %     out = eval(out);
                    end
                    UserList{UserCount}.JobQueueRoot = out;
                    
                    % Read name and FULL path to user's task directory. TaskIn and TaskOut directories are under this path.
                    % out = util.fp(cfgFile, heading1, 'TasksRoot'); out = out{1}{1};
                    % out = cell2mat([out{:}]);
                    % if isempty(out)
                    %     out = fullfile(UserPath,'Tasks');
                    % else
                    %     out = eval(out);
                    % end
                    % UserList{UserCount}.TasksRoot = out;
                    
                    TaskCfgFileName = 'ctc_cfg';
                    out = util.fp( fullfile(UserPath,TaskCfgFileName), '[paths]', 'input' ); out = out{1}{1};
                    UserList{UserCount}.TaskInDir = out;
                    out = util.fp( fullfile(UserPath,TaskCfgFileName), '[paths]', 'output' ); out = out{1}{1};
                    UserList{UserCount}.TaskOutDir = out;
                    
                    % Read name and full path of function to be executed for running each task.
                    out = util.fp(cfgFile, heading1, 'FunctionName'); out = out{1}{1};
                    UserList{UserCount}.FunctionName = out;
                    
                    out = util.fp(cfgFile, heading1, 'FunctionPath'); out = out{1}{1};
                    UserList{UserCount}.FunctionPath = out;
                    
                    
                    heading2 = '[TasksInSpec]';
                    
                    % Read maximum number of input tasks in TaskIn queue/directory.
                    out = util.fp(cfgFile, heading2, 'MaxInputTasks'); out = out{1}{1};
                    if( isempty(out) ), out = '1000'; end
                    UserList{UserCount}.MaxInputTasks = str2double(out);
                    
                    % Read the number of input tasks in TaskIn queue/directory beyond which generation of new tasks is slowed down until it reaches the maximum of MaxInputTasks.
                    out = util.fp(cfgFile, heading2, 'TaskGenDecelerate'); out = out{1}{1};
                    if( isempty(out) ), out = '750'; end
                    UserList{UserCount}.TaskGenDecelerate = str2double(out);
                    
                    % Read maximum number of input tasks to be submitted to TaskIn at a time/each step.
                    out = util.fp(cfgFile, heading2, 'MaxTaskGenStep'); out = out{1}{1};
                    if( isempty(out) ), out = '60'; end
                    UserList{UserCount}.MaxTaskGenStep = str2double(out);
                    
                    % Read number of new input tasks saved in temporary directory (TempJMDir) that should be moved to TaskIn directory of user at a time.
                    out = util.fp(cfgFile, heading2, 'TaskInFlushRate'); out = out{1}{1};
                    if( isempty(out) ), out = '10'; end
                    UserList{UserCount}.TaskInFlushRate = str2double(out);
                    
                    % Read maximum number of parallel jobs running at a time.
                    out = util.fp(cfgFile, heading2, 'MaxRunningJobs'); out = out{1}{1};
                    if( isempty(out) ), out = '3'; end
                    UserList{UserCount}.MaxRunningJobs = str2double(out);
                    
                    
                    heading3 = '[RunTimeSpec]';
                    
                    % Read quick initial running time of each task to quickly get initial results back.
                    out = util.fp(cfgFile, heading3, 'InitialRunTime'); out = out{1}{1};
                    if( isempty(out) ), out = '60'; end
                    UserList{UserCount}.InitialRunTime = str2double(out);
                    
                    % Read longer running time of each task in the long term.
                    out = util.fp(cfgFile, heading3, 'MaxRunTime'); out = out{1}{1};
                    if( isempty(out) ), out = '300'; end
                    UserList{UserCount}.MaxRunTime = str2double(out);
                    
                    % Read pause time to wait between task submissions and flow control.
                    out = util.fp(cfgFile, heading3, 'PauseTime'); out = out{1}{1};
                    if( isempty(out) ), out = '0.1'; end
                    UserList{UserCount}.PauseTime = str2double(out);
                    
                    % Reset the task ID counter.
                    UserList{UserCount}.TaskID = 0;
                % If user is already listed in UserList but its CFG_Filename (project configuration file) does not exist anymore, remove user from list.
                elseif( (sum(UserFoundFlag)~=0) && isempty(cfgFileDir) )
                    UserList(UserFoundFlag == 1) = [];
                    UserCount = UserCount - sum(UserFoundFlag);
                end
            end
        end
        
        
        function [JobDirectory, JobName] = SelectInRunningJob(obj, JobInDir, JobRunningDir, MaxRunningJobs, SuccessMsgIn, SuccessMsgRunning, NoJobMsg)
        % Pick a job from JobIn or JobRunning directory and return its directory and its name.
        %
        % Calling syntax: [JobDirectory, JobName] = obj.SelectInRunningJob(JobInDir, JobRunningDir, MaxRunningJobs [,SuccessMsgIn] [,SuccessMsgRunning] [,NoJobMsg])
        % MaxRunningJobs is a POSITIVE maximum number of simultaneously-running jobs.
            DIn = dir( fullfile(JobInDir,'*.mat') );
            DRunning = dir( fullfile(JobRunningDir,'*.mat') );
            
            if( length(DRunning) >= MaxRunningJobs )
                % Pick a running job AT RANDOM.
                JobDirectory = JobRunningDir;
                JobFileIndex = randint( 1, 1, [1 length(DRunning)]);
                % Construct the filename.
                JobName = DRunning(JobFileIndex).name;
                if( nargin>=6 && ~isempty(SuccessMsgRunning) )
                    Msg = [SuccessMsgRunning sprintf('Selected JOB name: %s.\n', JobName(1:end-4))];
                    PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                end
            else
                if ~isempty(DIn)
                    % Pick the OLDEST new job.
                    JobDirectory = JobInDir;
                    [Dummy, DateIndx] = sort( [DIn(:).datenum], 'ascend' );
                    JobFileIndex = DateIndx(1);
                    % Construct the filename.
                    JobName = DIn(JobFileIndex).name;
                    if( nargin>=5 && ~isempty(SuccessMsgIn) )
                        Msg = [SuccessMsgIn sprintf('Selected JOB name: %s.\n', JobName(1:end-4))];
                        PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                    end
                elseif ~isempty(DRunning)
                    % Pick a running job AT RANDOM.
                    JobDirectory = JobRunningDir;
                    JobFileIndex = randint( 1, 1, [1 length(DRunning)]);
                    % Construct the filename.
                    JobName = DRunning(JobFileIndex).name;
                    if( nargin>=6 && ~isempty(SuccessMsgRunning) )
                        Msg = [SuccessMsgRunning sprintf('Selected JOB name: %s.\n', JobName(1:end-4))];
                        PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                    end
                else
                    JobDirectory = [];
                    JobName = [];
                    if( nargin>=7 && ~isempty(NoJobMsg) )
                        PrintOut(NoJobMsg, 0, obj.JobManagerParam.LogFileName);
                    end
                end
            end
        end
        
        
        function JobDirectory = FindRunningOutJob(obj, JobRunningDir, JobOutDir, JobName, ErrorMsg)
            % Calling syntax: JobDirectory = obj.FindRunningOutJob(JobRunningDir, JobOutDir, JobName [,ErrorMsg])
            
            DRunning = dir( fullfile(JobRunningDir,JobName) );
            DOut = dir( fullfile(JobOutDir,JobName) );
            
            if ~isempty(DRunning)
                JobDirectory = JobRunningDir;
            elseif ~isempty(DOut)
                JobDirectory = JobOutDir;
            else
                JobDirectory = [];
                if( nargin>=5 && ~isempty(ErrorMsg) )
                    PrintOut(ErrorMsg, 0, obj.JobManagerParam.LogFileName);
                end
            end
        end
        
        
        function [NodeID_Times, eTimeTrial] = ExtractETimeTrial( obj, TaskInfo, CurrentTime )
            % This function is designed for billing purposes.
            % NodeID_Times is a vector structure with two fields:
            % NodeID and NumNodeTaskInfo (how many times that specific node has generated TaskInfo (run simulations)).
            % The length of this structure is equal to the number of active nodes (NumNode).
            %
            % eTimeTrial is a 3-by-MaxRecentTaskInfo-by-NumNode matrix.
            % Its first row contains the time calculated globally from the start of the job manager until receiving curret consumed task from TaskOut directory.
            % Its second row contains elapsed times in current task at the worker and its third row contains the number of trials completed during the eTime at the worker.
            
            MaxRecentTaskInfo = obj.JobManagerParam.MaxRecentTaskInfo;
            NodeID_Times = obj.NodeID_Times;
            eTimeTrial = obj.eTimeTrial;
            
            % Check to see if the NodeID has already been registered in NodeID_Times.
            NumNode = length(NodeID_Times);
            IndT = zeros(NumNode,1);
            for Node = 1:NumNode
                % IndT(Node) = strcmpi( num2str(NodeID_Times(Node).NodeID), TaskInfo.NodeID );
                IndT(Node) = strcmpi( num2str(NodeID_Times(Node).NodeID), TaskInfo.HostName );
            end
            
            Ind = find(IndT~=0,1,'first');
            if isempty(Ind) % This is a new NodeID. Add it to the list of NodeID_Times.
                NodeID_Times = [NodeID_Times ; struct('NodeID',TaskInfo.HostName, 'NumNodeTaskInfo',1)];
                Ind = length(NodeID_Times);
                eTimeTrial = cat(3,eTimeTrial,zeros(3,MaxRecentTaskInfo));
            else            % This NodeID has already been registered in NodeID_Times.
                NodeID_Times(Ind).NumNodeTaskInfo = NodeID_Times(Ind).NumNodeTaskInfo + 1;
            end
            
            if NodeID_Times(Ind).NumNodeTaskInfo <= MaxRecentTaskInfo
                ColPos = NodeID_Times(Ind).NumNodeTaskInfo;
            else
                % Note that the first row of eTimeTrial is cumulative time from the start of the job manager.
                eTimeTrial(2:end,2,:) = eTimeTrial(2:end,1,:) + eTimeTrial(2:end,2,:);
                eTimeTrial = circshift(eTimeTrial, [0 -1 0]);
                ColPos = size(eTimeTrial,2);
            end
            
%             eTimeTrial(:,ColPos,Ind) = [CurrentTime
%                 etime(TaskInfo.StopTime, TaskInfo.StartTime)
%                 sum(TaskInfo.Trials(end,:))];
            eTimeTrial(1:2,ColPos,Ind) = [CurrentTime
                etime(TaskInfo.StopTime, TaskInfo.StartTime)];
            
            obj.NodeID_Times = NodeID_Times;
            obj.eTimeTrial = eTimeTrial;
            
            eTimeTrial( :,all(all(eTimeTrial==0,1),3),: ) = [];
        end
        
        
        function DeleteFile(obj, FullFileName, SuccessMsg, ErrorMsg)
            % Calling Syntax: obj.DeleteFile(FullFileName [,SuccessMsg] [,ErrorMsg])
            try
                RmStr = ['sudo rm ' FullFileName];
                sysStatus = system( RmStr );
                if sysStatus==0     % Successful deletion of FullFileName.
                    if( (nargin>=3) && ~isempty(SuccessMsg) )
                        PrintOut(SuccessMsg, obj.JobManagerParam.vqFlag, obj.JobManagerParam.LogFileName);
                    end
                else
                    delete( FullFileName );
                    if( (nargin>=3) && ~isempty(SuccessMsg) )
                        PrintOut(SuccessMsg, obj.JobManagerParam.vqFlag, obj.JobManagerParam.LogFileName);
                    end
                end
            catch % Unsuccessful deletion of FullFileName.
                if( (nargin>=4) && ~isempty(ErrorMsg) )
                    PrintOut(ErrorMsg, 0, obj.JobManagerParam.LogFileName);
                end
            end
        end
        
        
        function [FileContent, SuccessFlag] = LoadFile(obj, FullFileName, FieldA, FieldB, SuccessMsg, ErrorMsg, FieldC)
            % Calling Syntax: [FileContent, SuccessFlag] = obj.LoadFile(FullFileName, FieldA, FieldB [,SuccessMsg] [,ErrorMsg] [,FieldC])
            % FieldC is only used for loading TASK files.
            SuccessFlag = 0;
            if( nargin<7 || isempty(FieldC) )
                try
                    FileContent = load( FullFileName, FieldA, FieldB );
                    if( isfield(FileContent,FieldA) && isfield(FileContent,FieldB) )
                        SuccessFlag = 1;
                    end
                catch
                end
            else
                try
                    FileContent = load( FullFileName, FieldA, FieldB, FieldC );
                    if( isfield(FileContent,FieldA) && isfield(FileContent,FieldB) && isfield(FileContent,FieldC) )
                        SuccessFlag = 1;
                    end
                catch
                end
            end
            if( (SuccessFlag == 1) && nargin>=5 && ~isempty(SuccessMsg) )
                PrintOut(SuccessMsg, obj.JobManagerParam.vqFlag, obj.JobManagerParam.LogFileName);
            elseif(SuccessFlag == 0) % FullFileName was bad, kick out of loading loop.
                FileContent = [];
                if( nargin>=6 && ~isempty(ErrorMsg) )
                    PrintOut(ErrorMsg, 0, obj.JobManagerParam.LogFileName);
                end
            end
        end
        
        
        function SuccessFlag = MoveFile(obj, FullFileName, FullDestination, SuccessMsg, ErrorMsg)
            % Calling Syntax: SuccessFlag = obj.MoveFile(FullFileName, FullDestination [,SuccessMsg] [,ErrorMsg])
            [mvStatus,mvMsg] = movefile(FullFileName, FullDestination, 'f');
            if( (mvStatus==1) && isempty(mvMsg) ) % Successful moving of FullFileName to FullDestination.
                SuccessFlag = 1;
                if( nargin>=4 && ~isempty(SuccessMsg) )
                    PrintOut(SuccessMsg, obj.JobManagerParam.vqFlag, obj.JobManagerParam.LogFileName);
                end
            else % Unsuccessful moving of FullFileName to FullDestination using MATLAB's built-in movefile function.
                MvStr = ['sudo mv ' FullFileName ' ' FullDestination];
                sysStatus = system( MvStr );
                if sysStatus==0 % Successful moving of FullFileName to FullDestination by OS.
                    SuccessFlag = 1;
                    if( nargin>=4 && ~isempty(SuccessMsg) )
                        PrintOut(SuccessMsg, obj.JobManagerParam.vqFlag, obj.JobManagerParam.LogFileName);
                    end
                else % Unsuccessful moving of FullFileName to FullDestination by both MATLAB and OS.
                    SuccessFlag = 0;
                    if( nargin>=5 && ~isempty(ErrorMsg) )
                        PrintOut(ErrorMsg, 0, obj.JobManagerParam.LogFileName);
                    end
                end
            end
        end
        
        
        function SuccessFlag = UpdateResultsStatusFile(obj, FileDestination, FileName, Msg, fopenPerm)
            % Calling syntax: SuccessFlag = obj.UpdateResultsStatusFile(FileDestination, FileName, Msg [,fopenPerm])
            % If fopenPerm = 'w+', it opens or creates FileName for reading and writing. Discard existing contents.
            % If fopenPerm = 'a+', it opens or creates FileName for reading and writing. Append data to the end of FileName.
            if( nargin<5 || isempty(fopenPerm) ), fopenPerm = 'w+'; end
            FileFullPath = fullfile(obj.JobManagerParam.TempJMDir,FileName);
            FID_RSFile = fopen(FileFullPath, fopenPerm);
            fprintf( FID_RSFile, Msg );
            fclose(FID_RSFile);
            % SuccessFlag = obj.MoveFile(FileFullPath, FileDestination, SuccessMsg, ErrorMsg);
            SuccessFlag = obj.MoveFile(FileFullPath, FileDestination);
        end


        function FinalTaskID = SaveTaskInFiles(obj, TaskInputParam, UserParam, JobName, TaskMaxRunTime)
            % TaskInputParam is NumNewTasks-by-1 vector of structures each one of them associated with one TaskInputParam.
            if( nargin<5 || isempty(TaskMaxRunTime) ), TaskMaxRunTime = UserParam.MaxRunTime; end

            % TaskInDir = fullfile(UserParam.TasksRoot,'TaskIn');
            TaskInDir = UserParam.TaskInDir;
            % [HomeRoot, Username, Extension, Version] = fileparts(UserParam.UserPath);
            [Dummy, Username] = fileparts(UserParam.UserPath);
            OS_flag = 0;

            TaskParam = struct(...
                'FunctionName', UserParam.FunctionName,...
                'FunctionPath', UserParam.FunctionPath,...
                'InputParam', []);

            % Submit each task one-by-one. Make sure that each task has a unique name.
            for TaskCount=1:length(TaskInputParam)
                % Increment TaskID counter.
                UserParam.TaskID = UserParam.TaskID + 1;
                TaskInputParam(TaskCount).MaxRunTime = TaskMaxRunTime;
                TaskInputParam(TaskCount).RandSeed = mod(UserParam.TaskID*sum(clock), 2^32);

                TaskParam.InputParam = TaskInputParam(TaskCount);

                % Create the name of the new task, which includes the job name.
                TaskName = [obj.JobManagerParam.ProjectName '_' JobName(1:end-4) '_Task_' int2str(UserParam.TaskID) '.mat'];

                % Save the new task in TaskIn queue/directory.
                MsgQuiet = '+';
                try
                    save( fullfile(TaskInDir,TaskName), 'TaskParam' );
                    MsgVerbose = sprintf( 'Task file %s for user %s is saved to its TaskIn directory.\n', TaskName(1:end-4), Username );
                    PrintOut({MsgVerbose ; MsgQuiet}, obj.JobManagerParam.vqFlag, obj.JobManagerParam.LogFileName);
                catch
                    save( fullfile(obj.JobManagerParam.TempJMDir,TaskName), 'TaskParam' );
                    MsgVerbose = sprintf( 'Task file %s for user %s is saved to its TaskIn directory by OS.\n', TaskName(1:end-4), Username );
                    PrintOut({MsgVerbose ; MsgQuiet}, obj.JobManagerParam.vqFlag, obj.JobManagerParam.LogFileName);
                    OS_flag = 1;
                end

                if( rem(TaskCount,UserParam.TaskInFlushRate) == 0 )
                    PrintOut('\n', 0, obj.JobManagerParam.LogFileName);
                    if OS_flag ==1
                        % SuccessFlag = obj.MoveFile(fullfile(obj.JobManagerParam.TempJMDir,'*.mat'), TaskInDir, SuccessMsg, ErrorMsg);
                        obj.MoveFile(fullfile(obj.JobManagerParam.TempJMDir,[obj.JobManagerParam.ProjectName '_' JobName(1:end-4) '_Task_*.mat']), TaskInDir);
                        OS_flag = 0;
                    end
                end

                % Pause briefly for flow control.
                pause( UserParam.PauseTime );
            end
            PrintOut('\n', 0, obj.JobManagerParam.LogFileName);
            if OS_flag == 1
                % SuccessFlag = obj.MoveFile(fullfile(obj.JobManagerParam.TempJMDir,[obj.JobManagerParam.ProjectName '_' JobName(1:end-4) '_Task_*.mat']), TaskInDir, SuccessMsg, ErrorMsg);
                obj.MoveFile(fullfile(obj.JobManagerParam.TempJMDir,[obj.JobManagerParam.ProjectName '_' JobName(1:end-4) '_Task_*.mat']), TaskInDir);
            end
            FinalTaskID = UserParam.TaskID;
        end
        
        
        function FinalTaskID = DivideJob2Tasks(obj, JobParam, JobState, UserParam, JobName, TaskMaxRunTime)
            % Divide the JOB into multiple TASKs.
            % Calling syntax: obj.DivideJob2Tasks(JobParam, JobState, UserParam, JobName [,TaskMaxRunTime])
            if( nargin<6 || isempty(TaskMaxRunTime) )
                if isfield(JobParam, 'MaxRunTime')
                    TaskMaxRunTime = JobParam.MaxRunTime;
                else
                    TaskMaxRunTime = UserParam.MaxRunTime;
                end
            end
            FinalTaskID = UserParam.TaskID;

            % [HomeRoot, Username, Extension, Version] = fileparts(UserParam.UserPath);
            [Dummy, Username] = fileparts(UserParam.UserPath);

            % Determine the number of new tasks to be generated for the current user.
            NumNewTasks = obj.FindNumNewTasks(UserParam);
            
            if NumNewTasks > 0
                Msg = sprintf( 'Generating %d NEW TASK files corresponding to JOB %s of user %s and saving them to its TaskIn directory at %s.\n\n',...
                    NumNewTasks, JobName(1:end-4), Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
                PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                
                % Calculate TaskInputParam vector for NumNewTasks new input tasks.
                TaskInputParam = obj.CalcTaskInputParam(JobParam, JobState, NumNewTasks);
                if( (length(TaskInputParam) == 1) && (NumNewTasks ~= 1) )
                    TaskInputParam = repmat(TaskInputParam, NumNewTasks, 1);
                end
                if ~isempty(TaskInputParam)
                    % Save new task files.
                    FinalTaskID = obj.SaveTaskInFiles(TaskInputParam, UserParam, JobName, TaskMaxRunTime);
                end
            else    % TaskInDir of the current user is full. No new tasks will be generated.
                Msg = sprintf('No new task is generated for user %s since its TaskIn directory is full.\n', Username);
                PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
            end
        end
    end
end
