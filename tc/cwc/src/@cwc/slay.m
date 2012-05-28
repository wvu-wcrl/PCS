%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.


function slay(obj)


% log message about slaying workers
    msg = ['Slaying all workers.'];
            PrintOut(msg, 0, obj.cwc_logfile{1}, 1);

% Loop over all active nodes and end worker processes.
n = length(obj.workers);
m = length(obj.nodes);


% Form the command string.
cmd_str_base = [obj.bs{1} '/slay_worker.sh'];


% Slay the workers on all active nodes.
for k = 1:m,
cmd_str = [cmd_str_base, ' ' obj.nodes{k}];    
[stat output] = system(cmd_str);
end




for k = 1:n,

% Null the worker process ids.
obj.workers{n}.pid = 0;

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
