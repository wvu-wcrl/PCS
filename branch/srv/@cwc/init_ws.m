% init_ws.m
%
% initialize worker state structure
%
% Version 1
% 12/7/2011
% Terry Ferrett


function init_ws(obj)

nw = 1; % number of workers
n = length(obj.cfg.nl);   % number of nodes
for k = 1:n,
    for l = 1:obj.cfg.wpn{k},
        tmp.wid = nw;
        tmp.user = '';
        tmp.status = '';
        obj.ws{nw} = tmp;
        nw = nw + 1;
    end
end

obj.nw = nw-1;   % total number of workers
obj.aw = 0;         % all workers are idle
    
    
end










