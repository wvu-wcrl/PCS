% CalcTaskInputParam.m
% Construct task input structure
%     InputParam
% using job parameters and state read from user job file.
%
%
% Inputs
%  obj          Specific job manager object.
%  JobParam     JobParam structure read from user's job file.
%  JobState     JobState structure read from user's job file.
%  NumNewTasks  *ask Mohammad*
%
% Outputs
%  TaskInputParam    Input structure for tasks.
%
%
%     Last updated on 9/7/2015
%
%     Copyright (C) 2015, Terry Ferrett and Matthew C. Valenti.
%     For full copyright information see the bottom of this file.

function TaskInputParam = ...
    CalcTaskInputParam(obj, JobParam, JobState, NumNewTasks)

% Compute
switch JobParam.UserType
    case{'EndUser'}
        TaskInputParam.ImageOnePath = JobParam.ImageOnePath;
        TaskInputParam.ImageTwoPath = JobParam.ImageTwoPath;
        TaskInputParam.AlgorithmParams = JobParam.AlgorithmParams;
        TaskInputParam.UserType = JobParam.UserType;
        TaskInputParam.JobState = JobState;
    case {'Developer'}
        
    otherwise
end
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


