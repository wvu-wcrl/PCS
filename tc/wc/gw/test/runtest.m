rootdir = pwd;

cd ..; addpath(pwd); cd(rootdir);  % add gw to path

% set queue paths
cd iq; iq = pwd; cd(rootdir);
cd oq; oq = pwd; cd(rootdir);
cd rq; rq = pwd; cd(rootdir);

% copy input to input queue
cs = ['cp' ' ' 'test_task_1.mat' ' ' iq '/' 'tferrett_' 'test_task_1.mat'];
system(cs);

% start generic worker
cd(rootdir);
gw(1, iq, rq, oq);


% observe queues
