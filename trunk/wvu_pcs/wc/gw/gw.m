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



while(1)
    
    next_input = read_input_queue(iq); % read a random input file from the input queue
    
    if( ~isempty(next_input) )
        next_running = feed_running_queue(next_input, rq); % move the input file to the running queue
        input_struct = read_input_file(next_running); % read the input struct from the running queue
        
        
        % break down the input struct
        sim_param = input_struct.sim_param;     % simulation parameters
        sim_path = input_struct.sim_path;           % path to simulation code
        sim_fcn = input_struct.sim_fcn;                % entry routine into simulation code
        
        addpath(sim_path);   % add path to simulation code to global path
        
        % run the function with its input parameters
        fun_in = str2func(sim_fcn);
        save_param = feval(fun_in, sim_param);

        
        consume_running_queue(next_running, rq); % delete file from running queue
        write_output(sim_param, save_param, next_input); % write to output queue
        
        rmpath(sim_path);  % remove code paths from global path
    end
    
    
    pause(5); % wait 5 seconds before making another pass
    
end
end




function next_input = read_input_queue(iq)

srch = strcat(iq, '/*.mat');      % form full directory string

fl = dir( srch );    % get list of .mat files in input queue directory
    
nf = length(fl);  % how many input files does this user have?

next_input = ceil(rand*nf); % pick file randomly

end




function next_running = feed_running_queue(next_input, rq, wid)

% move the file to the running queue and tag with the worker id
[beg en] = strtok(next_input,'_');
next_running = [beg '_' int2str(wid) en];

cs = ['mv' ' ' iq '/' next_input ' ' next_running '/' fn];

system(cs);

end


function input_struct = read_input_file(next_running)
end



function consume_running_queue(next_running, rq)
end



function write_output(sim_param, save_param, next_input)
end


