% init_queue.m
%
% read queue parameters from queue configuration file
%
% Version 1
% 3/23/2013
% Terry Ferrett
%
%     Copyright (C) 2013, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.

function init_queue(obj)
 

  % maximum files in input queue at any time
  heading = '[queue]';
  key = 'mfiq';
  out = util.fp(obj.cfp, heading, key);
  obj.mfiq = str2double(out{1}{1});
  
  
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






