% tc_startup.m
% Startup script for AWS task controller.
%
% Inputs
%  cfg_file         full path to task controller configuration file
%  ss               Startup state, taking one value from {start, stop, resume, shutdown}
% 
% Outputs
%  ctcobj           task controller object
%
%
%     Last updated on 11/9/2016
%
%     Copyright (C) 2016, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.


function ctcobj = tc_startup(cfg_file, ss)

rootdir = pwd;              % make the current directory the root
addpath(rootdir);

cd ..; cd ..; cd ..;
cd util/; addpath(pwd);  % add file parser code to path

cd(rootdir);
cd ..; cd ..; cd cfg/; cfg_file = strcat(pwd,'/', cfg_file);     % current config file

cd(rootdir);
ctcobj = atc(cfg_file, ss);     % create task controller object


if strcmp(ss, 'stop') || strcmp(ss, 'shutdown')
exit;
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
