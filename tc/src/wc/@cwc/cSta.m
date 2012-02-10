% cSta.m
%
% Start all cluster workers.
%
% Version 2
% 12/26/2011
% Terry Ferrett

function cSta(obj, varargin)

n = length(obj.workers);
obj.workers;

if nargin == 1,   % start all workers unconditionally
    % Loop over all active workers and start worker processes.
    n = length(obj.workers);
    for k = 1:n,
	      staw(obj, obj.workers{k}.wid );
    end
    
 else
        error('Too many arguments to function cSto()');

end

end
