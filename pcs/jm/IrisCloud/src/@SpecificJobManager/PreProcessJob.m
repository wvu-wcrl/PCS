% PreProcessJob.m
%  Transform job parameters and state prior to job execution.
%
% Inputs
%  obj            Specific job manager object.
%  JobParamIn     JobParam structure read from user's input file.
%  JobStateIn     JobState structure read from user's input file.
%  JobInfoIn      Structure containing job execution information.
%  CurrentUser     WCRL cluster username of executing user.
%  JobName      Job name.
%
% Outputs
%  JobParam       Updated job parameters.
%  JobState       Updated job state.
%  JobInfo        Updated job execution information.
%  PPSuccessFlag  Pre-processing success flag (1=success, 0=failure)
%  PPErrorMsg     Pre-processing error message (if any).
%
%     Last updated on 9/7/2015
%
%     Copyright (C) 2015, Terry Ferrett, Veeru Talreja and Matthew C. Valenti.
%     For full copyright information see the bottom of this file.


function [JobParam, JobState, JobInfo, PPSuccessFlag, PPErrorMsg] =...
    PreProcessJob(obj, JobParamIn, JobStateIn, JobInfoIn, CurrentUser, JobName)


% Get path to algorithms.
CodeRoot = CurrentUser.CodeRoot;

% Add algorithm path to job path.
OldPath = obj.SetCodePath(CodeRoot);

% Get user's username from the path to their home directory.
Username = obj.FindUsername(CurrentUser.UserPath);


% Pre-process job based on user type.
%  End user jobs utilize the algorithm selection algorithm to
%   select a matching algorithm.
%
%  Developer jobs are currently unspecified.
switch JobParamIn.UserType
    
    case{'EndUser'}
        
        % Confirm that specified input images exist on the filesystem.
        Im1Exist = exist(JobParamIn.ImageOnePath, 'file');
        if (Im1Exist ~= 2 )
            PPErrorMsg = sprintf( 'Image 1 not found on filesystem.\n' );
            fprintf( ErrorMsg );
            PPSuccessFlag = 0;
            path(OldPath);
            return;
        end
        
        Im2Exist = exist(JobParamIn.ImageTwoPath, 'file');
        if (Im2Exist ~= 2 )
            PPErrorMsg = sprintf( 'Image 2 not found on filesystem.\n' );
            fprintf( ErrorMsg );
            PPSuccessFlag = 0;
            path(OldPath);
            return;
        end
        
        
        %  Decide where to store Dr. Adjeroh's QA code.
        AlgorithmIndex=QA(JobParamIn.ImageOnePath,JobParamIn.ImageTwoPath);
        
        % Look for the algorithm name corresponding to the algorithm index.
        %  Return the algorithm parameters.
        [AlgorithmParams]=LookUpAlgorithm(AlgorithmIndex);
        
        % Create the JobParam structure.
        %JobParam.InputParam.UserType=JobParamIn.UserType;
        %JobParam.InputParam.ImageOnePath=JobParamIn.ImageOnePath;
        %JobParam.InputParam.ImageTwoPath=JobParamIn.ImageTwoPath;
        %JobParam.InputParam.AlgorithmParams= AlgorithmParams;
        
        % Assign parameters to JobParam.
        JobParam.UserType=JobParamIn.UserType;
        JobParam.ImageOnePath=JobParamIn.ImageOnePath;
        JobParam.ImageTwoPath=JobParamIn.ImageTwoPath;
        JobParam.AlgorithmParams=AlgorithmParams;
        
        % Create the JobState structure.
        JobState=JobStateIn;
        JobInfo=JobInfoIn;
        
        % Set success flag to indicate success.
        PPSuccessFlag = 1;
        PPErrorMsg = '';
        
        % Reset MATLAB path to previous.
        path(OldPath);
        
    case {'Developer'}
        % Under development.
    otherwise
        % Specified user type not valid. Print error messages and exit.
        ErrorMsgP1 = 'UserType is not valid. ';
        ErrorMsgP2 = 'Valid options are { EndUser, Developer }.';
        PPErrorMsg = [ ErrorMsgP1 ErrorMsgP2 ];
        fprintf( PPErrorMsg );
        PPSuccessFlag = 0;
        path(OldPath);
end


end




function AlgorithmIndex=QA(ImageOnePath, ImageTwoPath)

AlgorithmIndex = 2;

end






% Given an index, read algorithm parameters from table and return.
function [AlgorithmParams]=LookUpAlgorithm(AlgorithmIndex)

% Load algorithm table from disk.  Later, get this path
%  from configuration file.
load('/home/pcs/jm/IrisCloud/Usage/AlgorithmTable.mat')

% Using index, extract algorithm params from table
%row index, columns 3 and 4
AlgorithmName=Table{AlgorithmIndex,3};
AlgorithmType=Table{AlgorithmIndex,4};

% Form structure AlgorithmParams
AlgorithmParams.AlgorithmName = AlgorithmName;
AlgorithmParams.AlgorithmType = AlgorithmType;

end





%     This library is free software;
%     you can redistribute it and/or modify it under the terms of
%     the GNU Lesser General Public License as published by the
%     Free Software Foundation; either version 2.1 of the License,
%     or (at your option) any later version.
%
%     This library is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%     Lesser General Public License for more details.
%
%     You should have received a copy of the GNU Lesser General Public
%     License along with this library; if not, write to the Free Software
%     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
