% UpdateJobState.m
%  Takes matching score computed by task as input, and stores
%  it in the job's state.
%
%  Inputs
%   obj         Specific job manager object.
%   JobStateIn  Job state prior to receiving matching score.
%   TaskState   Task state containing computed matching score.
%   JobParam    Job parameters.
%
%  Outputs
%   JobState  Job state containing matching score computed by task.
%
%
%     Last updated on 9/7/2015
%
%     Copyright (C) 2015, Terry Ferrett and Matthew C. Valenti.
%     For full copyright information see the bottom of this file.


function JobState = UpdateJobState(obj, JobStateIn, TaskState, JobParam)

% Assign the task state matching score to JobState
JobState.MatchingScore=TaskState.MatchingScore;

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

