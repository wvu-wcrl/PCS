% CmlStartup
%
% Initializes the Coded Modulation Library
%
% Last updated June 9, 2010

% determine the version of matlab version
version_text = version;
if ( str2num( version_text(1) ) > 6)
    save_flag = '-v6';
else
    save_flag = '-mat';
end

% determine the home directory
cml_home = pwd;

% this is the location of the mex directory for this architecture
switch computer
    case 'PCWIN'  % MS Windows on x86
        addpath( strcat( cml_home, '\mex\mexpcwin');
    case 'GLNX86' % Linux on x86
        addpath( strcat( cml_home, '/mex/mexglnx86');
    case 'MACI'   % Apple Mac OS X on x86         
        addpath( strcat( cml_home, '/mex/mexmaci');
    case 'PCWIN64' % Microsoft Windows on x64      
        addpath( strcat( cml_home, '\mex/mexpcwin64');
    case 'GLNXA64'  % Linux on x86_64      
        addpath( strcat( cml_home, '/mex/mexglnxa64');
    case 'SOL64'    % Sun Solaris on SPARC          
        addpath( strcat( cml_home, '/mex/mexsol64');
    case 'MACI64'   % Apple Mac OS X on x86_64   
        addpath( strcat( cml_home, '/mex/mexmaci64');
end

if ispc
    % setup the path
    addpath( strcat( cml_home, '\mat'), ...
        strcat( cml_home, '\matalt' ), ...
        strcat( cml_home, '\mexhelp'), ...
        strcat( cml_home, '\demos' ), ...
        strcat( cml_home, '\scenarios'), ...
        strcat( cml_home, '\localscenarios'),...
        strcat( cml_home, '\data\interleavers'), ...
        strcat( cml_home, '\data\ldpc'), ...
        strcat( cml_home, '\data\tables'), ...
        strcat( cml_home, '\data\bandwidth') );

    % if CML grid is installed
    if exist( '.\grid\mat' )
        addpath( strcat( cml_home, '\grid\mat' ) );
    end

    % save the home directory
    save_directory = strcat( cml_home, '\scenarios\CmlHome.mat' );
else
    % setup the path
    addpath( strcat( cml_home, '/mat'), ...
        strcat( cml_home, '/matalt' ), ...
        strcat( cml_home, '/mexhelp'), ...
        strcat( cml_home, '/demos' ), ...
        strcat( cml_home, '/scenarios'), ...
        strcat( cml_home, '/localscenarios'),...
        strcat( cml_home, '/data/interleavers'), ...
        strcat( cml_home, '/data/ldpc'), ...
        strcat( cml_home, '/data/tables'), ...
        strcat( cml_home, '/data/bandwidth') );

    % if CML grid is installed
    if exist( './grid/mat' )
        addpath( strcat( cml_home, '/grid/mat' ) );
    end

    % save the home directory
    save_directory = strcat( cml_home, '/scenarios/CmlHome.mat' );
end

save( save_directory, save_flag, 'cml_home' );