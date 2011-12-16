% init_ws.m
%
% initialize worker state structure
%
% Version 1
% 12/7/2011
% Terry Ferrett


function init_ws(obj)

% read worker list and workers per node
heading = '[workers]';
key = 'worker';
out = util.fp(obj.cfp, heading, key);
wrklist = out;


n = length(wrklist);  % number of nodes
for k = 1:n,
    nl{k} = wrklist{k}{1};   % node name
    wpn{k} = str2double( wrklist{k}{2} ); %workers per node
end


nw = 1; % number of workers
n = length(nl);   % number of nodes
for k = 1:n,
    for l = 1:wpn{k},
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










