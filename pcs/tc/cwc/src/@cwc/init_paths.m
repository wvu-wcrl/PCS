% init_paths.m
%
% read configuration file for task controller
%
% Version 1
% 12/7/2011
% Terry Ferrett
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.



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


  
  % worker logging directory path
  heading = '[paths]';
  key = 'log';
  out = util.fp(obj.cf, heading, key);
  obj.lp = out{1};
    
  
  % logging function path
  heading = '[paths]';
  key = 'log_function';
  out = util.fp(obj.cf, heading, key);
  obj.lfup = out{1};
  addpath(obj.lfup{1}); 
  
   % cwc logfile path
  heading = '[paths]';
  key = 'cwc_logfile';
  out = util.fp(obj.cf, heading, key);
  obj.cwc_logfile = out{1};


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




%     This library is free software;
%     you can redistribute it and/or modify it under the terms of
%     the GNU Lesser General Public License as published by the
%     Free Software Foundation; either version 2.1 of the License,
%     or (at your option) any later version.
%
%     This library is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%     Lesser General Public License for more details.
%
%     You should have received a copy of the GNU Lesser General Public
%     License along with this library; if not, write to the Free Software
%     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA





