% startup script for task controller

rootdir = pwd;
addpath(rootdir);


cd ..; cd ..; cd ..; cd ..;
cd util/; addpath(pwd);  % add file parser code to path


cd(rootdir);


cd ..; cd ..; cd cfg/; cfg_file = strcat(pwd,'/','pcs_test_224.cfg'); % current config file



addpath(strcat(rootdir, '/tc'))

       

cd(rootdir);



ctcobj = ctc(cfg_file);
