% cstat.m
%
% check status of specified worker
%
% Version 1
% 9/21/2011
% Terry Ferrett

function [NumberWorkers nodes] = cstat(obj, ws)
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
    cs = ['ssh ' obj.nodes{k} ' ps aux| grep -i '  ws ];
    [~, pr] = system( cs );


c1 = length(pr) > 0;    
if c1,
  c2 = strcmp( pr(1:3), 'ssh' );
  if c2, % node is down
        nw(k) = 0;
    else
        hits = findstr( pr, ws );
        nw(k) = length( hits );
    end
	else
	  nw(k) = 0;
end
    
end


NumberWorkers = nw;
nodes = obj.nodes;

% return total number of workers running 'worker script'
%tot = sum(nw);


end
