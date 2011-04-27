% LocalStartup
%
% Initializes EE561 project by setting the path
%
% Last updated April 20, 2011 by Matthew Valenti

% determine the home directory
cml_home = pwd;

% set the path to matlab
if ispc
    addpath( strcat( cml_home, '\mat' ) );
else
    addpath( strcat( cml_home, '/mat' ) );
end

% can add paths to c-mex, if necessary