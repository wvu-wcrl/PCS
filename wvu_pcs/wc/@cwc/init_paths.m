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
  out = util.fp(obj.cf, heading, key);
  obj.gq.iq = out{1};

  
  % output path
  heading = '[paths]';
  key = 'output_queue';
  out = util.fp(obj.cf, heading, key);
  obj.gq.oq = out{1};

  
  % running path
  heading = '[paths]';
  key = 'run_queue';
  out = util.fp(obj.cf, heading, key);
  obj.gq.rq = out{1};
  
  
  % bash script path
  heading = '[paths]';
  key = 'bash_scripts';
  out = util.fp(obj.cf, heading, key);
  obj.bs = out{1};


  % worker script path
  heading = '[workerscript]';
  key = 'path';
  out = util.fp(obj.cf, heading, key);
  obj.gwp = out{1};


  % worker script
  heading = '[workerscript]';
  key = 'script';
  out = util.fp(obj.cf, heading, key);
  obj.gwn = out{1};
  
  

end










