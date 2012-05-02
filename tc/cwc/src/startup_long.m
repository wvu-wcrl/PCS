% initialize the worker controller
rootdir = pwd;
cd ..; cd ..; cd ..;
cd util/;
addpath(pwd);



cfg_file = 'pcs_long_224.cfg';

cd(rootdir); cd ..; cd ..; cd cfg/;

cfg_file = strcat(pwd, '/', cfg_file);

cd(rootdir);

cwcobj = cwc(cfg_file);
