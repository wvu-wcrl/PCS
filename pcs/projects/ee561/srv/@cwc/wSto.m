% wSto.m
%
% Stop worker having ID 'wNum'.
%
% Version 1
% 2/28/2011
% Terry Ferrett


function wSto(obj, wNum)

% Iterate over worker array and locate worker
%  having ID 'wNum'
numWorkers = length(obj.workers);
tempWrk = [];
for k = 1:numWorkers,
    if obj.workers(k).wrkCnt == wNum,
        tempWrk = obj.workers(k);
        break;
    end
end

% If no workers were found, set the output to null and return.
if isempty(tempWrk)
    sprintf('Worker %d not found. \n', wNum);
    return;
end


% Form the command string.
cmd_str = [obj.bashScriptPath, '/stop_worker.sh'];
cmd_str = [cmd_str, ' ',...
    tempWrk.hostname, ' ',...
    tempWrk.pid];

% Run the BASH script which stops the worker.
[stat] = system(cmd_str);


% Remove worker from array.
workTmp = obj.workers(1:k-1);
workTmp = [workTmp obj.workers(k+1:end)];
obj.workers = workTmp;

% Save cluster state.
svSt(obj);

end
