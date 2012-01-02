% initialize the worker controller
rootdir = pwd;
cd ..; cd util/;
addpath(pwd);



cfg_file = 'two_worker.cfg';

cd(rootdir); cd ..; cd cfg/;

cfg_file = strcat(pwd, '/', cfg_file);

cd(rootdir);

cwcobj = cwc(cfg_file);
