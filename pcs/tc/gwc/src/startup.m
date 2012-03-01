% initialize the worker controller
rootdir = pwd;
cd ..; cd ..; cd ..;
cd util/;
addpath(pwd);



cfg_file = 'grid_worker.cfg';

cd(rootdir); cd ..; cd ..; cd cfg/;

cfg_file = strcat(pwd, '/', cfg_file);

cd(rootdir);

gwcobj = gwc(cfg_file);
