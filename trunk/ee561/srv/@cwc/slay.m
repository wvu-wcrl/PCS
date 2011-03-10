% slay.m
%
% Unconditionally stop all MATLAB instances on
% worker nodes.
%
% Version 1
% 3/9/2011
% Terry Ferrett

function slay(obj)

% Loop over all active nodes and end worker processes.
num_nodes = length(obj.nodes);


% Form the command string.
cmd_str_base = [obj.bashScriptPath, '/slay_worker.sh'];


% Slay the workers on all active nodes.
for k = 1:num_nodes,
    cmd_str = [cmd_str_base, ' ',...
        obj.nodes{k}];    
    [stat output] = system(cmd_str);
end


% Null the worker array.
obj.workers = [];
end
