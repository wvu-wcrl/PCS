% CmlClusterRetrieve.m
% Run continuously, gather cml task files and combine to form cml data
% file.
%
%
%     Last updated on 7/10/2012
%
%     Copyright (C) 2012, Terry Ferrett, Mohammad Fanaei and Matthew C. Valenti
%     For full copyright information see the bottom of this file.



% loop%%%%

% check for cml tasks in global task output queue

% if tasks exist, 
%  determine which user this task belongs to
%
%  determine which scenario and record this task belongs to
%
%  retrieve sim_state for the current scenario and task
%
%  update sim_using the results of this task

%%%%%%%




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
