% Test the constructor of the cluster worker
%   controller.
%
% Version 1
% 2/27/2011
% Terry Ferrett

function cwc_obj = start_worker_test(cml_home)

cd ..;
cd ..;
cmlRoot = pwd;
cd srv/
cd tests/

% Create cluster worker object
cwc_obj = cwc(cmlRoot, 'test.cfg', 'stub_worker');

cwc_obj.wSta('node01');
