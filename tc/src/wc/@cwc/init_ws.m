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
out = util.fp(obj.cf, heading, key);
wrklist = out;


% split data from input file into multiple variables
n = length(wrklist);  % number of nodes
for k = 1:n,
    nl{k} = wrklist{k}{1};   % node name
    wpn{k} = str2double( wrklist{k}{2} ); %workers per node
end

% store the node list
    obj.nodes = nl;

% create initial worker structs
nw = 1; % number of workers
n = length(nl);   % number of nodes
for k = 1:n,
    for l = 1:wpn{k},
        tmp.wid = nw;
        tmp.node = nl{k};
        tmp.pid = 0;
        obj.workers{nw} = tmp;
        nw = nw + 1;
    end
end


% read logging parameters
    heading = '[logging]';
key = 'log_period';
out = util.fp(obj.cf, heading, key);
obj.log_period = out{1}{1};



key = 'num_logs';
out = util.fp(obj.cf, heading, key);
obj.num_logs = out{1}{1};



end










