% cSta.m
%
% Start all cluster workers.
%
% Version 2
% 9/18/2011
% Terry Ferrett

function cSta(obj, varargin)


if nargin == 1,   % start all workers unconditionally
    % Loop over all active workers and start worker processes.
    n = length(obj.workers);
    for k = 1:n,
        staw(obj, obj.workers(k) );
    end

elseif nargin == 2, % start workers by name

  % Loop over all active workers and locate workers running a particular worker script.
        n = length(obj.workers);
        ws = varargin{1};

        
        % gather worker objects running the script 'ws'
        l = 1;
        for k = 1:n,
            if strcmp(obj.workers(k).ws, ws),
                wrk_array(l) = obj.workers(k);
                l = l + 1;
            end
        end
        
        % start the workers running script 'ws'
        for k = 1:length(wrk_array),
            staw(obj, wrk_array(k));
        end

else
        error('Too many arguments to function cSto()');

end
