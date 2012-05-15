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




end
