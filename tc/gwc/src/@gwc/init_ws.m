% init_ws.m
%
% initialize worker state structure
%
% Version 1
% 12/7/2011
% Terry Ferrett


function init_ws(obj)



% init job counter

obj.jc = 0;
obj.rtn = 'compiled_fsk';

% read logging parameters
    heading = '[logging]';
key = 'log_period';
out = util.fp(obj.cf, heading, key);
obj.log_period = out{1}{1}


key = 'num_logs';
out = util.fp(obj.cf, heading, key);
obj.num_logs = out{1}{1};


key = 'verbose_mode';
out = util.fp(obj.cf, heading, key);
obj.verbose_mode = out{1}{1};



end










