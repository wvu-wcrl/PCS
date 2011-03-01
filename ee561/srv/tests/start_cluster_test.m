% Test the cluster start method of the cluster worker
%   controller.
%
% Version 1
% 2/28/2011
% Terry Ferrett

function cwc_obj = start_cluster_test()

cd ..;
cd ..;
cmlRoot = pwd;
cd srv/
cd tests/

% Create cluster worker object
cwc_obj = cwc(cmlRoot, 'test.cfg', 'stub_worker');

cwc_obj.cSta();

pause(10);

cwc_obj.cSto();