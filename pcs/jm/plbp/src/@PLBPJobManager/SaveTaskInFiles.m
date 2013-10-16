function FinalTaskID = SaveTaskInFiles(obj, TaskInputParam, UserParam, JobName, TaskMaxRunTime)
% TaskInputParam is NumNewTasks-by-1 vector of structures each one of them associated with one TaskInputParam.
if( nargin<5 || isempty(TaskMaxRunTime) ), TaskMaxRunTime = UserParam.MaxRunTime; end

% TaskInDir = fullfile(UserParam.TasksRoot,'TaskIn');
TaskInDir = UserParam.TaskInDir;
% [HomeRoot, Username, Extension, Version] = fileparts(UserParam.UserPath);
% [Dummy, Username] = fileparts(UserParam.UserPath);
Username = obj.FindUsername(UserParam.UserPath);
OS_flag = 0;

TaskParam = struct(...
    'FunctionName', UserParam.FunctionName,...
    'FunctionPath', UserParam.FunctionPath,...
    'InputParam', []);

TaskCount = 1;

% Submit the task. Make sure that each task has a unique name.
% Increment TaskID counter.
UserParam.TaskID = UserParam.TaskID + 1;
TaskInputParam.MaxRunTime = TaskMaxRunTime;
TaskInputParam(TaskCount).RandSeed = mod(UserParam.TaskID*sum(clock), 2^32);

TaskParam.InputParam = TaskInputParam;

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

% if( rem(taskcount,userparam.taskinflushrate) == 0 )
%     printout('\n', 0, obj.jobmanagerparam.logfilename);
%     if os_flag ==1
%         % successflag = obj.movefile(fullfile(obj.jobmanagerparam.tempjmdir,'*.mat'), taskindir, successmsg, errormsg);
%         obj.movefile(fullfile(obj.jobmanagerparam.tempjmdir,[obj.jobmanagerparam.projectname '_' jobname(1:end-4) '_task_*.mat']), taskindir);
%         os_flag = 0;
%     end
% end

% Pause briefly for flow control.
% pause( UserParam.PauseTime );

PrintOut('\n', 0, obj.JobManagerParam.LogFileName);
if OS_flag == 1
    % SuccessFlag = obj.MoveFile(fullfile(obj.JobManagerParam.TempJMDir,[obj.JobManagerParam.ProjectName '_' JobName(1:end-4) '_Task_*.mat']), TaskInDir, SuccessMsg, ErrorMsg);
    obj.MoveFile(fullfile(obj.JobManagerParam.TempJMDir,[obj.JobManagerParam.ProjectName '_' JobName(1:end-4) '_Task_*.mat']), TaskInDir);
end

FinalTaskID = UserParam.TaskID;

end