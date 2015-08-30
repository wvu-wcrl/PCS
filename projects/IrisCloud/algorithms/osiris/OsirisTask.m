function OutputParam =OsirisTask(InputParam,IrisCloudCodeRoot)


% Set desired debugging mode
%   DEBUG='true'   debugging on, temporary directories left in
%   place
%
%   DEBUG='false'   no debugging, temporary directories deleted
DEBUG='true';


   OutPutParam=[];
   % Assigning the Image Paths to a local variable
  ImageOnePath=InputParam.ImageOnePath;
  ImageTwoPath=InputParam.ImageTwoPath;
  
  % Get the Image Names from the ImagePaths. The Image Names are important
  % for creating the Image List.
  [Path ImageOneName ext]=fileparts(ImageOnePath);
  [Path ImageTwoName ext]=fileparts(ImageTwoPath);
  temp='IrisCodes';
  
  % Creating the Algorithm Path by using the Algorithm Name and The
  % IrisCloud Code Root
  AlgorithmName=InputParam.AlgorithmParams.AlgorithmName;
  AlgorithmPath=fullfile(IrisCloudCodeRoot,'algorithms',AlgorithmName);


  % create pcs temporary directory - move this somewhere else later
  mkdir('/tmp', 'pcs');
  % temporary directory --tmpdir hard coded for now, later generalize
  [status TempDir]=system('mktemp -d --tmpdir=/tmp/pcs');
  % Remove trailing carriage return from Linux command return
  % string.
  TempDir = TempDir(1 : end-1);



  % Creating the Temperory Directory
  %  TaskFileName=TaskParam.TaskFileName;
  %TempDir= fullfile('/tmp/',TaskFileName);
  status=mkdir(TempDir,temp);




 
  % Check if the temporary directory got created
   if (~status)
           return;
   else
            
            formatSpecImage='%s \n';
            
            % Creating the files MatchingResult, ImageList and the
            % configuration file mandatory for Osiris
            MatchingResult=fullfile(TempDir,'MatchingResult.txt');
            ImageList= fullfile(TempDir,'ImageList.txt');
            ConfigurationFile=fullfile(TempDir,'configuration.ini');
            file=fopen(MatchingResult,'w');
            fclose(file);
            
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
             fprintf(file2,formatSpecConfig,'Process segmentation',A2,'Process normalization',A2,'Process encoding',A2,'Process matching',A2,'Use the mask provided by osiris',A2);
            fprintf(file2,formatSpecConfig,'List of images',ImageList,'Load original images',ImageOnePath);
            fprintf(file2,formatSpecConfig,'Save segmented images',IrisCodes,'Save contours parameters',IrisCodes,'Save masks of iris',IrisCodes,'Save normalized images',IrisCodes,'Save normalized masks',IrisCodes,'Save iris codes',IrisCodes);
           fprintf(file2,formatSpecConfig,'Save matching scores',MatchingResult);
            fclose(file2);
            
            % Calling the Matching function to run Osiris
            [success]=Matching(ConfigurationFile,AlgorithmPath);
             if (success)
                try
                    
                    %oldfolder = cd (ParentFolder);
                    formatSpec='%s'; 
                    
                    
                    % Reading the matching score from the
                    % MatchingResult.txt to create the Output Param
                    fileID = fopen(MatchingResult,'r');
                   
                    C = textscan(fileID,formatSpec);
                    fclose(fileID);
                    score=C{1}{3};
                   
                  

                    % If we are debugging, leave the temporary
                    % directory in place, otherwise delete it.
                    if( strcmp(DEBUG,'true') )
                        % Don't delete temporary directory
                    elseif( strcmp(DEBUG,'false') )
                        % Deletect temporary directory
                       [status stdout] = rmdir(TempDir,'s');
                       fprintf(stdout);
                    end

                   % cd (oldfolder);
                    msg = sprintf( 'Create Output Param\n' );
                    fprintf( msg );
                    
                    % create output structure
                    
                    %OutputParam.AlgorithmName=InputParam.AlgorithmParams.AlgorithmName;
                    OutputParam.MatchingScore=score;
                    
                catch
                    msg = sprintf( 'Error: Output Param could not be created\n' );
                    fprintf( msg );
                end
            end
   end
end

  
  