% cSta.m
%
% Stop all cluster workers.
%
% Version 1
% 2/28/2011
% Terry Ferrett

function cSta(obj)

% Start the maximum number of workers on each node.
num_nodes = length(obj.nodes);
for k = 1:num_nodes,
    for l = 1:obj.maxWorkers(k),
        wSta(obj, obj.nodes{k});
    end
end
end
