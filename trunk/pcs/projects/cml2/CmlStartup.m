% CmlStartup
%
% Initializes CML 2 by setting the path
%
% Last updated July 15, 2010

% determine the home directory
cml_home = pwd;

if ispc
    % setup the path
    addpath( strcat( cml_home, '\mat') );
else
    % setup the path
    addpath( strcat( cml_home, '/mat') );
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
