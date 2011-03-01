% Test the method which starts a single worker.
%
% Version 1
% 2/27/2011
% Terry Ferrett

function cwc_obj = start_worker_test()

cd ..;
cd ..;
cmlRoot = pwd;
CmlStartup
cd srv/
cd tests/

% Create cluster worker object
cwc_obj = cwc(cmlRoot, 'test.cfg', 'stub_worker');

cwc_obj.wSta('node01');
