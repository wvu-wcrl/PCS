function [success] = Matching (ConfigurationFile,AlgorithmPath)
% Matching function to take the input as Configuration file and the
% algorithm path of osiris and execute it


formatSpecImage='%s \n';
%  file4=fopen('check.txt','w');
%  fprintf(file4,formatSpecImage,'2');

% getting the path of the configuration file to create a check file for
% debugging
 [pathstr,name,ext] = fileparts(ConfigurationFile);
%  fprintf(file4,formatSpecImage,'3');

formatSpec = '%s %s %s';
%formatSpec1 = '%s %s';
%  fprintf(file4,formatSpecImage,'4');
%  fclose(file4);

% tilda='~';
% 
% strCurr= fullfile(tilda,pathstr);



% oldfolder=cd(pathstr);

%Create and open the checkfile
Check=fullfile(pathstr,'check.txt');
file5=fopen(Check,'w');
%  fprintf(file5,formatSpecImage,pathstr);

A1= 'LD_LIBRARY_PATH= && ';

 %fprintf(file5,formatSpecImage,A1);
%A2=strcat ('./',name);
A2=fullfile(AlgorithmPath,'osiris');
 %fprintf(file5,formatSpecImage,A2);

% A3=fullfile(ParentFolder,configfile);
A3=Configurationfile;
 %fprintf(file5,formatSpecImage,A3);

%A3='/home/vtalreja/Iris_Osiris_v4.1/scripts/TestingSegment/configurationtry.ini';

%A4='/home/vtalreja/Iris_Osiris_v4.1/scripts/TestingMatching/configurationmatch.ini';





%str3=sprintf(formatSpec1,A2,A3);

% Create the string for usage in the system command
str2 = sprintf(formatSpec,A1,A2,A3);
 %fprintf(file5,formatSpecImage,str2);



try


% Writing into the check file for debugging puposes
 msg = sprintf( 'PreProcessing Images- Segmentation, Normalization, and Encoding \n' );
            fprintf( msg );
  fprintf(file5,formatSpecImage,msg);

  % calling the system command
[status cmdout]=system(str2)

% [status cmdout]=system(str3)

 fprintf(file5,formatSpecImage,cmdout);
 fclose(file5)

% msg = sprintf( 'Matching the Images \n' );
%             fprintf( msg );

% [status cmdout]=system(str3)


Score = 0;

%cd(oldfolder);

if (status==0)
file6=fopen(Check,'w');
fprintf(file6,formatSpecImage,'status');
 success = 1;
else
 success=0;
end



catch

Score = 1;
success = 0;

end
end

