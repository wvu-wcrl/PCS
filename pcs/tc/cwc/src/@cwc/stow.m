% stow.m
%
% Stop worker.
%
% Version 2
% 9/18/2011
% Terry Ferrett
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.



function stow(obj, wid)

so(obj,wid);  % shell out and call the worker stop script

obj.workers{wid}.pid = 0; % clear the pid

end




function so(obj, wid)
 
 % Form the command string.
cs = [obj.bs{1}, '/stop_worker.sh'];
 cs = [cs, ' ',...
     obj.workers{wid}.node, ' ',...
	  obj.workers{wid}.pid ]
 
   system(cs);
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
