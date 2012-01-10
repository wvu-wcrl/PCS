% gw.m
%
% generic worker function
%
% reads struct containing
%  entry function
%  path to code
%  struct containing parameters
%
% Version 1
% 12/26/2011
% Terry Ferrett

function gw(wid, iq, rq, oq)
%varagin

default_path = path; % save the default path.

% global task controller directories
%iq = gq.iq;     %input
%rq = gq.rq;    % running
%oq = gq.oq;  %output
%ld = gq.ld;    %log dir

   [year month day hour min sec] = gettime(); % current time 

   ls = ['Worker' ' ' int2str(wid) ' ' 'started at' ' '  year '-' month '-' day ' ' hour ':' min ':' sec];
   fprintf(ls);


while(1)
    
    next_input = read_input_queue(iq); % read a random input file from the input queue


    
    if( ~isempty(next_input) )

      
        next_running= feed_running_queue(next_input, iq, rq, wid); % move the input file to the running queue
        input_struct = read_input_file(rq, next_running); % read the input struct from the running queue
        
        
        % break the input struct into local variables
        TaskParam = input_struct.TaskParam;     % simulation parameters
        FunctionPath = input_struct.FunctionPath;           % path to simulation code
        FunctionName = input_struct.FunctionName;                % entry routine into simulation code
        
        addpath(FunctionPath);   % add path to simulation code to global path
        
        % run the function with its input parameters
        FunctionName = str2func(FunctionName);
      


   [year month day hour min sec] = gettime(); % current time 
   username = strtok(next_running, '_');  % username


   task_name = get_task_name(next_input);


   ls = ['Executing task' ' ' task_name ' ' 'from user' ' ' username  ' ' 'at'  ' ' year '-' month '-' day ' ' hour ':' min ':' sec];
   fprintf(ls);
fprintf('\n');
        
output_struct = feval(FunctionName, TaskParam);


   [year month day hour min sec] = gettime(); % current time
   ls = ['Task' ' ' task_name ' ' 'from user'  ' ' username ' ' 'complete' ' ' 'at'  ' ' year '-' month '-' day ' ' hour ':' min ':' sec];
   fprintf(ls);
fprintf('\n');

        
        
        consume_running_queue(next_running, rq); % delete file from running queue
        write_output(input_struct, output_struct, next_input, oq); % write to output queue
        
        path(default_path); % restore the default path
    end
    
    
    pause(5); % wait 5 seconds before making another pass
    
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
next_running = [beg '_' int2str(wid) en];


cs = ['mv' ' ' iq '/' next_input ' ' rq '/' next_running ];



system(cs);

end





function input_struct = read_input_file(rq, next_running)

lf = [rq '/' next_running];

load(lf);

% data file contains   
        % data file contains
            % input_struct
                 % fcn_param
                 % fcn_path
                 % fcn
            % output_struct
                % fcn_res
end






function consume_running_queue(next_running, rq)

cs = ['rm' ' ' rq '/' next_running];
system(cs);

end



function write_output(input_struct, output_struct, next_input, oq)

op = [oq '/' next_input];

save(op, 'input_struct', 'output_struct');

end



function [year month day hour min sec] = gettime();
   timevec = fix(clock);  % time
 year = int2str(timevec(1)); month = int2str(timevec(2)); day = int2str(timevec(3)); 
 hour = int2str(timevec(4)); min = int2str(timevec(5)); sec = int2str(timevec(6));
end






function  task_name = get_task_name(next_input)


  [beg task_name] = strtok(next_input, '_');

task_name = task_name(2:end-4);

end
