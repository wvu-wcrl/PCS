% init_paths.m
%
% read paths from configuration file for grid worker
%
% Version 1
% 3/1/2012
% Terry Ferrett



function init_paths(obj)
 




  % root directory of Rapids
  heading = '[paths]';
  key = 'rapids_root';
  out = util.fp(obj.cf, heading, key);
  obj.rp = out{1}{1};

  
  % path to root of rapids templates
  heading = '[paths]';
  key = 'rapids_templates';
  out = util.fp(obj.cf, heading, key);
  obj.tp = out{1}{1};


  
  % path to root of rapids templates
  heading = '[paths]';
  key = 'rapids_executable';
  out = util.fp(obj.cf, heading, key);
  obj.pre = out{1}{1};
  
  
  
  % path to root of rapids templates
  heading = '[paths]';
  key = 'rapids_templates';
  out = util.fp(obj.cf, heading, key);
  obj.tp = out{1}{1};
  
  % path to root of rapids templates
  heading = '[paths]';
  key = 'rapids_temp';
  out = util.fp(obj.cf, heading, key);
  obj.rtp = out{1}{1};
  
  
  
  
  
  
  % input path
  heading = '[paths]';
  key = 'input_queue';
  out = util.fp(obj.cf, heading, key);
  obj.gq.iq = out{1}{1};

  
  % output path
  heading = '[paths]';
  key = 'output_queue';
  out = util.fp(obj.cf, heading, key);
  obj.gq.oq = out{1}{1};

  
  % running path
  heading = '[paths]';
  key = 'run_queue';
  out = util.fp(obj.cf, heading, key);
  obj.gq.rq = out{1}{1};
  
  
  % bash script path
  heading = '[paths]';
  key = 'bash_scripts';
  out = util.fp(obj.cf, heading, key);
  obj.bs = out{1}{1};


  
  % bash script path
  heading = '[paths]';
  key = 'log';
  out = util.fp(obj.cf, heading, key);
  obj.lp = out{1}{1};


  

end










