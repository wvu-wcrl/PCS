% stow.m
%
% Stop worker.
%
% Version 2
% 9/18/2011
% Terry Ferrett


function stow(obj, wid)

so(obj,wid);  % shell out and call the worker stop script

obj.workers{wid}.pid = 0; % clear the pid

end




function so(obj, wid)
 
 % Form the command string.
 cs = [obj.bs, '/stop_worker.sh'];
 cs = [cs, ' ',...
     obj.workers{wid}.node, ' ',...
     obj.workers{wid}.pid];
 
 end
