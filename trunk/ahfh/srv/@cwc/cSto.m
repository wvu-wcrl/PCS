% cSto.m
%
% Stop all cluster workers.
%
% Version 1
% 2/28/2011
% Terry Ferrett

function cSto(obj)
% Loop over all active workers and end worker processes.
num_workers = length(obj.workers);
for k = 1:num_workers,
    wSto(obj, obj.workers(1).wrkCnt);
end
end
