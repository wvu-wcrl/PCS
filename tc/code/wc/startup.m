% initialize the worker controller
rootdir = pwd;
cd ..; cd util/;
addpath(pwd);



cfg_file = 'pcs_test_2.cfg';

cd(rootdir); cd ..; cd cfg/;

cfg_file = strcat(pwd, '/', cfg_file);

cd(rootdir);

cwcobj = cwc(cfg_file);
