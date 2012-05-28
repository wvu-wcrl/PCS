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



% init job counter

obj.jc = 0;
obj.rtn = 'compiled_fsk';

% read logging parameters
    heading = '[logging]';
key = 'log_period';
out = util.fp(obj.cf, heading, key);
obj.log_period = out{1}{1}


key = 'num_logs';
out = util.fp(obj.cf, heading, key);
obj.num_logs = out{1}{1};


key = 'verbose_mode';
out = util.fp(obj.cf, heading, key);
obj.verbose_mode = out{1}{1};



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









