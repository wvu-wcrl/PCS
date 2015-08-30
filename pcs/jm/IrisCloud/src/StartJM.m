% StartJM.m
% Startup script for job manager.
%
% Inputs
%  cfgFile          Full path to task controller configuration file.
%
% Outputs
%  JMObj         Job manager object.
%
%
%     Last updated on 8/14/2015
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti.
%     For full copyright information see the bottom of this file.



function JMObj = StartJM(cfgFile, queueCfg)


%  Factor out generic job manager
%%% Paths required for all job managers.
addpath( fullfile( filesep, 'home', 'pcs', 'util' ) );
addpath( fullfile( filesep, 'home', 'pcs', 'jm', 'CodedMod', 'src' ) );
addpath( fullfile( filesep, 'home', 'pcs', 'util', 'log') );


% Instantiate job manager object.
JMObj = SpecificJobManager( cfgFile, queueCfg );


% Execute job manager.
JMObj.RunJobManager();


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
