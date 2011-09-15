% cSto.m
%
% Stop cluster workers.
%
% If called with no arguments
% Version 2
% 9/15/2011
% Terry Ferrett



function cSto(obj,varargin)

if nargin == 0,   % kill all workers unconditionally
    % Loop over all active workers and end worker processes.
    num_workers = length(obj.workers);
    for k = 1:num_workers,
        wSto(obj, obj.workers(1).wrkCnt);
    end
    
else if nargin == 1,
        
        % Loop over all active workers and stop workers running a particular worker script.
        num_workers = length(obj.workers);
        ws = varargin{1};
        
        % gather the IDs of the workers running the script 'ws'
        for k = 1:num_workers,
            if obj.workers(k).ws == ws,
                wrkid(k) = obj.worker(k).wrkCnt;
            end
        end
        
        % stop the workers running script 'ws'
        for k = 1:length(wrkid),
            wSto(obj, wrkid(k));
        end
        
        
    else
        error('Too many arguments to function cSto()');
    end
    
end    
