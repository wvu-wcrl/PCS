% init_ws.m
%
% initialize worker state structure
%
% Version 1
% 12/7/2011
% Terry Ferrett
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.

function init_ws(obj)

% read worker list and workers per node
heading = '[workers]';
key = 'worker';
out = util.fp(obj.cfp, heading, key);
wrklist = out;


n = length(wrklist);  % number of nodes
for k = 1:n,
    nl{k} = wrklist{k}{1};   % node name
    wpn{k} = str2double( wrklist{k}{2} ); %workers per node
end


nw = 1; % number of workers
n = length(nl);   % number of nodes
for k = 1:n,
    for l = 1:wpn{k},
        tmp.wid = nw;
        tmp.user = '';
        tmp.status = '';
        obj.ws{nw} = tmp;
        nw = nw + 1;
    end
end

obj.nw = nw-1;   % total number of workers
obj.aw = 0;         % all workers are idle

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







