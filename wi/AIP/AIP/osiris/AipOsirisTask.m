%function OutputParam = AipOsirisTask(InputParam,IrisCloudCodeRoot)
function OutputParam = AipOsirisTask(AIP);

% Set desired debugging mode
%   DEBUG='true'   debugging on, temporary directories left in
%   place
%
%   DEBUG='false'   no debugging, temporary directories deleted
% DEBUG='false';

% Assigning the Database Names to a local variable.
tic
g=load('AIP.mat');
ImageOnePath=g.JobParam.DBOneName;
%ImageOnePath=DBOne;
%ImageTwoPath=InputParam.DBTwoName;
ClassValue=g.JobParam.Class;
if(strcmp(ClassValue,'Inter-Class'))
    ImageTwoPath=g.JobParam.DBTwoName;
    
end

IrisCloudCodeRoot='/home/vtalreja/AIP/AIPData';


ImageOnePath=fullfile(IrisCloudCodeRoot,ImageOnePath);
if(strcmp(ClassValue,'Inter-Class'))
    ImageTwoPath=fullfile(IrisCloudCodeRoot,ImageTwoPath);
end


mkdir('temp');
mkdir(fullfile(pwd,'temp','Images'));
Images=fullfile(pwd,'temp','Images/');
ImageList= fullfile(pwd,'temp','ImageListPre.txt');
ImageList1= fullfile(pwd,'temp','ImageListMatch.txt');
formatSpecImage='%s \n';

switch ClassValue
    case('Inter-Class')

old=cd(ImageOnePath);


Files=dir('*.*');

cd(ImageTwoPath);
Files1=dir('*.*');

cd(ImageOnePath);

for k=1:length(Files)
    if(~Files(k).isdir)
   FileName= Files(k).name;
   copyfile(FileName,Images);
   cd(ImageTwoPath);
   FileName1=Files1(k).name;
   copyfile(FileName1,Images);
   cd(ImageOnePath);
 new=cd(old);
 
file1=fopen(ImageList,'a');
fprintf(file1,formatSpecImage,FileName);
fprintf(file1,formatSpecImage,FileName1);

fclose(file1);
file2=fopen(ImageList1,'a');
fprintf(file2,formatSpecImage,FileName);
fprintf(file2,formatSpecImage,FileName1);

fclose(file2);
cd(new);
    end
end

cd(old);


 case('Intra-Class')

old=cd(ImageOnePath);


Files=dir('*.*');

% cd(ImageTwoPath);
% Files1=dir('*.*');
% 
% cd(ImageOnePath);

for k=1:length(Files)
    if(~Files(k).isdir)
   FileName= Files(k).name;
   copyfile(FileName,Images);
%    cd(ImageTwoPath);
%    FileName1=Files1(k).name;
%    copyfile(FileName1,Images);
%    cd(ImageOnePath);
 new=cd(old);
 
file1=fopen(ImageList,'a');
fprintf(file1,formatSpecImage,FileName);
% fprintf(file1,formatSpecImage,FileName1);

fclose(file1);
% file2=fopen(ImageList1,'a');
% fprintf(file2,formatSpecImage,FileName);
% fprintf(file2,formatSpecImage,FileName1);
% 
% fclose(file2);
if (k~=3)
 file2=fopen(ImageList1,'a');
 fprintf(file2,formatSpecImage,Files(3).name,FileName);
 fclose(file2);
 end
cd(new);
    end
end

cd(old);

    otherwise
end



% if (k~=3)
% file2=fopen(ImageList1,'a');
% fprintf(file1,formatSpecImage,Files(3).name,FileName);
% fclose(file1);
% end
% cd(new);
%     end
% end
% 
% cd(old);






temp='IrisCodes';
% Path = [Path '/'];
% ImageOnePath=[ImageOnePath '/'];


% Construct algorithm path.
% AlgorithmName=InputParam.AlgorithmParams.AlgorithmName;
AlgorithmPath=fullfile(pwd);


% temporary directory --tmpdir hard coded for now, later generalize
% [status TempDir]=system('mktemp -d --tmpdir=/tmp/pcs');
% % Remove trailing carriage return from Linux command return
% % string.
% TempDir = TempDir(1 : end-1);
% 
% % Create task temporary directory
% status=mkdir(TempDir,temp);
% if (~status)
%     fprintf('Error creating temporary directory.')
%     return;
% end



