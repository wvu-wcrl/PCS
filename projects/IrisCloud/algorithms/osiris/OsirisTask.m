% OsirisTask.m
%  Function to launch Osiris


function OutputParam = OsirisTask(InputParam,IrisCloudCodeRoot)

% Set desired debugging mode
%   DEBUG='true'   debugging on, temporary directories left in
%   place
%
%   DEBUG='false'   no debugging, temporary directories deleted
DEBUG='false';

% Assigning the Image Paths to a local variable.
ImageOnePath=InputParam.ImageOnePath;
ImageTwoPath=InputParam.ImageTwoPath;

% Get the Image Names from the ImagePaths for creating the image list.
[Path ImageOneName ext]=fileparts(ImageOnePath);
[Path ImageTwoName ext]=fileparts(ImageTwoPath);
temp='IrisCodes';
Path = [Path '/'];


% Construct algorithm path.
AlgorithmName=InputParam.AlgorithmParams.AlgorithmName;
AlgorithmPath=fullfile(IrisCloudCodeRoot,'algorithms',AlgorithmName);


% Create pcs temporary directory - move this somewhere else later
mkdir('/tmp', 'pcs');
% temporary directory --tmpdir hard coded for now, later generalize
[status TempDir]=system('mktemp -d --tmpdir=/tmp/pcs');
% Remove trailing carriage return from Linux command return
% string.
TempDir = TempDir(1 : end-1);

% Create task temporary directory
status=mkdir(TempDir,temp);
if (~status)
    fprintf('Error creating temporary directory.')
    return;
end



formatSpecImage='%s \n';

% Creating the files MatchingResult, ImageList and the
% configuration file required for Osiris
MatchingResult=fullfile(TempDir,'MatchingResult.txt');
ImageList= fullfile(TempDir,'ImageList.txt');
ConfigurationFile=fullfile(TempDir,'configuration.ini');
file=fopen(MatchingResult,'w');
fclose(file);

ImageOneName=[ImageOneName '.tiff'];
ImageTwoName=[ImageTwoName '.tiff'];

% Saving the ImageNames in the ImageList
file1=fopen(ImageList,'w');
fprintf(file1,formatSpecImage,ImageOneName,ImageTwoName);
fclose(file1);
A2='yes';
IrisTemp=strcat(temp,'/');
IrisCodes=fullfile(TempDir,IrisTemp);
formatSpecConfig='%s = %s \n';

% Writing data into configuration file
file2=fopen(ConfigurationFile,'w');
fprintf(file2,formatSpecConfig,'Process segmentation',A2,...
    'Process normalization',A2,...
'Process encoding',A2,...
'Process matching',A2,...
'Use the mask provided by osiris',A2);
fprintf(file2,formatSpecConfig,'List of images',...
    ImageList,'Load original images',Path);
fprintf(file2,formatSpecConfig,'Save segmented images',IrisCodes,...
    'Save contours parameters',IrisCodes,...
    'Save masks of iris',IrisCodes,...
    'Save normalized images',IrisCodes,...
    'Save normalized masks',IrisCodes,...
    'Save iris codes',IrisCodes);

fprintf(file2,formatSpecConfig,'Save matching scores',MatchingResult);
fclose(file2);

% Calling the matching function which executes osiris
[success]=Matching(ConfigurationFile,AlgorithmPath);

fprintf('Printing matching result %f', success)



% if osiris completes successfully, read the matching score.
if (success)
    try               
        formatSpec='%s';
                
        % Reading the matching score from MatchingResult.txt 
        fileID = fopen(MatchingResult,'r');        
        C = textscan(fileID,formatSpec);
        fclose(fileID);
        score=C{1}{3};        
        
        
        % If we are debugging, leave the temporary
        % directory in place, otherwise delete it.
        if( strcmp(DEBUG,'true') )
            % Don't delete temporary directory
        elseif( strcmp(DEBUG,'false') )
            % Delete temporary directory
            [status stdout] = rmdir(TempDir,'s');
            fprintf(stdout);
        end
        
        OutputParam.MatchingScore=score;
        
    catch
        msg = sprintf( 'Error: OutputParam could not be created\n' );
        fprintf( msg );
    end
    
    
else
    fprintf('Matching not successful.\n');
    
end

end



