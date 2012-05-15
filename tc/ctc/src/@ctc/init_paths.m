% init_paths.m
%
% read configuration file for task controller
%
% Version 1
% 12/7/2011
% Terry Ferrett


function init_paths(obj)
 

  % input path
  heading = '[paths]';
  key = 'input_queue';
  out = util.fp(obj.cfp, heading, key);
  obj.gq.iq = out{1};

  
  % output path
  heading = '[paths]';
  key = 'output_queue';
  out = util.fp(obj.cfp, heading, key);
  obj.gq.oq = out{1};

  
  % running path
  heading = '[paths]';
  key = 'run_queue';
  out = util.fp(obj.cfp, heading, key);
  obj.gq.rq = out{1};


  
  % log path
  heading = '[paths]';
  key = 'log';
  out = util.fp(obj.cfp, heading, key);
  obj.gq.log = out{1};


  % bash scripts
  heading = '[paths]';
  key = 'bash_scripts';
  out = util.fp(obj.cfp, heading, key);
  obj.bs = out{1};


end










