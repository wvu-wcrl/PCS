function OutputParam = IrisCloud(InputParam,TaskParam)
% function to assign the task of calling the Osiris or custom Algorithm.InputParam is a structure array 
% This function takes the input as the Input images path along with the
% Algorithm Parameters and the USer Type and gives out the
% matching score for that particular algorithm.
IrisCloudCodeRoot='/rhome/pcs/jm/IrisCloud/CodeRoot';
OutputParam=[];
% Check for the User Type  1. EndUser 2. Developer
if isfield(InputParam,'UserType')
    UserType=InputParam.UserType;
    
    if(UserType=='EndUser')
           
         % Error check to make sure Image Paths have been passed in the
         % Input Param
        if  isfield( InputParam, 'ImageOnePath' )
            ImageOnePath= InputParam.ImageOnePath;
            
            
            if  isfield( InputParam, 'ImageTwoPath' )
                ImageTwoPath= InputParam.ImageTwoPath;
                
            else
                msg = sprintf( 'Sorry. Image 2 not found\n' );
                fprintf( msg );
                return;
            end
        else
            msg = sprintf( 'Sorry. Image 1 not found\n' );
            fprintf( msg );
            
            return;
            
        end
       
           % Error Check to make sure Algorithm Parameters are passed in
           % the Input Param
           if isfield(InputParam, 'AlgorithmParams')
               if isfield(InputParam.AlgorithmParams, 'AlgorithmName')
                   AlgorithmName=InputParam.AlgorithmParams.AlgorithmName;
               else
                   msg = sprintf( 'Sorry. No Algorithm Name.Cannot run without the Algorithm name\n' );
                   fprintf( msg );
                   return;
               end
               if isfield(InputParam.AlgorithmParams,'AlgorithmType')
                   AlgorithmType=InputParam.AlgorithmParams.AlgorithmType;
               else
                   msg = sprintf( 'Sorry. No Algorithmtype for the given Algorithm.Cannot run without the AlgorithType \n' );
                   fprintf( msg );
                   return;
               end
              
           else
               msg = sprintf( 'Sorry. No Algorithm Paramaters found.Cannot run without the Algorithm Structure \n' );
               fprintf( msg );
               return;
           end
           
           % Switching on the Algorithm Type : 1. osiris 2. HOG.....
           switch(InputParam.AlgorithmParams.AlgorithmType)
               case('osiris')
                   OutputParam=OsirisTask(InputParam,TaskParam,IrisCloudCodeRoot);
               case('HOG')
                   OutputParam=HOGTask(InputParam);
               otherwise
                msg = sprintf( 'Sorry. TaskType Not Known. Contact the Administrator \n' );
               fprintf( msg );
               return;
           end
            else
        
        
        
        
        
        
        
        
    end
else
     msg = sprintf( 'Sorry. UserType is not defined\n' );
                fprintf( msg );
                return;
end
end
           
           
        
        
%         [token,remain]=strtok(fliplr(ImageOnePath),filesep);
%         ParentFolder=fliplr(remain);
%         oldFolder=cd(ParentFolder);
%         temp='IrisCodes'
%         status=mkdir(ParentFolder,temp);
%        % status=MakeFolders(ParentFolder);
%        if (~status)
%            return;
%         else
%             formatSpecImage='%s \n';
%           %  oldFolder=cd(ParentFolder);
%             file=fopen('MatchingResult.txt','w');
%             fclose(file);
%             file1=fopen('ImageList.txt','w');
%             fprintf(file1,formatSpecImage,ImageOneName,ImageTwoName);
%             fclose(file1);
% %             oldFolder=cd(ParentFolder);
% %             file1=fopen('ImageList.txt','w');
% %             formatSpecImage='%s \n';
% %             fprintf(file1,formatSpecImage,ImageOneName,ImageTwoName);
% %             fclose(file1);
%             A2='yes';
%             ImageDir=fullfile(ParentFolder,'ImageList.txt');
%             %SegmentedImages=fullfile(ParentFolder,'SegmentedImages/');
%             %CircleParameters=fullfile(ParentFolder,'CircleParameters/');
%             %Masks=fullfile(ParentFolder,'Masks/');
%             %NormalizedImages=fullfile(ParentFolder,'NormalizedImages/');
%             %NormalizedMasks=fullfile(ParentFolder,'NormalizedMasks/');
%             IrisTemp=strcat(temp,'/');
%             IrisCodes=fullfile(ParentFolder,IrisTemp);
%             ResultDir=fullfile(ParentFolder,'MatchingResult.txt');
%             formatSpecConfig='%s = %s \n';
%             
%             file2=fopen('configuration.ini','w');
%             
%             fprintf(file2,formatSpecConfig,'Process segmentation',A2,'Process normalization',A2,'Process encoding',A2,'Process matching',A2,'Use the mask provided by osiris',A2);
%             fprintf(file2,formatSpecConfig,'List of images',ImageDir,'Load original images',ImageOnePath);
%            % fprintf(file2,formatSpecConfig,'Save segmented images',SegmentedImages,'Save contours parameters',CircleParameters,'Save masks of iris',Masks,'Save normalized images',NormalizedImages,'Save normalized masks',NormalizedMasks,'Save iris codes',IrisCodes);
%              fprintf(file2,formatSpecConfig,'Save segmented images',IrisCodes,'Save contours parameters',IrisCodes,'Save masks of iris',IrisCodes,'Save normalized images',IrisCodes,'Save normalized masks',IrisCodes,'Save iris codes',IrisCodes);
%            fprintf(file2,formatSpecConfig,'Save matching scores',ResultDir);
%             fclose(file2);
%             configfile='configuration.ini';
%             
%             
%             cd(oldFolder);
%             
%              file3=fopen('check.txt','w');
%              fprintf(file3,formatSpecImage,'1');
%              fclose(file3);
%             [success]=Matching(ParentFolder,configfile,FileName);
%             
%             if (success)
%                 try
%                     
%                     oldfolder = cd (ParentFolder);
%                     formatSpec='%s';
%                     fileID = fopen('MatchingResult.txt','r');
%                     %formatSpec='%s';
%                     C = textscan(fileID,formatSpec)
%                     fclose(fileID);
%                     score=C{1}{3};
%                    
%                   
% 
%                     
%                      rmdir(temp,'s');
%                     
%                     cd (oldfolder);
%                     msg = sprintf( 'Create Output Param\n' );
%                     fprintf( msg );
%                     
%                     % create output structure
%                     OutputParam.DeveloperName=InputParam.AlgorithmStructure.DeveloperName;
%                     OutputParam.AlgorithmName=InputParam.AlgorithmStructure.AlgorithmName;
%                     OutputParam.MatchingScore=score;
%                     
%                 catch
%                     msg = sprintf( 'Error: Output Param could not be created\n' );
%                     fprintf( msg );
%                 end
%             end
%         end
   


    
    
    

