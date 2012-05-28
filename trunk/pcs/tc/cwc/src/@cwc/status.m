% status.m
%
% check worker status and revive dead workers
%
% Version 1
% 4/9/2012
% Terry Ferrett
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.


function status(obj)

%%% named constants
IS_RUNNING = 0;        % worker running state
IS_NOT_RUNNING=1;

ALIVE = 0;             % worker is alive or dead
DEAD = 1;
%%%%%%%%%%%%%%%%%%





% iterate over all workers
n = length(obj.workers);


while(1)   % loop forever
    
    for k = 1:n,
        running_state = check_worker(obj.workers{k}); % check worker running state
        
        [obj] = maintain_worker(obj, obj.workers{k}, running_state);  % if the worker is dead, revive it
    end
    
    
    pause(60);   % pause for 60 seconds between passes.
    
end
end






function running_state = check_worker(worker)

% connect to the node containing the worker and check its state
node = worker.node;
pid = worker.pid;

cmd = ['ssh' ' ' node ' ' '"ps -p ' pid '" |wc |awk ''{print $1}'''];
[status ret] = system(cmd);


% return state

if( strcmp(ret(1), '2') )
    running_state = 0;
else
    running_state = 1;
end


end




function  [obj]  = maintain_worker(obj, worker, running_state);



% if worker is dead, revive it
if( running_state == 1 )
    staw(obj, worker.wid);
    
    % log message about reviving worker
        msg = ['Reviving worker ' int2str(worker.wid)];
        PrintOut(msg, 0, obj.cwc_logfile{1}, 1);
end

end



%     This library is free software;
%     you can redistribute it and/or modify it under the terms of
%     the GNU Lesser General Public License as published by the
%     Free Software Foundation; either version 2.1 of the License,
%     or (at your option) any later version.
%
%     This library is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%     Lesser General Public License for more details.
%
%     You should have received a copy of the GNU Lesser General Public
%     License along with this library; if not, write to the Free Software
%     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA




