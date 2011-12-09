% readcfg.m
%
% read configuration file for task controller
%
% Version 1
% 12/7/2011
% Terry Ferrett


function readcfg(obj)


  % read worker list and workers per node
  heading = '[workers]';
  key = 'worker';
  out = util.fp(obj.cfp, heading, key);
  obj.wrklist = out;



  % read queue path
  heading = '[paths]';
  key = 'queuedir';
  out = util.fp(obj.cfp, heading, key);
  obj.qp = out{1};


end










