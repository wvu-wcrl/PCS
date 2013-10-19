% manage_queues.m
%
% manage queues during cluster startup
%
% Version 1
% 5/14/2012
% Terry Ferrett
%
% input
%
%  ss   start      clear global and user running queues
%       stop       move global running queue files to input queue
%       resume     no action
%       shutdown   no action
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.

function manage_queues(obj,ss)


switch lower(ss)

 
case 'start'   % clear global queues and user running queues
   msg = ['Task controller starting.  Clearing global queues.'];
            PrintOut(msg, 0, obj.ctc_logfile{1}, 1);

clear_global_queues( obj );


move_u_rq_iq( obj.users )



case 'stop'      % move running queue files to input queue

% move global running queue .mat files to input queue

msg = ['Task controller stopping.  Moving contents of global running queue to input queue.'];
PrintOut(msg, 0, obj.ctc_logfile{1}, 1);

clear_global_queues( obj );

move_u_rq_iq( obj.users );


case 'resume'    % do not clear queues
end

end


		    

% clear global queues
function clear_global_queues( obj )
cmd = ['rm ' obj.gq.iq{1} '/*.mat &>/dev/null'];  system(cmd);
cmd = ['rm ' obj.gq.rq{1} '/*.mat &>/dev/null'];  system(cmd);
%cmd = ['rm ' obj.gq.oq{1} '/*.mat &>/dev/null'];  system(cmd);
end


% move user task files in runnning queues to input queues
function move_u_rq_iq( users )
nu = length(users);
for k = 1:nu,
	  cmd = ['sudo mv ' users{k}.rq{1}  '/*.mat'  ' ' users{k}.iq{1} ];
          system(cmd);
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

