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


% clean PCS temporary directory on all nodes
msg = ['Cleaning PCS temporary directory (/tmp/pcs) contents on all nodes.'];
PrintOut(msg, 0, obj.cwc_logfile{1}, 1);
cptd(obj, obj.nodes);



% log message about starting workers across the entire cluster
msg = ['Workers launching across entire cluster.'];


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



function cptd(obj, nodes)

    % Loop over all nodes and clean temporary directory.
    n = length(nodes);
    for k = 1:n,
    % log message about cleaning
    msg = ['Cleaning temporary directory /tmp/pcs on ' ' ' nodes{k}];
    PrintOut(msg, 0, obj.cwc_logfile{1}, 1);


    cs = [obj.bs{1}  '/clean_pcs_tmp.sh'];
    cs = [cs, ' ', nodes{k}, ' &' ]
    [stat pid] = system(cs);
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
