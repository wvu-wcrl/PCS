% init_cfg.m
%
% initialize controller configuration structure
%
% Version 1
% 12/7/2011
% Terry Ferrett


function init_cfg(obj)

obj.cfg.qp = obj.qp;  % queue path

n = length(obj.wrklist);  % number of nodes
for k = 1:n,
    obj.cfg.nl{k} = obj.wrklist{k}{1};   % node name
    obj.cfg.wpn{k} = str2double( obj.wrklist{k}{2} ); %workers per node
end

end










