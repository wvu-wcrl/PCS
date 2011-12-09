% init.m
%
% initialization routine for ctc
%
% Version 1
% 12/7/2011
% Terry Ferrett


function init(obj)

% read configuration file
readcfg(obj);

% init controller configuration structure
init_cfg(obj);

% init task state structures
init_ws(obj);

% init users structure
init_users(obj) 

end










