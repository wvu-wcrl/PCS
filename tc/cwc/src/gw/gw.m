% gw.m
%
% generic worker function
%
% executes user-submitted task code on the cluster
% 
% outline of main loop
%  1. look for task files in input queue
%  2. if files exist, pick one randomly
%  3. read task execution information from randomly selected file
%  4. execute task
%
% Version 3
% 3/12/2012
% Terry Ferrett
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.


%%%%  Inputs %%%%
%   wid    worker id
%  
%   % Paths %
%   iq       global input queue
%   rq       global running queue
%   oq      global output queue
%   lfup    logging function
%   lfip     log file
%
%  % Logging parameters %
%    LOG_PERIOD       time between log rotations, seconds
%    NUM_LOGS         number of log files to archive before deleting old files
%    VERBOSE_MODE  logging verbosity level


function gw(wid, iq, rq, oq, lfup, lfip, LOG_PERIOD, NUM_LOGS, VERBOSE_MODE)



%lifp%% place logging variables into local workspace for easy access %%%
LOG_PERIOD = str2double(LOG_PERIOD);
NUM_LOGS = str2double(NUM_LOGS);

IS_VERBOSE = 1;  % flag verbose log messages
IS_NOT_VERBOSE = 0;

STDOUT = 1;         % print to standard out

APPEND_TIME = 1; % append time to message written to log file
DONT_APPEND_TIME = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% add logging function to path, and save base path information %%%
addpath(lfup);
default_path = path; % the default path will be restored after executing
                     %  the entry function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% log the worker start time %%%
% [cur_time] = gettime(); % current time
%msg = ['Worker' ' ' int2str(wid) ' ' 'started at' ' '  cur_time];
%log_msg(msg, IS_NOT_VERBOSE, VERBOSE_MODE);
msg = ['Worker' ' ' int2str(wid) ' ' 'started.'];
PrintOut(msg, IS_NOT_VERBOSE, STDOUT, APPEND_TIME);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%% initialize logging information %%%
tic;   % start logging timer
nlog = 0; % intialize log count
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%% main worker loop
while(1)
    
    %%% attempt to read a random task from the input queue %%%
    next_input = read_input_queue(iq); 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




    %%% if a task exists in input queue, execute it %%%
    if( ~isempty(next_input) )
    
      
        try
        next_running = feed_running_queue(next_input, iq, rq, wid); % move the input file to the running queue



	clear TaskParam;
        TaskParam = read_input_file(rq, next_running); % read the input struct from the running queue
        

        
        % break the input struct into local variables
        InputParam = TaskParam.InputParam;     % simulation parameters
        FunctionPath = TaskParam.FunctionPath; % path to simulation code
        FunctionName = TaskParam.FunctionName; % entry routine into simulation code

        

        addpath(FunctionPath);   % add simulation code path to working paths
        

        
        %%% log function start time %%%       
         [cur_time] = gettime(); % current time
%        username = strtok(next_running, '_');  % username

        [name_loc en] = get_name_loc(next_running);



        task_name = get_task_name(next_input);
        %msg = ['Executing task' ' ' task_name ' ' 'from user' ' ' name_loc  ' ' 'at'  ' ' cur_time];
        %log_msg(msg, IS_NOT_VERBOSE, VERBOSE_MODE);
        msg = ['Executing task' ' ' task_name ' ' 'from user' ' ' name_loc];
        PrintOut(msg, IS_NOT_VERBOSE, STDOUT, APPEND_TIME);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%




	% place function start time into TaskInfo struct
	hostname = get_hostname();
        TaskInfo = create_task_info(cur_time, hostname, wid);



        % append worker id to InputParam prior to exection
	InputParam.wid = wid;

        % run the function with its input parameters        
	clear TaskState;
        FunctionName = str2func(FunctionName);
        TaskState = feval(FunctionName, InputParam);

        

        
        %%% log function end time %
        % [cur_time] = gettime(); % current time
        %msg = ['Task' ' ' task_name ' ' 'from user'  ' ' name_loc ' ' 'complete' ' ' 'at'  ' ' cur_time];
        %log_msg(msg, IS_NOT_VERBOSE, VERBOSE_MODE);
        msg = ['Task' ' ' task_name ' ' 'from user'  ' ' name_loc ' ' 'complete'];
        PrintOut(msg, IS_NOT_VERBOSE, STDOUT, APPEND_TIME);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%



        %  place task stop time into the task information data structure
	    TaskInfo.StopTime = clock;

                
        
        consume_running_queue(next_running, rq); % delete file from running queue
        write_output(TaskParam, TaskState, TaskInfo,  next_input, oq); % write to output queue
        

        
        path(default_path); % restore the default path
        

        
        catch exception
            % an error occurred in file loading or function execution.
            %   perform cleanup 
            %   reset the default path
	    %   if another worker consumed the file before this worker got there,
            %      write nothing to the log file
            %        
	        


        path(default_path); 

        % if the error results from a consumed file, do not write to the log file
        if isempty(strfind(exception.message, 'Unable to read file'))

	% the task failed to execute.  write the appropriate log message,
        % including MATLAB's exception message, allowing debugging.
        write_task_failed_to_log(next_input, next_running, IS_NOT_VERBOSE,...
                                  VERBOSE_MODE, name_loc, exception.message );


        % write error message to TaskInfo
        TaskInfo.ErrorMsg = exception.message;


        % append "_failed" to the task filename and move to output queue
        move_failed_task_to_output_queue(next_input, TaskParam, TaskInfo, oq, next_running, rq);
        end


        end
    end




    
    
    pause(5); % wait 5 seconds before making another pass


    t = toc;
if(t > LOG_PERIOD) % rotate log file
    [cur_time] = gettime(); % current time
    rotate_log(lfip,nlog, cur_time);        % rotate the log file
    nlog = mod(nlog+1, NUM_LOGS);
