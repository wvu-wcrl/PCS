% CmlStartup
%
% Initializes CML 2 by setting the path
%
% Last updated July 15, 2010

% determine the home directory
cml_home = pwd;

% setup the path.
addpath( fullfile( cml_home, 'mat') );

% this is the location of the mex directory for this architecture.
addpath( fullfile( cml_home, 'mex', lower(computer)) );