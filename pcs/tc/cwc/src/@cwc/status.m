% status.m
%
% check worker status and revive dead workers
%
% Version 1
% 4/9/2012
% Terry Ferrett


function status(obj)

%%% named constants
IS_RUNNING = 0;        % worker running state
IS_NOT_RUNNING=1;

ALIVE = 0;             % worker is alive or dead
DEAD = 1;
%%%%%%%%%%%%%%%%%%





% iterate over all workers
n = length(obj.workers);


while(1)   % loop forever

for k = 1:n,
	  running_state = check_worker(obj.workers{k}); % check worker running state

          [obj] = maintain_worker(obj, obj.workers{k}, running_state);  % if the worker is dead, revive it
end


pause(60);   % pause for 60 seconds between passes.

end
end






function running_state = check_worker(worker)

% connect to the node containing the worker and check its state
  node = worker.node;
  pid = worker.pid;
 
cmd = ['ssh' ' ' node ' ' '"ps -p ' pid '" |wc |awk ''{print $1}'''];
[status ret] = system(cmd); 


% return state

if( strcmp(ret(1), '2') )
  running_state = 0;
else
  running_state = 1;
end


end




function  [obj]  = maintain_worker(obj, worker, running_state);

% if worker is dead, revive it
   if( running_state == 1 )
    staw(obj, worker.wid);
    sprintf(['Revived worker ' int2str(worker.wid)])
  end

end







