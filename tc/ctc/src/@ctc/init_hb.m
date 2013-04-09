% init_hb.m
%
% read heartbeat parameters from queue configuration file
%
% Version 1
% 4/8/2013
% Terry Ferrett
%
%     Copyright (C) 2013, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.

function init_hb(obj)
 
  % heartbeat path
  heading = '[heartbeat]';
  key = 'hb_path';
  out = util.fp(obj.cfp, heading, key);
  obj.hb_path = out{1}{1};


  % heartbeat period in seconds
  heading = '[heartbeat]';
  key = 'hb_period';
  out = util.fp(obj.cfp, heading, key);
  obj.hb_period = str2double(out{1}{1});

 
  
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






