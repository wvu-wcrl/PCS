% test the worker controller using the worker controller using config
%  files of the form  
%    [Workers]
%    work = 'worker script' 'node' 'instances'
%
%
% Version 1
% 9/19/2011
% Terry Ferrett

function cwc_obj = test_v3()

cd ..;
cd ..;
cmlRoot = pwd;
CmlStartup
cd srv/
cd tests/

% Create cluster worker object
cwc_obj = cwc(cmlRoot, 'test_v3');

cwc_obj.cSta();

% Wait 10 seconds, and then slay all workers.
pause(10);

cwc_obj.cSto();


% wait 5 seconds, start all workers, and kill by name.
% you may want to pop some tops on nodes 2 and 11 to watch this
pause(5);

cwc_obj.cSta();

pause(3);
cwc_obj.cSto('stub_worker');
