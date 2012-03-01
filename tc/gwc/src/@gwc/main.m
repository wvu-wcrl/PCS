% main.m
%
% primary loop for grid worker controller
%
% process which reads the grid input queue and launches
%  grid tasks using Rapids
%
%
% Version 1
% 2/22/2012
% Terry Ferrett

function obj = main(obj)

LOG_PERIOD = str2double(obj.log_period);
NUM_LOGS = str2double(obj.num_logs);
IS_VERBOSE = 1;
IS_NOT_VERBOSE = 0;

% log the worker start time %%%%%%%%
[cur_time] = gettime(); % current time
msg = ['Grid gateway started at' ' ' cur_time];
log_msg(msg, IS_NOT_VERBOSE, VERBOSE_MODE);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic;       % start logging timer
nlog = 0;  % initialize log count

iq = obj.iq; % assign the input queue path to a local variable for easy reference
rq = obj.rq;

while(1)  %%% main worker loop
    next_input = read_input_queue(iq);    % read a random file from the input queue
    if( ~isempty(next_input) )
        try
            next_running = feed_running_queue(next_input, iq, rq)   % move input file to running queue
            obj = launch_rapids_task(obj, rq, next_running); % launch on Rapids
        catch exception
        end
    end
    
    
    % check for completed job
    next_output = read_rapids_output(obj);
    if( ~isempty(next_output) )
        consume_rapids_output( obj, next_output );
    end
    
    pause(5);   % wait five seconds before making another pass
    
    
    t = toc;
    if(t > LOG_PERIOD) % rotate log file
        [cur_time] = gettime();
        rotate_log(lp, nlog, cur_time);
        nlog = mod(nlog+1, NUM_LOGS);
        tic;
    end
    
end

end





function obj = launch_rapids_task(obj, next_running)
% load task file
TaskParam = read_input_file(rq, next_running);
% based on contents of task file, compress program into elements.zip
create_job_elements(obj, TaskParam);
% create job.properties
create_job_properties(obj);
% create new job using Rapids interface
create_rapids_job(obj);
% increment rapids queue
increment_rapids_queue();
end




function TaskParam = read_input_file(rq, next_running)   % read task from grid input queue
path_to_task_file = [rq '/' next_running];
load(path_to_task_file);
obj.rtn = 'test_template';    % rapids template name.  hard-code it for now
obj.pjp  = [obj.rtn '/' 'job.properties'];
end



% create elements.zip and move to Rapids template dir
% 1. create zip of executable
% 2. move zip to Rapids template directory
function create_job_elements(obj, TaskParam)   
tp = obj.tp;      % Rapids template path
rtn = obj.rtn;   % Rapids template name
tez = obj.tez;  % temporary path to elements.zip

frtn = [tp '/' rtn];   % full rapids template name

ExecutablePath = TaskParam.ExecutablePath;

% zip executable
cmd = ['zip -r ' tez ExecutablePath];
system(cmd);

% move to Rapids template directory
cmd = ['mv ' tez  ' ' frtn];
system(cmd);

end



function create_job_properties(obj)   

pjp = [obj.tp '/' obj.pjp];  % path to job.properties

cmd = ['echo RUNTIME=.*ubuntu-11.04-2.* >> ' pjp]; system(cmd);
cmd = ['echo REQUIRED_EXTENSIONS=mcr2010a-1b.shar >> ' pjp]; system(cmd);
cmd = ['echo ELEMENTS=elements.zip >> ' pjp]; system(cmd);
cmd = ['echo COMMAND_LINE= /bin/sh -c "\"unzip elements.zip && chmod +x RunTask && ./RunTask"\" >> ' pjp]; system(cmd);

end





function obj = run_rapids_job(obj)   

pre = obj.pre;
rtn = obj.rtn;

% call Rapids
job_name = obj.jc;
cmd = [pre ' '  'newjob' ' ' rtn '1' job_name]; system(cmd);  % create new job
cmd = [pre ' ' 'launch' ' ' job_name]; system(cmd);              % launch job
cmd = [pre ' ' 'listen' ' ' job_name]; system(cmd);              % listen to job
obj.jc = obj.jc + 1;

end




function tpp = read_rapids_output(obj)

% scan for output file in active job directories
tp = obj.tp;      % Rapids template path
rtn = obj.rtn;   % Rapids template name
tez = obj.tez;  % temporary path to elements.zip

% need to associate jobs, tasks, job names, and 

tpp = [tp '/' rtn '/' 'resultsets' '/' '1' '/' 'TaskParam.mat'];   % task param path

tpe = dir(tpp); % task param exists
if length(tpe) ~= 1,  % if task param does not exist, return empty string
tpp = '';
end

end




function consume_rapids_output(obj)
% read TaskParam.mat

% create name for output file

% save to output queue
end