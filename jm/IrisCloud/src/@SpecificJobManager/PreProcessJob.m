% PreProcessJob.m
%  Optional. Transform job parameters and state prior to job execution.
%
%     Last updated on 8/14/2015
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti.
%     For full copyright information see the bottom of this file.


function [JobParam, JobState, JobInfo, PPSuccessFlag, PPErrorMsg] =...
    PreProcessJob(obj, JobParamIn, JobStateIn, JobInfoIn, CurrentUser, JobName)


%  Assign input data structures to output.
%  Modify if necessary.
CodeRoot = CurrentUser.CodeRoot;

% First, set the path to Algorithms and QA.
OldPath = obj.SetCodePath(CodeRoot);
Username = obj.FindUsername(CurrentUser.UserPath);

% Check for the UserType field in JobParamIn 
if( isfield(JobParamIn,'UserType') && ~isempty(JobParamIn.UserType) )
    switch JobParamIn.UserType
        
        case{'EndUser'}
            
          
            % Check for the fields which have the Image Paths
            if (isfield(JobParamIn,'ImageOnePath')&& ~isempty(JobParamIn.ImageOnePath))
                if (isfield(JobParamIn,'ImageTwoPath')&& ~isempty(JobParamIn.ImageTwoPath))

                    %  Decide where to store Dr. Adjeroh's QA code.
                    AlgorithmIndex=QA(JobParamIn.ImageOnePath,JobParamIn.ImageTwoPath);
                    
                    % Look for the Algorithm Name corresponding to
                    % the algorithm index in the table 
                    
                    % Terry will write
                    [AlgorithmParams]=LookUpAlgorithm(AlgorithmIndex);
                    
                    
                    % Creating the structure of JobParam
                    JobParam.InputParam.ImageOnePath=JobParamIn.ImageOnePath;
                    JobParam.InputParam.ImageTwoPath=JobParamIn.ImageTwoPath;
                    JobParam.InputParam.AlgorithmParams= AlgorithmParams;
                    JobParam.InputParam.UserType=JobParamIn.UserType;
                  
                    
                    JobState=JobStateIn;
                    JobInfo=JobInfoIn;
                    
                    
                    
                    PPSuccessFlag = 1;
                    PPErrorMsg = '';
                    
                    path(OldPath);

                    
                else
                    
                    PPErrorMsg = sprintf( 'Sorry. Image 2 not found\n' );
                    fprintf( ErrorMsg );
                    PPSuccessFlag = 0;
                    path(OldPath);
                    return;
                end
            else
                PPErrorMsg = sprintf( 'Sorry. Image 1 not found\n' );
                fprintf( ErrorMsg );
                PPSuccessFlag = 0;
                path(OldPath);
                return;
            end
        case {'Developer'}
            % Yet to decide on it
        otherwise
            PPErrorMsg = sprintf( 'Sorry. UserType is not valid. Only valid options are EndUser or Developer.\n' );
            fprintf( ErrorMsg );
            PPSuccessFlag = 0;
            path(OldPath);
    end
end


end




function AlgorithmIndex=QA(ImageOnePath, ImageTwoPath)

AlgorithmIndex = 1;

end






% Given an index, read algorithm parameters from table and return.
function [AlgorithmParams]=LookUpAlgorithm(AlgorithmIndex)



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
