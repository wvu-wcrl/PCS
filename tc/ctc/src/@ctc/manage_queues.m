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
%  ss - start      clear global and user running queues
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

% clear global queues
cmd = ['rm ' obj.gq.iq{1} '/*.mat &>/dev/null'];  system(cmd);
cmd = ['rm ' obj.gq.rq{1} '/*.mat &>/dev/null'];  system(cmd);
cmd = ['rm ' obj.gq.oq{1} '/*.mat &>/dev/null'];  system(cmd);


% loop over active users and clear running queues
nu = length(obj.users);
for k = 1:nu,
	  cmd = ['sudo rm ' obj.users{k}.rq{1}  '/*.mat &>/dev/null'];  system(cmd);
end




case 'stop'      % move running queue files to input queue
% move global running queue .mat files to input queue

msg = ['Task controller stopping.  Moving contents of global running queue to input queue.'];
PrintOut(msg, 0, obj.ctc_logfile{1}, 1);
mv_rq_to_iq(obj);


case 'resume'    % do not clear queues


end



end



% move files in global running queue to input queue
function mv_rq_to_iq(obj)

% strip worker id from workers
			cmd = ['sudo ' obj.bs{1} '/strip_wid.sh' ' ' obj.gq.rq{1}];
system(cmd);


% move running queue files to input queue
cmd = ['mv ' obj.gq.rq{1} '/*.mat' ' ' obj.gq.iq{1}];
system(cmd);


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

