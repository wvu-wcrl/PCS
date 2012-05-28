% main.m
%
% primary loop for grid worker controller
%
% process which reads the grid input queue and launches
%  grid tasks using Rapids
%
%
% Version 2
% 4/2/2012
% Terry Ferrett
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.


function obj = main(obj)


   while(1)

     scan_for_input();            % scan user directores for input

     if( USER_INPUT_EXISTS )
    
           schedule();                  % schedule discovered user tasks

	   if( NEW_JOB_REQUESTED )

              start_job();                 % if a task requesting a new job is discovered, start the job

           else

              update_job();                  % add task to existing job

           end
      end

end















function obj = main(obj)

LOG_PERIOD = str2double(obj.log_period);
NUM_LOGS = str2double(obj.num_logs);
IS_VERBOSE = 1;
IS_NOT_VERBOSE = 0;
VERBOSE_MODE = 0;

% log the worker start time %%%%%%%%
[cur_time] = gettime(); % current time
msg = ['Grid gateway started at' ' ' cur_time];
log_msg(msg, IS_NOT_VERBOSE, VERBOSE_MODE);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic;       % start logging timer
nlog = 0;  % initialize log count

iq = obj.gq.iq; % assign the input queue path to a local variable for easy reference
rq = obj.gq.rq;

while(1)  %%% main worker loop
    next_input = read_input_queue(iq);    % read a random file from the input queue
    if( ~isempty(next_input) )
        try
            next_running = feed_running_queue(next_input, iq, rq)   % move input file to running queue
            obj = launch_rapids_task(obj, rq, next_running, next_input); % launch on Rapids
        catch exception
            sprintf(exception.message)
        end
    end
    
    
    % check for completed job
    next_output = read_rapids_output(obj);
    if( ~isempty(next_output) )
        consume_rapids_outpu( obj, next_output );
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
[beg en] = strtok(next_input,'_');
%next_running = [beg '_' int2str(wid) en];
next_running = [beg '_' en];

cs = ['mv' ' ' iq '/' next_input ' ' rq '/' next_running ];
system(cs);

end







function obj = launch_rapids_task(obj, rq, next_running, next_input)
% load task file
TaskParam = read_input_file(rq, next_running);
% based on contents of task file, compress program into elements.zip
create_job_elements(obj, TaskParam);
% create job.properties
create_job_properties(obj);
% create new job using Rapids interface
create_rapids_job(obj);

end




function TaskParam = read_input_file(rq, next_running)   % read task from grid input queue
path_to_task_file = [rq '/' next_running];
load(path_to_task_file);

obj.rtn = 'compiled_fsk';    % rapids template name.  hard-code it for now
obj.pjp  = [obj.rtn '/' 'job.properties'];
end



% create elements.zip and move to Rapids template dir
% 1. create zip of executable
% 2. move zip to Rapids template directory
function create_job_elements(obj, TaskParam)   
tp = obj.tp;      % Rapids template path
rtn = obj.rtn;   % Rapids template name
tez = [obj.rtp '/' 'elements.zip'];

frtn = [tp '/' rtn '/common/job_elements' ];   % full rapids template name

ExecutablePath = TaskParam.ExecutablePath;

% zip executable
cmd = ['zip -r ' tez ' ' ExecutablePath];
system(cmd);

% move to Rapids template directory
cmd = ['mv ' tez  ' ' frtn];
system(cmd);

end



function create_job_properties(obj)   

pjp = [obj.tp '/' obj.pjp 'compiled_fsk/job.properties'];  % path to job.properties

cmd = ['echo RUNTIME=.*ubuntu-11.04-2.* >> ' pjp]; system(cmd);
cmd = ['echo REQUIRED_EXTENSIONS=mcr2010a-1b.shar >> ' pjp]; system(cmd);
cmd = ['echo ELEMENTS=elements.zip >> ' pjp]; system(cmd);
cmd = ['echo COMMAND_LINE= /bin/sh -c "\"unzip elements.zip && chmod +x SingleSimulate && ./SingleSimulate"\" >> ' pjp]; system(cmd);
cmd = ['echo OUTPUT_FILES=NFSK8AWGNCSI.mat >> ' pjp]; system(cmd);

end





function obj = create_rapids_job(obj)   

pre = obj.pre;
rtn = obj.rtn;

% call Rapids
job_name = int2str(obj.jc);
cmd = [pre ' '  'newjob' ' ' rtn ' 1 ' job_name]; system(cmd);  % create new job
cmd = [pre ' ' 'launch' ' ' job_name]; system(cmd);              % launch job
cmd = [pre ' ' 'listen' ' ' job_name]; system(cmd);              % listen to job
obj.jc = obj.jc + 1;

end







function consume_rapids_output(obj, TaskParam, next_input)

rtn = obj.rtn;
tp = obj.tp;

op = [tp '/' rtn '/' 'resultsets' '/' '0' '/' 'NFSK8AWGNCSI0.mat']; % read NFSK8AWGNCSI0.mat
load(op);

TaskState.save_param = save_param;
TaskState.save_state = save_state;

% create name for output file
oq = obj.oq;
fn = [oq '/' next_input];

save(fn, 'TaskParam', 'TaskState');   % save to output queue

end


function [cur_time] = gettime();
timevec = fix(clock);  % time
year = int2str(timevec(1)); month = int2str(timevec(2)); day = int2str(timevec(3));
hour = int2str(timevec(4)); min = int2str(timevec(5)); sec = int2str(timevec(6));

cur_time = [year '-' month '-' day ' ' hour ':' min ':' sec];
end




% logging function
% inputs
%  msg               - string to output to logs
%  msg_verbose       - is this a verbose message?
%  log_mode_verbose  - is the logging mode verbose?
function log_msg(msg, msg_verbose, log_mode_verbose)
if ~(msg_verbose == 1 & log_mode_verbose == 0),
  fprintf(msg); fprintf('\n');
end
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
