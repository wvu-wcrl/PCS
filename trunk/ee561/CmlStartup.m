% CmlStartup
%
% Initializes CML 2 by setting the path
%
% Last updated February 27, 2011 by Terry
% Latest change:
% Added worker controller and utility code directories to the path.


% determine the home directory
cml_home = pwd;

% set the path
if ispc
    addpath( strcat( cml_home, '\mat' ) );
    addpath( strcat( cml_home, '\util' ) );
    addpath( strcat( cml_home, '\srv' ) );
else
    addpath( strcat( cml_home, '/mat' ) );
    addpath( strcat( cml_home, '/util' ) );
    addpath( strcat( cml_home, '/srv' ) );
end


% Load the cluster worker controller state, if it exists.
cwcRelativePath = strcat('srv',...
    '/', 'state');
cwcFullPath = strcat(cml_home,...
    '/', cwcRelativePath);
try
    fprintf('Attempting to load cluster controller state from file\n %s\n\n', cwcRelativePath);
    cd(cwcFullPath)
    load('cwc_state.mat');
    cd(cml_home);
fprintf('State loaded.\n')
catch
    fprintf('State file does not exist.  Aborting load.\n');
end


% this is the location of the mex directory for this architecture
switch computer
    case 'PCWIN'  % MS Windows on x86
        addpath( strcat( cml_home, '\mex\pcwin') );
    case 'GLNX86' % Linux on x86
        addpath( strcat( cml_home, '/mex/glnx86') );
    case 'MACI'   % Apple Mac OS X on x86
        addpath( strcat( cml_home, '/mex/maci') );
    case 'PCWIN64' % Microsoft Windows on x64
        addpath( strcat( cml_home, '\mex\pcwin64') );
    case 'GLNXA64'  % Linux on x86_64
        addpath( strcat( cml_home, '/mex/glnxa64') );
    case 'SOL64'    % Sun Solaris on SPARC
        addpath( strcat( cml_home, '/mex/sol64') );
    case 'MACI64'   % Apple Mac OS X on x86_64
        addpath( strcat( cml_home, '/mex/maci64') );
end
