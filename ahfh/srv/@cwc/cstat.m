% cstat.m
%
% check status of specified worker
%
% Version 1
% 9/21/2011
% Terry Ferrett

function [NumberWorkers] = cstat(obj, ws)
% == outputs ==
% tot    total number of running processes



% form array of pids from worker objects
% n = length(obj.workers);   % number of workers
% l = 1;
% for k = 1:n,
%     if ( strcmp(obj.workers(k).ws, ws) ),
%         apid(l) = obj.workers(k).pid;
%         l = l + 1;
%     end
% end


% query all active pids
n = length(obj.nodes);
for k = 1:n,
    cs = ['ssh ' nodes{k} ' ps aux| grep -i ' ws];
    [~, pr] = system( cs );
    
    if strcmp( pr(1:3), 'ssh' ) % node is down
        nw(k) = 0;
    else
        hits = findstr( pr, 'outage_worker' );
        nw(k) = length( hits );
    end
    
end


NumberWorkers = nw;
% return total number of workers running 'worker script'
%tot = sum(nw);






% start the worker by executing the command string
[stat pid] = system(worker.stac);

% store the pid in the worker object
worker.pid = pid;

% create the command string which stops the worker
worker.stoc = ccs(obj, worker);

end



function cs = ccs(obj, worker)

% Form the command string.
cs = [obj.bashScriptPath, '/stop_worker.sh'];
cs = [cs, ' ',...
    worker.hostname, ' ',...
    worker.pid];

end
