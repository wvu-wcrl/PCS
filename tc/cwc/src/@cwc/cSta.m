% cSta.m
%
% Start all cluster workers.
%
% Version 2
% 12/26/2011
% Terry Ferrett

function cSta(obj, varargin)


% log message about starting workers across the entire cluster
msg = ['Workers launching across entire cluster.'];
PrintOut(msg, 0, obj.cwc_logfile{1}, 1);


n = length(obj.workers);
obj.workers;

if nargin == 1,   % start all workers unconditionally
    % Loop over all active workers and start worker processes.
    n = length(obj.workers);
    for k = 1:n,
        % log message about starting worker
            msg = ['Worker' ' ' int2str(obj.workers{k}.wid) ' ' 'starting on' ' ' obj.workers{k}.node];
            PrintOut(msg, 0, obj.cwc_logfile{1}, 1);
	      staw(obj, obj.workers{k}.wid );
    end
    
 else
        error('Too many arguments to function cSto()');

end

end