formatSpecImage='%s \n';

% Creating the files MatchingResult, ImageList and the
% configuration file required for Osiris
MatchingResult= fullfile(pwd,'temp','MatchingResult.txt');
% MatchingResult=fullfile(TempDir,'MatchingResult.txt');
% ImageList= fullfile(TempDir,'ImageList.txt');
ConfigurationFilePre=fullfile(pwd,'temp','ConfigurationPre.ini');
ConfigurationFileMatch=fullfile(pwd,'temp','ConfigurationMatch.ini');
file=fopen(MatchingResult,'w');
fclose(file);

% ImageOneName=[ImageOneName ext];
% ImageTwoName=[ImageTwoName ext];

% Saving the ImageNames in the ImageList
% file1=fopen(ImageList,'w');
% fprintf(file1,formatSpecImage,ImageOneName,ImageTwoName);
% fclose(file1);
A2='yes';
A3='no';
IrisTemp=strcat(temp,'/');
IrisCodes=fullfile(pwd,'temp/');
% IrisCodes=fullfile(TempDir,IrisTemp);
formatSpecConfig='%s = %s \n';

% Writing data into configuration file
file2=fopen(ConfigurationFilePre,'w');
fprintf(file2,formatSpecConfig,'Process segmentation',A2,...
    'Process normalization',A2,...
'Process encoding',A2,...
'Process matching',A3,...
'Use the mask provided by osiris',A3);
fprintf(file2,formatSpecConfig,'List of images',...
    ImageList,'Load original images',Images);
fprintf(file2,formatSpecConfig,'Save segmented images',IrisCodes,...
    'Save contours parameters',IrisCodes,...
    'Save masks of iris',IrisCodes,...
    'Save normalized images',IrisCodes,...
    'Save normalized masks',IrisCodes,...
    'Save iris codes',IrisCodes);
fclose(file2);
file3=fopen(ConfigurationFileMatch,'w');
fprintf(file3,formatSpecConfig,'Process segmentation',A3,...
    'Process normalization',A3,...
'Process encoding',A3,...
'Process matching',A2,...
'Use the mask provided by osiris',A3);
fprintf(file3,formatSpecConfig,'List of images',...
    ImageList1,'Load original images',Images);
fprintf(file3,formatSpecConfig,'Load normalized masks',IrisCodes,...
    'Load iris codes',IrisCodes);




fprintf(file3,formatSpecConfig,'Save matching scores',MatchingResult);
fclose(file3);

% Calling the matching function which executes osiris
[success]=AIPMatching(ConfigurationFilePre,AlgorithmPath,ConfigurationFileMatch);

fprintf('Printing matching result %f', success)



% if osiris completes successfully, read the matching score.
if (success)
    try               
        formatSpec='%s';
                
        % Reading the matching score from MatchingResult.txt 
        fileID = fopen(MatchingResult,'r');        
        C = textscan(fileID,formatSpec);
        fclose(fileID);
%         score=[1:11];
if(strcmp(ClassValue,'Intra-Class'))
        for i=3:3:33
        score(i/3)=str2num(C{1}{i}); 
        
        end 

else
    for i=3:3:36
        score(i/3)=str2num(C{1}{i}); 
        
    end 
    end
    
        histogram(score,10);
%         for k=1:length(Files)
        
        
   
        % delete temporary directory
%         DelTemp(DEBUG, TempDir);     
        
        OutputParam.MatchingScore=score;
        
    catch
        msg = sprintf( 'Error: OutputParam could not be created.\n' );
        fprintf( msg );

        msg = sprintf('File ID: %f', fileID);
        fprintf( msg );

%         DelTemp(DEBUG, TempDir);     

    end
    
    
else
    fprintf('Matching not successful.\n');
%     DelTemp(DEBUG, TempDir);     
    
end
toc
end




% Delete temporary directory
function DelTemp(DEBUG, TempDir)
        % If we are debugging, leave the temporary
        % directory in place, otherwise delete it.
        if( strcmp(DEBUG,'true') )
            % Don't delete temporary directory
        elseif( strcmp(DEBUG,'false') )
            % Delete temporary directory
            [status stdout] = rmdir(TempDir,'s');
            fprintf(stdout); fprintf('\n');
        end
end

