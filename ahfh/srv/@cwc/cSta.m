% cSta.m
%
% Stop all cluster workers.
%
% Version 1
% 2/28/2011
% Terry Ferrett

function cSta(obj)

% read the worker distribution from the configuration file
% if no distribution exists, default to the worker specified in the cwc constructor
 heading = '[Workers]';
 key = 'worker';
 out = util.fp(obj.cfp, heading, key);


% if workers were specified in the configuration file, use them.
%  otherwise, use the default worker specified in the cwc object
if(~isempty(out))
 nws = length(out);
 for k = 1:nws,
    ws{k} = out{k}{1};
    nwi(k) = str2num(out{k}{2});
 end
else

nws = 1;
ws = obj.workerScript;
nwi{1} = sum(obj.maxWorkers);
end



% the number of requested worker instances is greater than
%  the available number of workers. stop execution
if sum(nwi) > sum(obj.maxWorkers),
error('The number of requested workers in the configuration  file is greater than the maximum available.');
end



% start workers using the defined scripts and numbers of instances
wsc = nws;
wic = nwi(wsc);
num_nodes = length(obj.nodes);
   for l = 1:num_nodes,
      for m = 1:obj.maxWorkers(l)
        wSta(obj, obj.nodes{l},ws{wsc});
        wic = wic - 1;

	if wic ==0,
	   wsc = wsc - 1;
           if wsc == 0,
	    break;
           end
	   wic = nwi(wsc);
         end 
end
if wsc ==0,
break;
end
end




% Start the maximum number of workers on each node.
%num_nodes = length(obj.nodes);
%for k = 1:num_nodes,
%    for l = 1:obj.maxWorkers(k),
%        wSta(obj, obj.nodes{k});
%    end
%end

end
