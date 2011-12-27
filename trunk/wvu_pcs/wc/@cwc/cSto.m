% cSto.m
%
% Stop cluster workers.
%
% If called with no arguments
% Version 1
% 12/26/2011
% Terry Ferrett



function cSto(obj,varargin)

if nargin == 1,   % kill all workers unconditionally
    % Loop over all active workers and end worker processes.
    n = length(obj.workers);
    for k = 1:n,
        stow(obj, obj.workers{k}.wid);
    end
    %
    % else if nargin == 2,
    %
    %         % Loop over all active workers and stop workers running a particular worker script.
    %         n = length(obj.workers);
    %         ws = varargin{1};
    %
    %
    %
    %         % gather the IDs of the workers running the script 'ws'
    %         l = 1;
    %         for k = 1:n,
    %             if strcmp(obj.workers(k).ws, ws),
    %                 wrk_array(l) = obj.workers(k);
    %                 l = l + 1;
    %             end
    %         end
    %
    %         % stop the workers running script 'ws'
    %         for k = 1:length(wrk_array),
    %             stow(obj, wrk_array(k));
    %         end
    %
    %
else
    error('Too many arguments to function cSto()');
end

end
