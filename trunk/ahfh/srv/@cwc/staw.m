% staw.m
%
% Start a single worker.
%
% Version 2
% 9/18/2011
% Terry Ferrett

function staw(obj, worker)

% start the worker by executing the command string
[stat pid] = system(worker.cs);

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
