% init_paths.m
%
% read configuration file for task controller
%
% Version 2
% 5/2014
% Terry Ferrett
%
%     Copyright (C) 2014, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.


function init_paths(obj)

% global queue name
heading = '[paths]';
key = 'queue_name';
out = util.fp(obj.cfp, heading, key);
obj.gq_name = out{1}{1};

% input queue path
heading = '[paths]';
key = 'input_queue';
out = util.fp(obj.cfp, heading, key);
obj.gq.iq = out{1};

% output queue path
heading = '[paths]';
key = 'output_queue';
out = util.fp(obj.cfp, heading, key);
obj.gq.oq = out{1};

% running queue path
heading = '[paths]';
key = 'run_queue';
out = util.fp(obj.cfp, heading, key);
obj.gq.rq = out{1};

% log path
heading = '[paths]';
key = 'log';
out = util.fp(obj.cfp, heading, key);
obj.gq.log = out{1};

% logging function path
heading = '[paths]';
key = 'log_function';
out = util.fp(obj.cfp, heading, key);
obj.lfup = out{1};

% adding logging function directory to MATLAB path
addpath(obj.lfup{1});

% ctc logfile path
heading = '[paths]';
key = 'ctc_logfile';
out = util.fp(obj.cfp, heading, key);
obj.ctc_logfile = out{1};

% bash script path
heading = '[paths]';
key = 'bash_scripts';
out = util.fp(obj.cfp, heading, key);
obj.bs = out{1};

% path to previously executing user file
heading = '[paths]';
key = 'peu';
out = util.fp(obj.cfp, heading, key);
obj.peu = out{1};

% path to currently executing user file
heading = '[paths]';
key = 'ceu';
out = util.fp(obj.cfp, heading, key);
obj.peu = out{1};


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