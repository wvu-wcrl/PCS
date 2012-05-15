% manage_queues.m
%
% manage queues during cluster startup
%
% Version 1
% 5/14/2012
% Terry Ferrett
%
% input
%
%  ss - start      clear global and user running queues
%       stop       move global running queue files to input queu
%       resume     no action
%       shutdown   no action


function manage_queues(obj,ss)



switch lower(ss)


 
case 'start'   % clear global queues and user running queues


% clear global queues
cmd = ['rm ' obj.gq.iq{1} '/*.mat &>/dev/null'];  system(cmd);
cmd = ['rm ' obj.gq.rq{1} '/*.mat &>/dev/null'];  system(cmd);
cmd = ['rm ' obj.gq.oq{1} '/*.mat &>/dev/null'];  system(cmd);


% loop over active users and clear running queues
nu = length(obj.users);
for k = 1:nu,
	  cmd = ['sudo rm ' obj.users{k}.rq{1}  '/*.mat &>/dev/null'];  system(cmd);
end




case 'stop'      % move running queue files to input queue
% move global running queue .mat files to input queue
mv_rq_to_iq(obj);


case 'resume'    % do not clear queues


end



end



% move files in global running queue to input queue
function mv_rq_to_iq(obj)

% strip worker id from workers
			cmd = ['sudo ' obj.bs{1} '/strip_wid.sh' ' ' obj.gq.rq{1}];
system(cmd);


% move running queue files to input queue
cmd = ['mv ' obj.gq.rq{1} '/*.mat' ' ' obj.gq.iq{1}];
system(cmd);


end






