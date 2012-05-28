% cSta.m
%
% Start all cluster workers.
%
% Version 2
% 12/26/2011
% Terry Ferrett
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.



function cSta(obj, varargin)


% log message about starting workers across the entire cluster
msg = ['Workers launching across entire cluster.'];
PrintOut(msg, 0, obj.cwc_logfile{1}, 1);


n = length(obj.workers);
obj.workers;

if nargin == 1,   % start all workers unconditionally
    % Loop over all active workers and start worker processes.
    n = length(obj.workers);
    for k = 1:n,
        % log message about starting worker
            msg = ['Worker' ' ' int2str(obj.workers{k}.wid) ' ' 'starting on' ' ' obj.workers{k}.node];
            PrintOut(msg, 0, obj.cwc_logfile{1}, 1);
	      staw(obj, obj.workers{k}.wid );
    end
    
 else
        error('Too many arguments to function cSto()');

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
