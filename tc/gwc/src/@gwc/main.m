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


function gw(obj)

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
                    
		    launch_rapids_task(obj, rq, next_running); % launch on Rapids
                    		    
		  catch exception
		  end
                end

		% check for completed job

		next_output = read_rapids_output(obj);
                if( ~isempty(next_output) )
		  consume_rapids_queue( obj, next_output );
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



function launch_rapids_task(obj, next_running)

                    % load task file
                    TaskParam = read_input_file(rq, next_running);

                    % based on contents of task file, compress program into elements.zip
                    create_job_elements(obj, TaskParam);

                    % create job.properties
                    create_job_properties(obj);

                    % create new job using Rapids interface
		    create_rapids_job(obj);

                    % run job 
		    run_rapids_job(obj);

                    % create listener 
		    create_listener(obj);

		    % increment rapids queue
		    increment_rapids_queue();

end
