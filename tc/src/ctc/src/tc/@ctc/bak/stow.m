% stow.m
%
% Stop worker.
%
% Version 2
% 9/18/2011
% Terry Ferrett


function stow(obj, worker)


% execute the command string to stop the worker.
stoc = worker.stoc;
[stat] = system(stoc);

% clear the pid
worker.pid = 0;

end

