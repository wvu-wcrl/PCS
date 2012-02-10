function slay(obj)

% Loop over all active nodes and end worker processes.
n = length(obj.workers);
m = length(obj.nodes);


% Form the command string.
cmd_str_base = [obj.bs{1} '/slay_worker.sh'];


% Slay the workers on all active nodes.
for k = 1:m,
cmd_str = [cmd_str_base, ' ' obj.nodes{k}];    
[stat output] = system(cmd_str);
end




for k = 1:n,

% Null the worker process ids.
obj.workers{n}.pid = 0;

end




end
