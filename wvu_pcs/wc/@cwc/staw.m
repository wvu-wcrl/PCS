% staw.m
%
% Start a single worker.
%
% Version 2
% 12/26/2011
% Terry Ferrett

function staw(obj, wid)

% execute shell command to start worker - so -shell out
[stat pid] = so(obj, wid)

% store the pid in the worker object
workers{wid}.pid = pid;

% start the worker by executing the command string
%[stat pid] = system(worker.stac);



% create the command string which stops the worker
%worker.stoc = ccs(obj, worker);

end





function [stat pid] = so(obj, wid)


cmlPath = ''; %leave null for now.

cs = [obj.bs{1}  '/start_worker.sh'];
cs = [cs, ' ',...
	obj.workers{wid}.node, ' ',...
	obj.gwp{1}, ' ',...
	obj.gwn{1}, ' ',...
    int2str(wid), ' ', ...
    cmlPath];

cs
[stat pid] = system(cs);

end
