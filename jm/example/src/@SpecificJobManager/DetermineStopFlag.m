% DetermineStopFlag.m
%  This method implements the following functionality
%
%   1. Determine if job stopping criteria has been met.
%
%   2. Compute and display job progress.
%
%   3. Updates results file.
%
%     Last updated on 8/14/2015
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti.
%     For full copyright information see the bottom of this file.


function [StopFlag, JobInfo, varargout] = ...
DetermineStopFlag(obj, JobParam, JobState, JobInfo, JobName, Username, FiguresDir)

% StopFlag takes one of the following values
%  1 - job complete
%  0 - job must continue
%
% In this example, the stopping criteria is defined as
%  Stop when real valued variable
%   JobState.u_s 
%  takes a value greater than 20.

if JobState.u_s > 20,
   StopFlag = 1;
else
   StopFlag = 0;
end

% Update JobInfo if necessary.


% Assign JobParam and JobState to output arguments.
varargout{1} = JobParam;
varargout{2}= JobState;

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
