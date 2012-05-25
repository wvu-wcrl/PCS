rootdir = pwd;

cd ..; addpath(pwd); cd(rootdir);  % add gw to path

% set queue paths
cd iq; iq = pwd; cd(rootdir);
cd oq; oq = pwd; cd(rootdir);
cd rq; rq = pwd; cd(rootdir);

% copy input to input queue
cs = ['cp' ' ' 'test_task_1.mat' ' ' iq '/' 'tferrett_' 'test_task_1.mat'];
system(cs);

lfup = '/home/tferrett/proj/iscml/pcs/util/log';
lfip = '/home/tferrett/';
LOG_PERIOD = 10000;
NUM_LOGS = 2;
VERBOSE_MODE = 0;

% start generic worker
cd(rootdir);


gw(1, iq, rq, oq, lfup, lfip, LOG_PERIOD, NUM_LOGS, VERBOSE_MODE);


% observe queues
