% staw.m
%
% Start a single worker.
%
% Version 2
% 12/26/2011
% Terry Ferrett
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.


function staw(obj, wid)

% execute shell command to start worker - so -shell out
[stat pid] = so(obj, wid);

% store the pid in the worker object
obj.workers{wid}.pid = pid;


end



function [stat pid] = so(obj, wid)


  [bg iqr] = strtok(obj.gq.iq{1}, '/');
  [bg rqr] = strtok(obj.gq.rq{1}, '/');
  [bg oqr] = strtok(obj.gq.oq{1}, '/');
  [bg lp] = strtok(obj.lp{1}, '/');
  [bg lfup] = strtok(obj.lfup{1}, '/');

iqr = ['/rhome' iqr];
rqr = ['/rhome' rqr];
oqr = ['/rhome' oqr];
lp =  ['/rhome' lp '/' int2str(wid) '.log'];
lfup = ['/rhome' lfup];

cs = [obj.bs{1}  '/start_worker.sh'];

cs = [cs, ' ',...
	obj.workers{wid}.node, ' ',...
	obj.gwp{1}, ' ',...
	obj.gwn{1}, ' ',...
    int2str(wid), ' ', ...
	iqr, ' ',...
        rqr, ' ',...
        oqr,' ',...
        lfup, ' ',...
        lp, ' ',...
        obj.log_period, ' ',...
        obj.num_logs,' ',...
        obj.verbose_mode]



  [stat pid] = system(cs);
pid

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
