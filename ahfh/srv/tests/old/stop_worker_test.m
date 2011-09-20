% Test the worker stopping method.
%
% Version 1
% 2/28/2011
% Terry Ferrett

function cwc_obj = stop_worker_test()

cd ..;
cd ..;
cmlRoot = pwd;
CmlStartup;
cd srv/
cd tests/

% Create cluster worker object
cwc_obj = cwc(cmlRoot, 'test.cfg', 'stub_worker');

cwc_obj.wSta('node01');

pause(10);

cwc_obj.wSto(0);
