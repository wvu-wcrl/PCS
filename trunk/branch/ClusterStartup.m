% ClusterStartup
%
% Initializes EE561 project (cluster code) by setting the path
%
% Last updated February 27, 2011 by Terry
%
% Latest changes:
%    Added worker controller and utility code directories to the path.
%    On April 20, 2011 MCV changed the name of the file from CmlStartup to ClusterStartup

% determine the home directory
root = pwd;

% set the path
if ispc
    addpath( strcat( root, '\util' ) );
    addpath( strcat( root, '\srv' ) );
else
    addpath( strcat( root, '/util' ) );
    addpath( strcat( root, '/srv' ) );
end


% Load the cluster worker controller state, if it exists.
%cwcRelativePath = strcat('srv',...
%    '/', 'state');
%cwcFullPath = strcat(cml_home,...
%    '/', cwcRelativePath);
%try
%    fprintf('Attempting to load cluster controller state from file\n %s\n\n', cwcRelativePath);
%    cd(cwcFullPath)
%    load('cwc_state.mat');
%    cd(cml_home);
%fprintf('State loaded.\n')
%catch
%    fprintf('State file does not exist.  Aborting load.\n');
%    cd(cml_home);
%end

% can add paths to c-mex, if necessary
