% init_misc.m
%
% initialize miscellaneous parameters
%
% Version 1
% 5/2014
% Terry Ferrett
%
%     Copyright (C) 2014, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.


function init_misc(obj)

% blank username by default
obj.bu.username = '';

% execute one task on resume from blocking
obj.bu.tu = 1;

% no user is blocked by default
obj.bu.isbl = 0;

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
