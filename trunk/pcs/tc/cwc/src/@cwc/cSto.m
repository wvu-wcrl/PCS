% cSto.m
%
% Stop cluster workers.
%
% If called with no arguments
% Version 1
% 12/26/2011
% Terry Ferrett
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.



function cSto(obj,varargin)

% log message about stopping workers across entire cluster
msg = ['Workers stopping across entire cluster.'];
PrintOut(msg, 0, obj.cwc_logfile{1}, 1);


if nargin == 1,   % kill all workers unconditionally
    % Loop over all active workers and end worker processes.
    n = length(obj.workers);
    for k = 1:n,
        % log message about stopping individual worker
            msg = ['Worker' ' ' int2str(obj.workers{k}.wid) ' ' 'stopping on' ' ' obj.workers{k}.node];
            PrintOut(msg, 0, obj.cwc_logfile{1}, 1);
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
