% cw.m
%
% create worker objects from configuration file data
%
% Version 1
% 9/18/2011
% Terry Ferrett

function cw(obj, cfd)

%cfd - structure containing the following entries
ws = cfd{1};  % worker script name
nd = cfd{2};  % node name
n = cfd{3};   % number of workers per node


% create worker object with

for k = 1:n,

% create command string
cs = ccs(obj, ws, nd);

% add worker object to array
new_wrk = wrk(hostname, obj.wrkCnt, ws, cs);
obj.workers(end+1) = new_wrk;

% increment the worker counter
obj.wrkCnt = obj.wrkCnt + 1;
svSt(obj);
end


end



function cs = ccs(obj, ws, nd)


% we need to pass cmlRoot, but starting with /rhome instead of /home
cmlPath = ['/r' obj.cmlRoot(2:end)];

%  Form the BASH command string.
wNum_str = int2str(obj.wrkCnt);
cs = [obj.bashScriptPath, '/start_worker.sh'];
cs = [cs, ' ',...
    nd, ' ',...
    obj.workerPath, ' ',...
    ws, ' ',...
    int2str(obj.wrkCnt), ' ', ...
    cmlPath];


end
