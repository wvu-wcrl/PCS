% Matching.m
%  Executes specific osiris algorithm using MATLAB system command.

function [success] = Matching (ConfigurationFile,AlgorithmPath)

% Construct string containing osiris execution command.
formatSpec = '%s %s %s';
A1= 'LD_LIBRARY_PATH= && ';
A2=fullfile(AlgorithmPath,'osiris');
A3=ConfigurationFile;

% Create the string for executing osiris using the system() command.
str2 = sprintf(formatSpec,A1,A2,A3);

% Attempt to execute Osiris. 
try
    
    CurD=pwd;
    % Osiris execution requires switching to the directory
    %  containing the Osiris executable.
    cd(AlgorithmPath);
    [status cmdout]=system(str2)
    cd(CurD)
    
    % If execution was not successful
    if (status==0)
        success = 1;
    else
        success=0;
        fprintf(cmdout);
    end
        
catch
    
    fprintf('Failure in function Matching()');
    success = 0
    
end
end

