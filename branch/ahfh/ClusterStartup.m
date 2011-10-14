% ClusterStartup
%
% Initializes EE561 project (cluster code) by setting the path
%
% Last updated February 27, 2011 by Terry
%
% Latest changes:
%    Added worker controller and utility code directories to the path.
%    On April 20, 2011 MCV changed the name of the file from CmlStartup to ClusterStartup

   function [prjroot srvroot] = ClusterStartup(resume)


% determine the home directory
   prjroot = pwd; cd ..; srvroot = pwd; cd(prjroot);



% set the path
if ispc
    addpath( strcat( prjroot, '\mat' ) );
addpath(prjroot, '\state');
addpath( strcat( srvroot, '\srv' ) );
addpath( strcat( srvroot, '\srv','\util' ) );
 else
   addpath(strcat(prjroot, '/state'));
    addpath( strcat( prjroot, '/mat' ) );
addpath( strcat( srvroot, '/srv' ) );
addpath( strcat( srvroot, '/srv','/util' ) );
end



if resume == 1,

try
    fprintf('Attempting to load cluster controller state from file\n %s\n\n', cwcRelativePath);
    load('cwc_state.mat');
fprintf('State loaded.\n')
catch
    fprintf('State file does not exist.  Aborting load.\n');
end



end

