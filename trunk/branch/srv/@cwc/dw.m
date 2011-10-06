% dw.m
%
% delete worker.
%
% Version 1
% 9/18/2011
% Terry Ferrett


function dw(obj, worker)


% execute the command string to stop the worker.
stoc = worker.stoc;
[stat] = system(stoc);

% delete the worker from the worker array

% Iterate over worker array and locate worker
%  having ID 'wNum'
n = length(obj.workers);
tempWrk = [];
for k = 1:n,
    if obj.workers(k).wrkCnt == worker.wrkCnt,
        tempWrk = obj.workers(k);
        break;
    end
end


% Remove worker from array.
workTmp = obj.workers(1:k-1);
workTmp = [workTmp obj.workers(k+1:end)];
obj.workers = workTmp;


% save cluster state
svSt(obj);
end
