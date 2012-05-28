% tc_startup.m
% Startup script for cluster task controller.
%
% Inputs
%  cfg_file         full path to task controlelr configuration file
%  startup_type     task controller startup mode taking one value from {start, stop, resume, shutdown}
% 
% Outputs
%  ctcobj           task controller object
%
%
%     Last updated on 5/15/2012
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.



% startup script for task controller
%
%%%inputs
%
% cfg_file
%  configuration file specifying task controller parameters
%
%
% startup_type
%  'startup' - clear global and user running queues
%  'resume' - leave queues in existing state and start controllers
%%%%%%%%%% 




function ctcobj = tc_startup(cfg_file, startup_type)



rootdir = pwd;              % make the current directory the root
addpath(rootdir);



cd ..; cd ..; cd ..;
cd util/; addpath(pwd);  % add file parser code to path




cd(rootdir);
cd ..; cd ..; cd cfg/; cfg_file = strcat(pwd,'/', cfg_file);     % current config file


       

cd(rootdir);
ctcobj = ctc(cfg_file, startup_type);     % create task controller object


if strcmp(startup_type, 'stop') || strcmp(startup_type, 'shutdown')
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
