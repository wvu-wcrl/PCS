% startup script for task controller

rootdir = pwd;
addpath(rootdir);
cd ..; cd ..; cd util/; addpath(pwd);
cd(rootdir);


cd ..; cd ..; cd cfg/;


cfg_file = strcat(pwd,'/','two_worker.cfg');


cs(0);
cd(rootdir);


ctcobj = ctc(cfg_file);
