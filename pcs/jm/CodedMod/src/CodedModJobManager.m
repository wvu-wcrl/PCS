function CodedModJobManager(HomeRootIn)
% Coded-Modulation Simulation Job Manager.

if( nargin<1 || isempty(HomeRootIn) ), HomeRootIn = []; end

Check4NewUserPeriod = 50;
UserListPrimary = [];


ClusterGlobalTimer = tic;   % Global timer of job manager to keep track of timing information of finished tasks.

NodeID_TimesIn = [];
eTimeTrialIn = [];

% Echo out starting time of running coded-modulation simulation job manager.
msg = sprintf( '\nCoded-modulation simulation JOB MANAGER started at %s.\n\n', datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
fprintf( msg );

runningJob = 1;
running = 1;

while(runningJob)
    Check4NewUser = 0;
    msg = sprintf( '\n\n\nThe list of ACTIVE users is extracted and updated at %s.\n\n\n', datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
    fprintf( msg );
    UserList = InitUsers(HomeRootIn,UserListPrimary);
    nActiveUsers = length(UserList);
    
    if ~isempty(UserList)
    
    while(running)
    Check4NewUser = Check4NewUser + 1;
    for User = 1:nActiveUsers
        CurrentUser = UserList{User};
        
        UserRoot = CurrentUser.UserPath;
        % [HomePath, Username, Extension, Version] = fileparts(UserRoot);
        [HomeUserPath, Username] = fileparts(UserRoot);
        
        [JobInDir, JobRunningDir, JobOutDir, TaskInDir, TaskOutDir, TempDir] = SetPaths(UserRoot);

        % MONITOR THE JOB INPUT AND JOB RUNNING QUEUES/DIRECTORIES OF CURRENT USER.
        MaxRunningJobs = CurrentUser.MaxRunningJobs;
        % Look to see if there are any old .mat files in JobRunningDir and new .mat files in JobInDir.
        [InFileName, JobDirectory] = SweepJobInRunDir(JobInDir, JobRunningDir, Username, MaxRunningJobs);
        
        if ~isempty(InFileName)

            % Try to load the selected input job.
            try
                load( fullfile(JobDirectory,InFileName), 'SimParam', 'SimState' );
                % Reassign variables as Global.
                SimParamGlobal = SimParam;
                SimStateGlobal = SimState;
                msg = sprintf( 'Input job file %s for user %s is loaded at %s.\n\n', InFileName(1:end-4), Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
                fprintf( msg );
                success = 1;
            catch
                % Selected input job file was bad, kick out of loading loop.
                msg = sprintf( 'Job Load Error: Input job file %s of user %s could not be loaded. It will be deleted automatically.\n', InFileName(1:end-4), Username );
                fprintf( msg );
                success = 0;
                FID_ErrorLoad = fopen( fullfile(JobOutDir,[InFileName(1:end-4) '_Error_JobLoad.txt']), 'a+');
                msg = sprintf( ['Job Load Error: Input job file \t %s \t of user \t %s \t could not be loaded. It will be deleted automatically.\n',...
                    'Input job should be a .mat file containing two MATLAB structures named SimParam and SimState.'], InFileName(1:end-4), Username );
                fprintf( FID_ErrorLoad, msg );
                fclose(FID_ErrorLoad);
            end

            % Delete or move (to JobRunning directory) the selected input job file from JobIn directory.
            if strcmpi( JobDirectory, JobInDir )
                if(success) % Put a copy of the selected input job into JobRunning directory.
                    try
                        try
                            MvStr = ['sudo mv ' JobInDir filesep InFileName ' ' JobRunningDir];
                            try
                                system( MvStr );
                                msg = sprintf( 'Input job file %s of user %s is moved from its JobIn to its JobRunning directory by OS.\n', InFileName(1:end-4), Username );
                                fprintf( msg );
                            catch
                            end
                        catch
                            movefile(fullfile(JobInDir,InFileName), JobRunningDir, 'f');
                            msg = sprintf( 'Input job file %s of user %s is moved from its JobIn to its JobRunning directory.\n', InFileName(1:end-4), Username );
                            fprintf( msg );
                        end
                    catch
                        % If could not move the selected input job file from JobIn to JobRunning directory, just issue a warning.
                        msg = sprintf( 'Job Moving Error/Warning: Input job file %s of user %s could not be moved from its JobIn to its JobRunning directory.\n', InFileName(1:end-4), Username );
                        fprintf( msg );
                        FID_ErrorDel = fopen( fullfile(JobOutDir,[InFileName(1:end-4) '_Error_JobMove.txt']), 'a+');
                        msg = sprintf( ['Job Moving Error/Warning: Input job file \t %s \t of user \t %s \t could not be moved from the user JobIn directory to its JobRunning directory.\n',...
                            'The user can delete the .mat job file manually.'], InFileName(1:end-4), Username );
                        fprintf( FID_ErrorDel, msg );
                        fclose(FID_ErrorDel);
                    end
                else
                    try
                        try
                            RmStr = ['sudo rm ' JobInDir filesep InFileName];
                            try
                                system( RmStr );
                                msg = sprintf( 'Input job file %s of user %s is deleted by OS.\n', InFileName(1:end-4), Username );
                                fprintf( msg );
                            catch
                            end
                        catch
                            delete( fullfile(JobInDir,InFileName) );
                            msg = sprintf( 'Input job file %s of user %s is deleted.\n', InFileName(1:end-4), Username );
                            fprintf( msg );
                        end
                    catch
                        % If could not delete the selected input job file from JobIn directory, just issue a warning.
                        msg = sprintf( 'Job Delete Error/Warning: Input job file %s of user %s could not be deleted.\n', InFileName(1:end-4), Username );
                        fprintf( msg );
                        FID_ErrorDel = fopen( fullfile(JobOutDir,[InFileName(1:end-4) '_Error_JobDel.txt']), 'a+');
                        msg = sprintf( ['Job Delete Error/Warning: Input job file \t %s \t of user \t %s \t could not be deleted from the user JobIn directory.\n',...
                            'The user can delete the .mat job file manually.'], InFileName(1:end-4), Username );
                        fprintf( FID_ErrorDel, msg );
                        fclose(FID_ErrorDel);
                    end
                end
            end

            if(success)
                SimParamLocal = UpdateSimParamLocal(SimParamGlobal, SimStateGlobal);
                
                % Update the local simulation time.
                if strcmpi( JobDirectory, JobInDir )
                    SimTime = CurrentUser.InitialSimTime;
                elseif strcmpi( JobDirectory, JobRunningDir )
                    SimTime = CurrentUser.SimTime;
                end
                
                % Divide the JOB into multiple TASKs.
                FinalTaskID = DivideJob2Tasks(InFileName, CurrentUser, SimParamLocal, SimTime);
                
                CurrentUser.TaskID = FinalTaskID;
            end
            % Done!
            msg = sprintf( '\n\nDividing job to tasks for user %s is done at %s. Waiting for its next job or next job division! ...\n\n',...
                Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
            fprintf( msg );
        end
        
        % MONITOR THE TASK OUTPUT QUEUE/DIRECTORY OF CURRENT USER.

        % Look to see if there are any .mat files in TaskOut directory.
        D = dir( fullfile(TaskOutDir,'*.mat') );
        
        if ~isempty(D)
            % Pick a finished task file at random.
            OutFileIndex = randint( 1, 1, [1 length(D)]);

            % Construct the filename.
            OutFileName = D(OutFileIndex).name;

            msg = sprintf( '\nReceiving finished task %s of user %s at %s.\n', OutFileName(1:end-4), Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
            % fprintf( msg );
            PrintOut( msg );
            
            JobFileName = [OutFileName(1:regexpi(OutFileName, '_task_') - 1) '.mat'];
            
            % Try to load the selected output task file.
            [TaskContent, success] = LoadFile(OutFileName, TaskOutDir, Username, 'TaskParam', 'TaskState', JobOutDir, JobFileName);
            
            CurrentTime = toc(ClusterGlobalTimer); % Keep track of the global time at which the finished task is read.
            
            % Reassign variables as Local.
            SimParamLocal = TaskContent.TaskParam.InputParam;
            SimStateLocal = TaskContent.TaskState;

            if ~isempty(SimStateLocal)
                % Update completed TRIALS and required elapsed time for the corresponding NODE that has finished the task. Save timing info.
                [eTimeTrial, NodeID_Times] = ExtractETimeTrial( SimStateLocal, NodeID_TimesIn, eTimeTrialIn, CurrentTime );
                eTimeTrialIn = eTimeTrial;
                NodeID_TimesIn = NodeID_Times;
                
                eTimeTrial( :,all(all(eTimeTrial==0,1),3),: ) = [];
                
                try
                    save( fullfile(TempDir,[JobFileName(1:end-4) '_eTimeTrial.mat']), 'eTimeTrial', 'NodeID_Times' );
                    msg = sprintf( 'Timing information for the NODE that has finished the task is saved for task %s and user %s.\n', OutFileName(1:end-4), Username );
                    % fprintf( msg );
                    PrintOut( msg );
                catch
                    TempfileName = JM_Save([JobFileName(1:end-4) '_eTimeTrial.mat'], eTimeTrial, NodeID_Times);
                    JM_Move(TempfileName, TempDir);
                    msg = sprintf( 'Timing information for the NODE that has finished the task is saved for task %s and user %s by OS.\n', OutFileName(1:end-4), Username );
                    % fprintf( msg );
                    PrintOut( msg );
                end
            end
            
            % Delete the selected output task file from TaskOut directory.
            % if(success)
            DeleteFile(OutFileName, TaskOutDir, Username, JobOutDir, JobFileName);
            fprintf('\n');
            % end
            
            % Try to load the correspoding JOB file from the JobRunning (or JobOut) directory (if it is there).
            JobDirectory = SweepJobRunOutDir(JobRunningDir, JobOutDir, JobFileName);
            if( ~isempty(JobDirectory) && strcmpi(JobDirectory,JobOutDir) )
                msg = sprintf( 'Finished JOB %s of user %s is updated in its JobOut directory.\n\n', JobFileName(1:end-4), Username );
                fprintf( msg );
                strMsg = 'JobOut';
            elseif( ~isempty(JobDirectory) && strcmpi(JobDirectory,JobRunningDir) )
                strMsg = 'JobRunning';
            end
            
            if(success)
                try
                    if ~isempty(JobDirectory)
                        load( fullfile(JobDirectory,JobFileName), 'SimParam', 'SimState' );
                        msg = sprintf( ['The corresponding job file %s of user %s is loaded from its ', strMsg, ' directory.\n'], JobFileName(1:end-4), Username );
                        % fprintf( msg );
                        PrintOut( msg );

                        % Reassign variables as Global.
                        SimParamGlobal = SimParam;
                        SimStateGlobal = SimState;

                        successJR = 1;

                        % Update the Global SimState.
                        SimStateGlobal = UpdateSimStateGlobal(SimStateGlobal, SimStateLocal);
                    else
                        error('CodedModJobManager:LoadRJob', 'Job file could not be loaded from either JobRunning or JobOut directory.');
                    end
                catch
                    % The corresponding job file in JobRunning directory was bad or nonexistent, kick out of its loading loop.
                    % This is a method of killing a job.
                    msg = sprintf( 'Running Job Load Error: The corresponding job file %s of user %s could not be loaded from its JobRunning directory.\n',...
                        JobFileName(1:end-4), Username );
                    fprintf( msg );
                    
                    FID_ErrorRunningJobLoad = fopen( fullfile(JobOutDir,[JobFileName(1:end-4) '_Error_RunningJobLoad.txt']), 'a+');
                    msg = sprintf( ['Running Job Load Error: The corresponding job file \t %s \t of user \t %s \t could not be loaded from its JobRunning directory\n',...
                        'and will be deleted automatically. All corresponding task files will be deleted from TaskIn and TaskOut directories.\n',...
                        'Job files in JobRunning directory should be .mat files containing two MATLAB structures named SimParam and SimState.'],...
                        JobFileName(1:end-4), Username );
                    fprintf( FID_ErrorRunningJobLoad, msg );
                    fclose(FID_ErrorRunningJobLoad);

                    % Destroy any other task files related to this job.
                    % More Cleanup: Any tasks associated with this job should be deleted from TaskIn directory.
                    try
                        RmStr = ['sudo rm ' TaskInDir filesep JobFileName(1:end-4) '_task_*.mat' ];
                        try system( RmStr ); catch end
                    catch
                        delete( fullfile(TaskInDir,[JobFileName(1:end-4) '_task_*.mat']) );
                    end

                    % Some more associated output tasks could arrive in TaskOut directory. They should also be deleted.
                    try
                        RmStr = ['sudo rm ' TaskOutDir filesep JobFileName(1:end-4) '_task_*.mat' ];
                        try system( RmStr ); catch end
                    catch
                        delete( fullfile(TaskOutDir,[JobFileName(1:end-4) '_task_*.mat']) );
                    end

                    successJR = 0;
                end
            end
            
            if (successJR)
                % Look to see if there are any more related finished .mat task files in TaskOut directory.
                D = dir( fullfile(TaskOutDir,[JobFileName(1:end-4) '_task_*.mat']) );

                for OutFileIndex = 1:length(D) % Pick finished task files one by one in order of listing.
                    % Construct the filename.
                    OutFileName = D(OutFileIndex).name;

                    msg = sprintf( '\nReceiving finished task %s of user %s at %s.\n', OutFileName(1:end-4), Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
                    % fprintf( msg );
                    PrintOut( msg );

                    % Try to load the selected output task file.
                    % [TaskContent, success] = LoadFile(OutFileName, TaskOutDir, Username, 'TaskParam', 'TaskState', JobOutDir, JobFileName);
                    TaskContent = LoadFile(OutFileName, TaskOutDir, Username, 'TaskParam', 'TaskState', JobOutDir, JobFileName);
                    
                    CurrentTime = toc(ClusterGlobalTimer); % Keep track of the global time at which the finished task is read.
                    
                    % Reassign variables as Local.
                    SimParamLocal = TaskContent.TaskParam.InputParam;
                    SimStateLocal = TaskContent.TaskState;

                    if ~isempty(SimStateLocal)
                        % Update completed TRIALS and required elapsed time for the corresponding NODE that has finished the task. Save timing info.
                        [eTimeTrial, NodeID_Times] = ExtractETimeTrial( SimStateLocal, NodeID_TimesIn, eTimeTrialIn, CurrentTime );
                        eTimeTrialIn = eTimeTrial;
                        NodeID_TimesIn = NodeID_Times;
                        
                        eTimeTrial( :,all(all(eTimeTrial==0,1),3),: ) = [];

                        try
                            save( fullfile(TempDir,[JobFileName(1:end-4) '_eTimeTrial.mat']), 'eTimeTrial', 'NodeID_Times' );
                            msg = sprintf( 'Timing information for the NODE that has finished the task is saved for task %s and user %s.\n', OutFileName(1:end-4), Username );
                            % fprintf( msg );
                            PrintOut( msg );
                        catch
                            TempfileName = JM_Save([JobFileName(1:end-4) '_eTimeTrial.mat'], eTimeTrial, NodeID_Times);
                            JM_Move(TempfileName, TempDir);
                            msg = sprintf( 'Timing information for the NODE that has finished the task is saved for task %s and user %s by OS.\n', OutFileName(1:end-4), Username );
                            % fprintf( msg );
                            PrintOut( msg );
                        end
                    end

                    % Delete the selected output task file from TaskOut directory.
                    % if(success)
                    DeleteFile(OutFileName, TaskOutDir, Username, JobOutDir, JobFileName);
                    if( rem(OutFileIndex,5)==0 ), fprintf( '\n' ); end
                    % end
                    
                    % Update the Global SimState.
                    SimStateGlobal = UpdateSimStateGlobal(SimStateGlobal, SimStateLocal);
                    
                    % Wait before looping for reading the next finished task file in TaskOut directory.
                    pause( CurrentUser.PauseTime );
                end
                
                msg = sprintf( '\n\nConsolidating finished tasks associated with job %s for user %s is done at %s. \n\n',...
                    JobFileName, Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
                fprintf( msg );
                
                if( ~isempty(JobDirectory) && strcmpi(JobDirectory,JobRunningDir) ) % The job is read from JobRunning directory.
                
                % See if the global stopping criteria have been reached.

                % First check to see if minimum number of trials or frame errors has been reached.
                RemainingTrials = SimParamGlobal.MaxTrials - SimStateGlobal.Trials;
                RemainingTrials(RemainingTrials<0) = 0;         % Force to zero if negative.
                RemainingFrameError = SimParamGlobal.MaxFrameErrors - SimStateGlobal.FrameErrors(end,:);
                RemainingFrameError(RemainingFrameError<0) = 0; % Force to zero if negative.

                % Determine the position of active SNR points based on the number of remaining trials and frame errors.
                ActiveSNRPoints  = ( (RemainingTrials>0) & (RemainingFrameError>0) );
                % Set the stopping criteria flag.
                StoppingCriteria = ( sum(ActiveSNRPoints) == 0 );
                
                if StoppingCriteria
                    msg = sprintf( '\nStopping simulation of job %s for user %s because enough trials and/or frame errors are observed for ALL SNR points.\n\n',...
                        JobFileName(1:end-4), Username );
                    fprintf( msg );
                else
                    % Determine if we can discard some SNR points whose BER WILL be less than SimParam.minBER.
                    LastInactivePoint = find(ActiveSNRPoints == 0, 1, 'last');

                    StoppingCriteriaT = ~isempty(LastInactivePoint) && ...
                        ( ( (SimStateGlobal.BER(end, LastInactivePoint) ~=0) && (SimStateGlobal.BER(end, LastInactivePoint) < SimParamGlobal.minBER) ) || ...
                        ( (SimStateGlobal.FER(end, LastInactivePoint) ~=0) && (SimStateGlobal.FER(end, LastInactivePoint) < SimParamGlobal.minFER) ) );

                    if StoppingCriteriaT
                        ActiveSNRPoints(LastInactivePoint:end) = 0;
                        msg = sprintf( ['Stopping simulation of job %s for user %s for SOME SNR points because their BER and' ...
                            'FER is below the required mimimum BER and FER.\n'], JobFileName(1:end-4), Username );
                        fprintf( msg );
                    end
                    
                    % Set the stopping criteria flag again.
                    StoppingCriteria = ( sum(ActiveSNRPoints) == 0 );
                end

                % Determine and echo simulation progress.
                Remaining = sum( (ActiveSNRPoints==1).*RemainingTrials );
                Completed = sum( SimStateGlobal.Trials );
                msg = sprintf( '\nPROGRESS UPDATE for job %s user %s:\n\t%d\t Trials Completed\n\t%d\t Trials Remaining\n\t%2.4f Percent Completed.\n\n',...
                    JobFileName(1:end-4), Username, Completed, Remaining, 100*Completed/(Completed+Remaining) );
                fprintf( msg );
                
                % Set SimParam and SimState to their global values.
                SimParam = SimParamGlobal;
                SimState = SimStateGlobal;

                if ~StoppingCriteria    % If simulation of this job is not done, resubmit another round of tasks.
                    try
                        save( fullfile(JobRunningDir,JobFileName), 'SimParam', 'SimState' );
                        msg = sprintf( 'The corresponding job file %s of user %s is updated in the JobRunning directory.\n', JobFileName(1:end-4), Username );
                        fprintf( msg );
                    catch
                        TempfileName = JM_Save(JobFileName, SimParam, SimState);
                        JM_Move(TempfileName, JobRunningDir);
                        msg = sprintf( 'The corresponding job file %s of user %s is updated in the JobRunning directory by OS.\n', JobFileName(1:end-4), Username );
                        fprintf( msg );
                    end
                    
                    SimParamLocal = UpdateSimParamLocal(SimParamGlobal, SimStateGlobal);

                    SimParamLocal.MaxTrials(ActiveSNRPoints==0) = 0;
                    
                    % Limit the simulation runtime of each task.
                    SimTime = CurrentUser.SimTime;
                    % Divide the JOB into multiple TASKs.
                    FinalTaskID = DivideJob2Tasks(JobFileName, CurrentUser, SimParamLocal, SimTime);

                    CurrentUser.TaskID = FinalTaskID;
                    
                else % If simulation of this job is done, save the result in JobOut queue/directory.
                    % Save the results of this job simulation to a temporary file.
                    
                    % Set strings used to move saved files.
                    TempFile = fullfile(TempDir,'TempSaveJobManager.mat');
                    ChmodStr = ['chmod 666 ' TempFile];     % Allow everyone to read and write to the file, TempFile.
                    MovStr = ['sudo mv ' TempFile ' ' JobOutDir filesep];

                    try
                        save( TempFile, 'SimParam', 'SimState' );
                    catch
                        TempfileName = JM_Save('TempSaveJobManager.mat', SimParam, SimState);
                        JM_Move(TempfileName, TempDir);
                    end
                    
                    try system( ChmodStr ); catch end
                    try
                        try system( [ MovStr JobFileName ] ); catch end
                    catch
                        movefile(TempFile, fullfile(JobOutDir,JobFileName), 'f');
                    end
                        
                    % Remove the finished job from JobRunning queue/directory.
                    try
                        RmStr = ['sudo rm ' JobRunningDir filesep JobFileName];
                        try system( RmStr ); catch end
                    catch
                        delete( fullfile(JobRunningDir,JobFileName) );
                    end

                    % More Cleanup: Any tasks associated with this job should be deleted from TaskIn directory.
                    try
                        RmStr = ['sudo rm ' TaskInDir filesep JobFileName(1:end-4) '_task_*.mat' ];
                        try system( RmStr ); catch end
                    catch
                        delete( fullfile(TaskInDir,[JobFileName(1:end-4) '_task_*.mat']) );
                    end

                    % Some more associated output tasks could arrive in TaskOut directory. They should also be deleted.
                    % try
                    %     RmStr = ['sudo rm ' TaskOutDir filesep JobFileName(1:end-4) '_task_*.mat' ];
                    %     try system( RmStr ); catch end
                    % catch
                    %     delete( fullfile(TaskOutDir,[JobFileName(1:end-4) '_task_*.mat']) );
                    % end
                end
                
                else     % The job is read from JobOut directory.
                % Set SimParam and SimState to their global values.
                SimParam = SimParamGlobal;
                SimState = SimStateGlobal;
                
                % Cleanup: Any tasks associated with this job should be deleted from TaskIn directory.
                try
                    RmStr = ['sudo rm ' TaskInDir filesep JobFileName(1:end-4) '_task_*.mat' ];
                    try system( RmStr ); catch end
                catch
                    delete( fullfile(TaskInDir,[JobFileName(1:end-4) '_task_*.mat']) );
                end
                
                % Save the updated final result in JobOut directory.
                try
                    save( fullfile(JobOutDir,JobFileName), 'SimParam', 'SimState' );
                catch
                    TempfileName = JM_Save(JobFileName, SimParam, SimState);
                    JM_Move(TempfileName, JobOutDir);
                end
                
                end
            end
        end
        
        msg = sprintf( '\n\nSweeping JobIn, JobRunning, and TaskOut directories of user %s is finished at %s.\n\n',...
            Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
        fprintf( msg );
        % Wait before looping for the next active user.
        pause( CurrentUser.PauseTime );
        UserList{User} = CurrentUser;
    end
    if(Check4NewUser>=Check4NewUserPeriod), break; end
    end
    end
    UserListPrimary = UserList;
end
end


function SimParamLocal = UpdateSimParamLocal(SimParamGlobal, SimStateGlobal)
% Update local SimParam to the number of errors and trials that are remained.

% Initialize the LOCAL SimParam structure.
SimParamLocal = SimParamGlobal;

SimParamLocal.MaxFrameErrors = SimParamGlobal.MaxFrameErrors - SimStateGlobal.FrameErrors(end,:);
SimParamLocal.MaxFrameErrors(SimParamLocal.MaxFrameErrors<0) = 0;
SimParamLocal.MaxBitErrors = SimParamGlobal.MaxBitErrors - SimStateGlobal.BitErrors(end,:);
SimParamLocal.MaxBitErrors(SimParamLocal.MaxBitErrors<0) = 0;
SimParamLocal.MaxTrials = SimParamGlobal.MaxTrials - SimStateGlobal.Trials;
SimParamLocal.MaxTrials(SimParamLocal.MaxTrials<0) = 0;
end


function SimStateGlobal = UpdateSimStateGlobal(SimStateGlobalIn, SimStateLocal)
% Update the Global SimState.

SimStateGlobal = SimStateGlobalIn;
SimStateGlobal.Trials      = SimStateGlobal.Trials      + SimStateLocal.Trials;
SimStateGlobal.BitErrors   = SimStateGlobal.BitErrors   + SimStateLocal.BitErrors;
SimStateGlobal.FrameErrors = SimStateGlobal.FrameErrors + SimStateLocal.FrameErrors;

Trials = repmat(SimStateGlobal.Trials,[size(SimStateGlobal.BitErrors,1) 1]);
SimStateGlobal.BER         = SimStateGlobal.BitErrors   ./ ( Trials * SimStateLocal.NumCodewords * SimStateLocal.DataLength );
SimStateGlobal.FER         = SimStateGlobal.FrameErrors ./ ( Trials * SimStateLocal.NumCodewords );
end


function UserList = InitUsers(HomeRootIn,UserListPrimary)
% Initialize users' states in UserList structure.
%
% Calling syntax: UserList = InitUsers([HomeRootIn][,UserListPrimary])
% UserList fields for EACH user:
%       UserPath(Full Path),FunctionName,FunctionPath,MaxTasks,MaxTasksFactor,
%       NumTasks,MaxRunningJobs,InitialSimTime,SimTime,PauseTime,TaskID.
%
% Version 1, 12/07/2011, Terry Ferrett.
% Version 2, 01/11/2012, Mohammad Fanaei.

% Named constants.
if( nargin<1 || isempty(HomeRootIn) )
    if ispc
        HomeRoot = pwd;
    else
        HomeRoot = [filesep 'home'];
    end
else
    HomeRoot = HomeRootIn;
end
if( nargin<2 || isempty(UserListPrimary) ), UserListPrimary = []; end
CFG_Filename = '.CodedMod_cfg.txt';

usrdirs = []; RootInd = [];
if iscell(HomeRoot)
    for l = 1:length(HomeRoot)  % Perform a directory listing in home to list ALL users.
        usrdirs = [usrdirs ; dir(HomeRoot{l})];
        RootInd = [RootInd ; l*ones(size(dir(HomeRoot{l})))];
    end
else
    usrdirs = dir(HomeRoot);
end

UserList = UserListPrimary;
n = length(usrdirs);        % Number of directories found in home.
usr_cnt = length(UserList); % Counter to track number of ACTIVE users.

for k = 1:n
    % Find CFG_Filename file, i.e. project configuration file.
    if iscell(HomeRoot)
        cur_path = fullfile(HomeRoot{RootInd(k)}, usrdirs(k).name);
    else
        cur_path = fullfile(HomeRoot, usrdirs(k).name);
    end
    cur_file = fullfile(cur_path, CFG_Filename);
    cfgFileDir = dir(cur_file);
    
    UserFoundFlag = zeros(usr_cnt,1);
    for u = 1:usr_cnt
        UserFoundFlag(u) = strcmpi( UserList{u}.UserPath, cur_path );
    end
    
    % If CFG_Filename (project configuration file) exists AND user is NOT already listed in UserList, read CFG_Filename.
    if( ~isempty(cfgFileDir) && (sum(UserFoundFlag)==0) )
        usr_cnt = usr_cnt + 1;
        
        % Add FULL path to this user to active users list.
        UserList{usr_cnt}.UserPath = cur_path;
        
        
        heading1 = '[GeneralSpec]';
        
        % Read name and full path of function to be executed for running each task.
        key = 'FunctionName';
        out = fp(cur_file, heading1, key);
        UserList{usr_cnt}.FunctionName = eval(out);
        
        key = 'FunctionPath';
        out = fp(cur_file, heading1, key);
        UserList{usr_cnt}.FunctionPath = eval(out);
        
        
        heading2 = '[TaskInSpec]';
        
        % Read maximum number of input tasks in TaskIn queue/directory.
        key = 'MaxTasks';
        out = fp(cur_file, heading2, key);
        UserList{usr_cnt}.MaxTasks = str2num(out);
        
        % Read the factor of maximum number of input tasks in TaskIn queue/directory beyond which no new task is generated.
        key = 'MaxTasksFactor';
        out = fp(cur_file, heading2, key);
        UserList{usr_cnt}.MaxTasksFactor = str2num(out);
        
        % Read number of input tasks to submit to TaskIn at a time.
        key = 'NumTasks';
        out = fp(cur_file, heading2, key);
        UserList{usr_cnt}.NumTasks = str2num(out);
        
        % Read maximum number of parallel jobs running at a time.
        key = 'MaxRunningJobs';
        out = fp(cur_file, heading2, key);
        UserList{usr_cnt}.MaxRunningJobs = str2num(out);
        
        
        heading3 = '[SimTimeSpec]';
        
        % Read quick initial simulation time to quickly get results.
        key = 'InitialSimTime';
        out = fp(cur_file, heading3, key);
        UserList{usr_cnt}.InitialSimTime = str2num(out);
        
        % Read longer simulation time in the long term.
        key = 'SimTime';
        out = fp(cur_file, heading3, key);
        UserList{usr_cnt}.SimTime = str2num(out);
        
        % Read time to wait between task submissions and flow control.
        key = 'PauseTime';
        out = fp(cur_file, heading3, key);
        UserList{usr_cnt}.PauseTime = str2num(out);
        
        % Reset the task ID counter.
        UserList{usr_cnt}.TaskID = 0;
    % If user is already listed in UserList but its CFG_Filename (project configuration file) does not exist anymore, remove user from list.
    elseif( (sum(UserFoundFlag)~=0) && isempty(cfgFileDir) )
        UserList(UserFoundFlag == 1) = [];
        usr_cnt = usr_cnt - sum(UserFoundFlag);
    end
end
end


function [JobInDir, JobRunningDir, JobOutDir, TaskInDir, TaskOutDir, TempDir] = SetPaths(UserRoot)

UserRootJob = fullfile(UserRoot,'Projects','CodedMod');
UserRootTask = fullfile(UserRoot,'Tasks');

% Build required directories under UserRoot.
JobInDir = fullfile(UserRootJob,'JobIn');
JobRunningDir = fullfile(UserRootJob,'JobRunning');
JobOutDir = fullfile(UserRootJob,'JobOut');
TaskInDir = fullfile(UserRootTask,'TaskIn');
TaskOutDir = fullfile(UserRootTask,'TaskOut');
TempDir = fullfile(UserRootJob,'Temp');
end


function [InFileName, JobDirectory] = SweepJobInRunDir(JobInDir, JobRunningDir, Username, MaxRunningJobs)

InFileName = [];
JobDirectory = [];

DIn = dir( fullfile(JobInDir,'*.mat') );
DRunning = dir( fullfile(JobRunningDir,'*.mat') );

if( (length(DRunning) >= MaxRunningJobs) && ~isempty(DRunning) )
    % Pick a running job AT RANDOM.
    InFileIndex = randint( 1, 1, [1 length(DRunning)]);
    % Construct the filename.
    InFileName = DRunning(InFileIndex).name;
    msg = sprintf( '\nCONTINUING coded-modulation simulation for user %s job %s at %s by FURTHER generation of its tasks.\n', ...
        Username, InFileName(1:end-4), datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
    fprintf( msg );
    JobDirectory = JobRunningDir;
elseif( length(DRunning) < MaxRunningJobs )
    if ~isempty(DIn)
        % Pick the OLDEST new job.
        [Dummy, DateIndx] = sort( [DIn(:).datenum], 'ascend' );
        InFileIndex = DateIndx(1);
        % Construct the filename.
        InFileName = DIn(InFileIndex).name;
        msg = sprintf( '\nLaunching coded-modulation simulation for user %s NEW job %s at %s.\n', ...
            Username, InFileName(1:end-4), datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
        fprintf( msg );
        JobDirectory = JobInDir;
    elseif ~isempty(DRunning)
        % Pick a running job AT RANDOM.
        InFileIndex = randint( 1, 1, [1 length(DRunning)]);
        % Construct the filename.
        InFileName = DRunning(InFileIndex).name;
        msg = sprintf( '\nCONTINUING coded-modulation simulation for user %s job %s at %s by FURTHER generation of its tasks.\n', ...
            Username, InFileName(1:end-4), datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
        fprintf( msg );
        JobDirectory = JobRunningDir;
    end
else
    msg = sprintf( '\nNo new tasks for user %s was generated at %s. Both JobIn and JobRunning directories are emty of job files.\n', ...
        Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
    fprintf( msg );
end

end


function JobDirectory = SweepJobRunOutDir(JobRunningDir, JobOutDir, JobFileName)

JobDirectory = [];

DRunning = dir( fullfile(JobRunningDir,JobFileName) );
DOut = dir( fullfile(JobOutDir,JobFileName) );

if ~isempty(DRunning)
    JobDirectory = JobRunningDir;
elseif ~isempty(DOut)
    JobDirectory = JobOutDir;
end
end


function FinalTaskID = DivideJob2Tasks(InFileName, CurrentUser, SimParamLocal, SimTime)
% Divide the JOB into multiple TASKs.

UserRoot = CurrentUser.UserPath;
% [HomePath, Username, Extension, Version] = fileparts(UserRoot);
[HomeUserPath, Username] = fileparts(UserRoot);

TaskInDir = fullfile(UserRoot,'Tasks','TaskIn');

MaxTasks = CurrentUser.MaxTasks;
MaxTasksFactor = CurrentUser.MaxTasksFactor;
TaskID = CurrentUser.TaskID;

% Sense the load of the task input queue (TaskIn directory) of current user.
DTask = dir( fullfile(TaskInDir,'*.mat') );
TaskLoad = length(DTask);

if TaskLoad < MaxTasksFactor*MaxTasks    % If TaskLoad>MaxTasksFactor*MaxTasks, NO NEW TASKs will be generated.

NumTasks = CurrentUser.NumTasks;
PauseTime = CurrentUser.PauseTime;

Tasks = max( min( NumTasks, MaxTasks-TaskLoad ), 1);  % Always generate at least one task.
SimParamLocal.MaxTrials = ceil(SimParamLocal.MaxTrials/Tasks);

% Update the local simulation time.
SimParamLocal.SimTime = SimTime;

% Submit each task one-by-one. Make sure that each task has a unique name.
SimParam = SimParamLocal;
TaskParam = struct(...
    'FunctionName', CurrentUser.FunctionName,...
    'FunctionPath', CurrentUser.FunctionPath,...
    'InputParam', SimParam);

JobFileName = InFileName;

msg = sprintf( 'Generating TASK files corresponding to JOB %s of user %s  and saving them to its TaskIn directory at %s.\n\n',...
    JobFileName(1:end-4), Username, datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM') );
fprintf( msg );

OS_flag = 0;

for TaskCount=1:Tasks
    % Increment TaskID counter.
    TaskID = TaskID + 1;

    % Create the name of the new task, which includes the job name.
    TaskFileName = [JobFileName(1:end-4) '_task_' int2str(TaskID) '.mat'];

    % Save the new task in TaskIn queue.
    try
        save( fullfile(TaskInDir,TaskFileName), 'TaskParam' );
        msg = sprintf( 'Task file %s for user %s is saved to its TaskIn directory.\n', TaskFileName(1:end-4), Username );
        PrintOut( msg );
        msg = sprintf('+');
        fprintf( msg );
    catch
        TempfileName = JM_Save(TaskFileName, TaskParam);
        msg = sprintf( 'Task file %s for user %s is saved to its TaskIn directory by OS.\n', TaskFileName(1:end-4), Username );
        PrintOut( msg );
        msg = sprintf('+');
        fprintf( msg );
        OS_flag = 1;
    end
    
    if( rem(TaskCount,5) == 0 )
        fprintf( '\n' );
        if(OS_flag), JM_Move(TempfileName, TaskInDir); end
        OS_flag = 0;
    end
    
    % Pause briefly for flow control.
    pause( PauseTime );
end
fprintf( '\n' );
if(OS_flag), JM_Move(TempfileName, TaskInDir); end

else    % TaskInDir is full. No new tasks will be generated.
msg = sprintf('No new task is generated for user %s since its TaskIn directory is full.\n', Username);
fprintf( msg );
end

FinalTaskID = TaskID;

end


function out = fp(filename, heading, key)
% General-Purpose File Parser.
%
% Version 1, 20/27/2011, Terry Ferrett.
% Version 2, 10/07/2012, Mohammad Fanaei.
%
% Function Steps:
% 1. Open the file specified by filename.
% 2. Seek to 'heading'.
% 3. For the ONLY field denoted by 'key', read value into 'out' as a string.
% 4. Close the file.

fid = fopen(filename);

str_in = fgetl(fid);
empty_file = isnumeric(str_in);

% Scan for heading.
while(empty_file == false)
    switch str_in
        case heading
            break;
        otherwise
            str_in = fgetl(fid);
            empty_file = isnumeric(str_in);
    end
end

str_in = fgetl(fid);
empty_file = isnumeric(str_in);

% Scan for key value.
while(empty_file == false)
    if( ~isempty(str_in) && str_in(1) ~= '%' )
        Ind = strfind(str_in, '=');
        l_key = strtrim( str_in(1:Ind-1) );
        l_val = strtrim( str_in(Ind+1:end) );
        Ind_lVal = strfind(l_val, ';');
        if ~isempty(Ind_lVal), l_val = l_val(1:Ind_lVal-1); end

        switch l_key
            case key
                out = l_val;
                break;
            otherwise
                if( ~isempty(l_key) )
                    if( l_key(1) == '[' )
                        break;
                    end
                end
        end
    end
    str_in = fgetl(fid);
    empty_file = isnumeric(str_in);
end
fclose(fid);

% If no matching keys were found, assign out to null.
out_flag = strcmp( 'out', who('out') );
if isempty(out_flag), out = []; end

end


function TempfileName = JM_Save(InFileName, SimParam, SimState)
% Save SimParam and SimState in InFileName in a Temp directory.
if ispc
    HomeRoot = pwd;
else
    HomeRoot = '/home';
end

Sep = filesep;
TempDir = [HomeRoot Sep 'pcs' Sep 'jm' Sep 'CodedMod' Sep 'Temp'];

if( nargin<3 || isempty(SimState) )
    TaskParam = SimParam;
    save( fullfile(TempDir,InFileName), 'TaskParam' );
    TempfileName = TempDir;
else
    save( fullfile(TempDir,InFileName), 'SimParam', 'SimState' );
    TempfileName = [TempDir Sep InFileName];
end

end


function JM_Move(FileTarget, FileDestination)
TargetDir = dir(FileTarget);

if ~isempty(TargetDir)
    if length(TargetDir)>2  % Bypass . and .. directories in dir command.
        RmStr = ['sudo mv ' FileTarget filesep '* ' FileDestination];
        try system( RmStr ); catch end
    else
        RmStr = ['sudo mv ' FileTarget  ' ' FileDestination];
        try system( RmStr ); catch end
    end
else
    return;
end

end


function [eTimeTrial, NodeID_Times] = ExtractETimeTrial( SimState, NodeID_TimesIn, eTimeTrialIn, CurrentTime )
% NodeID_Times is a vector structure with two fields:
% NodeID and NumTimes (how many times that specific node has generated SimState (run simulations)).
% The length of this structure is equal to the number of active nodes.
%
% eTimeTrial is a 3-by-MaxTimes-by-NodeNum matrix.
% Its first row contains the time calculated globally from the start of the job manager until receiving curret consumed task from TaskOut directory.
% Its second row contains elapsed times in current task at the worker and its third row contains the number of trials completed in the eTime.

MaxTimes = 500;

NodeID_Times = NodeID_TimesIn;
eTimeTrial = eTimeTrialIn;

LID = length(NodeID_Times);
IndT = zeros(1,LID);
for Node = 1:LID
    IndT(Node) = strcmpi( num2str(NodeID_Times(Node).NodeID), SimState.NodeID );
end

Ind = find(IndT~=0, 1,'first');
if isempty(Ind)
    NodeID_Times = [NodeID_Times, struct('NodeID',SimState.NodeID, 'NumTimes',1)];
    Ind = length(NodeID_Times);
    eTimeTrial = cat(3,eTimeTrial,zeros(3,MaxTimes));
else
    NodeID_Times(Ind).NumTimes = NodeID_Times(Ind).NumTimes + 1;
end

if NodeID_Times(Ind).NumTimes <= MaxTimes
    ColPos = NodeID_Times(Ind).NumTimes;
else
    % Note that the first row of eTimeTrial is cumulative time from the start of the job manager.
    eTimeTrial(2:end,2,:) = eTimeTrial(2:end,1,:) + eTimeTrial(2:end,2,:);
    eTimeTrial = circshift(eTimeTrial, [0 -1 0]);
    ColPos = size(eTimeTrial,2);
end

eTimeTrial(:,ColPos,Ind) = [CurrentTime
    etime(SimState.StopTime, SimState.StartTime)
    sum(SimState.Trials)];
end


function DeleteFile(FileName, FileDirectory, Username, ResultsFileDir, JobFileName)
try
    try
        RmStr = ['sudo rm ' FileDirectory filesep FileName];
        try
            system( RmStr );
            msg = sprintf( 'The selected output task file %s of user %s is deleted from its TaskOut directory.\n', FileName(1:end-4), Username );
            % msg = sprintf( 'OTask %s of user %s --\t', FileName(1:end-4), Username );
            PrintOut( msg );
            msg = sprintf( '-' );
            fprintf( msg );
        catch
        end
    catch
        delete( fullfile(FileDirectory,FileName) );
        msg = sprintf( 'The selected output task file %s of user %s is deleted from its TaskOut directory.\n', FileName(1:end-4), Username );
        % msg = sprintf( 'OTask %s of user %s --\t', FileName(1:end-4), Username );
        PrintOut( msg );
        msg = sprintf( '-' );
        fprintf( msg );
    end
catch
    % Could not delete output task file. Just issue a warning.
    msg = sprintf( 'Task Delete Error/Warning: Output task file %s of user %s could not be deleted from its TaskOut directory.\n', FileName(1:end-4), Username );
    fprintf( msg );
    FID_ErrorTaskDel = fopen( fullfile(ResultsFileDir,[JobFileName(1:end-4) '_Error_TaskOutDel.txt']), 'a+');
    msg = sprintf( ['Task Delete Error/Warning: Output task file \t %s \t of user \t %s \t could not be deleted from the user TaskOut directory.\n',...
        'The user can delete the .mat task file manually.'], FileName(1:end-4), Username );
    fprintf( FID_ErrorTaskDel, msg );
    fclose(FID_ErrorTaskDel);
end
end


function [FileContent, success] = LoadFile(FileName, FileDirectory, Username, FieldA, FieldB, ResultsFileDir, JobFileName)
try
    FileContent = load( fullfile(FileDirectory,FileName), FieldA, FieldB );
    msg = sprintf( 'Output task file %s of user %s is loaded.\n', FileName(1:end-4), Username );
    % fprintf( msg );
    PrintOut( msg );
    success = 1;
catch
    FileContent = [];
    % Selected output task file was bad, kick out of loading loop.
    msg = sprintf( 'Output Task Load Error: Output task file %s of user %s could not be loaded and will be deleted.\n', FileName(1:end-4), Username );
    fprintf( msg );
    success = 0;
    FID_ErrorTaskLoad = fopen( fullfile(ResultsFileDir,[JobFileName(1:end-4) '_Error_TaskOutLoad.txt']), 'a+');
    msg = sprintf( ['Output Task Load Error: Output task file \t %s \t of user \t %s \t could not be loaded and will be deleted automatically.\n',...
        'Output task should be a .mat file containing two MATLAB structures named TaskParam and TaskState.'], FileName(1:end-4), Username );
    fprintf( FID_ErrorTaskLoad, msg );
    fclose(FID_ErrorTaskLoad);
end
end


function PrintOut( msg )
vgFlag = 'verbose'; % If vgFlag='verbose', all detailed intermediate messages are printed out.
                    % If vgFlag='quiet', just important intermediate  messages are printed out.
if strcmpi(vgFlag, 'verbose')
    fprintf( msg );
elseif strcmpi(vgFlag, 'quiet')
    return;
end
end