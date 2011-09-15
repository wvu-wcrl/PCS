% wSta.m
%
% Start a single worker.
%
% Version 1
% 2/28/2011
% Terry Ferrett

function wSta(obj, hostname, ws)

% we need to pass cmlRoot, but starting with /rhome instead of /home
cmlPath = ['/r' obj.cmlRoot(2:end)];

% 1. Form the BASH command string.
wNum_str = int2str(obj.wrkCnt);
cmd_str = [obj.bashScriptPath, '/start_worker.sh'];
cmd_str = [cmd_str, ' ',...
    hostname, ' ',...
    obj.workerPath, ' ',...
    ws, ' ',...
    int2str(obj.wrkCnt), ' ', ...
    cmlPath];

% 2. Execute the BASH command to start a worker.
[stat pid] = system(cmd_str);

% 3. Create a worker object from
%     hostname
%     process ID
%     worker ID
%     worker script
newWrkObj = cWrk(hostname, pid, obj.wrkCnt, ws);

% Add the new worker object to the worker array.
obj.workers(end+1) = newWrkObj;

% Increment the worker counter
obj.wrkCnt = obj.wrkCnt + 1;
svSt(obj);
end