tic;
end
    
end
end




function next_input = read_input_queue(iq)

srch = strcat(iq, '/*.mat');      % form full directory string

fl = dir( srch );    % get list of .mat files in input queue directory

nf = length(fl);  % how many input files does this user have?

fn = ceil(rand*nf); % pick file randomly
if fn ~= 0,
    next_input = fl(fn).name;
else
    next_input = '';
end

end






function next_running = feed_running_queue(next_input, iq,  rq, wid)


% move the file to the running queue and tag with the worker id
[beg en]  =   get_name_loc(next_input);
next_running = [beg '_' int2str(wid) en];



cs = ['mv' ' ' iq '/' next_input ' ' rq '/' next_running ];

[dont care] = system(cs);

end




function TaskParam = read_input_file(rq, next_running)

lf = [rq '/' next_running];

    load(lf);

end





function consume_running_queue(next_running, rq)

cs = ['rm' ' ' rq '/' next_running];
system(cs);

end




function write_output(TaskParam, TaskState, TaskInfo, next_input, oq)


op = [oq '/' next_input];

save(op, 'TaskParam', 'TaskState', 'TaskInfo');

end




function [cur_time] = gettime();

timevec = fix(clock);  % time
year = int2str(timevec(1)); month = int2str(timevec(2)); day = int2str(timevec(3));
hour = int2str(timevec(4)); min = int2str(timevec(5)); sec = int2str(timevec(6));

cur_time = [year '-' month '-' day ' ' hour ':' min ':' sec];

end




function  task_name = get_task_name(next_input)

[beg task_name] = strtok(next_input, '_');

task_name = task_name(2:end-4);

end






function rotate_log(lfip, nlog, cur_time)


% insert message at end of existing log file regarding rotation
cs = ['echo' ' ' '''Log file rotated at ' cur_time ''' ' '>>' ' ' lfip];
system(cs);


% copy the existing log file to file number nlog
fnind = strfind(lfip, '/');  %tokenize the full path to the log file
fnind = fnind(end);

lfp = lfip(1:fnind-1);
lfn = lfip(fnind+1:end);

af = [lfp '/archive' '/' lfn '.' int2str(nlog)];
cs = ['cp' ' ' lfip ' ' af];
system(cs);
%%%%%%%%%%%%%%%%


% null existing log file
cs = ['cat /dev/null' ' ' '>' ' ' lfip];
system(cs);


% prepend first ten lines of previous log file to new
cs = ['tail ' af ' >> ' lfip];


% insert message about new log file creation with timestamp
cs = ['echo' ' ' '''Log file rotated at ' cur_time ''' ' '>>' ' ' lfip];
system(cs);


end






% logging function
% inputs
%  msg               - string to output to logs
%  msg_verbose       - is this a verbose message?
%  log_mode_verbose  - is the logging mode verbose?
%function log_msg(msg, msg_verbose, log_mode_verbose)
%if ~(msg_verbose == 1 & log_mode_verbose == 0), 
%  fprintf(msg); fprintf('\n');
%end
%end





% append 'append_str' to old_str to form new_str
function new_str = str_append(old_str, append_str)

  prefix = old_str(1:end-4);
  suffix = old_str(end-3:end);
  new_str = strcat(prefix, append_str, suffix);

end



%  task failed to execute. log the error message describing why the task failed to execute
function write_task_failed_to_log(next_input, next_running, IS_NOT_VERBOSE,...
                 VERBOSE_MODE, username, message )
STDOUT=1;
APPEND_TIME=1;
        task_name = get_task_name(next_input);

	name_loc = get_name_loc(next_running);
        %[cur_time] = gettime(); % current time

	
        %msg = ['Task' ' ' task_name ' ' 'from user' ' ' name_loc  ' ' 'at'  ' ' cur_time];
        msg = ['Task' ' ' task_name ' ' 'from user' ' ' name_loc ' '];
        msg = [msg 'failed to execute.'];
        PrintOut(msg, IS_NOT_VERBOSE, STDOUT, APPEND_TIME);
        PrintOut(message, IS_NOT_VERBOSE, STDOUT, APPEND_TIME);
        %log_msg(msg, IS_NOT_VERBOSE, VERBOSE_MODE);
        %log_msg(message, IS_NOT_VERBOSE, VERBOSE_MODE);
        
end





% task failed to execute.  move input task file to output queue appending 'failed' to the filename
function move_failed_task_to_output_queue(next_input, TaskParam, TaskInfo, oq, next_running, rq)
	task_name_failed = str_append(next_input, '_failed');
        write_output(TaskParam, struct(), TaskInfo, task_name_failed, oq);
        consume_running_queue(next_running, rq);
end





% get the system hostname
function hostname = get_hostname()

[dont_care hostname] = system('hostname');

end





% gather task statistics - start time, hostname, and worker id
function TaskInfo = create_task_info(cur_time, hostname, wid)

   TaskInfo.StartTime = clock;    % use clock function so job manager can use etime to subtract
                                  %   start and stop
   TaskInfo.HostName = get_hostname();
   TaskInfo.WorkerID = wid;

end





% get username and location
function [name_loc en] = get_name_loc(filein)


[name entmp] = strtok(filein, '_');
[loc  en]  = strtok(entmp,'_');


name_loc = [name '_' loc];

end



%     This library is free software;
%     you can redistribute it and/or modify it under the terms of
%     the GNU Lesser General Public License as published by the
%     Free Software Foundation; either version 2.1 of the License,
%     or (at your option) any later version.
%
%     This library is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%     Lesser General Public License for more details.
%
%     You should have received a copy of the GNU Lesser General Public
%     License along with this library; if not, write to the Free Software
%     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
