% plbp_jm_startup.m
% Startup script for PLBP job manager.
%
% Inputs
%  cfgFile          (Optional) Full path to task controlelr configuration file.
%
% Outputs
%  PlbpJMObj         PLBP job manager object.
%
%
%     Last updated on 10/14/2013
%
%     Copyright (C) 2013, Mohammad Fanaei and Matthew C. Valenti.
%     For full copyright information see the bottom of this file.



function PlbpJMObj = plbp_jm_startup(cfgFile, queueCfg)
% Calling Syntax: PlbpJMObj = plbp_jm_startup('/home/pcs/jm/plbp/cfg/PlbpJobManager_cfg',...
%                     '/home/pcs/tc/cfg/short.cfg');
if( nargin<1 || isempty(cfgFile) )
    cfgFile = fullfile(filesep, 'home', 'pcs', 'jm', 'plbp', 'cfg', 'PlbpJobManager_cfg');
end

addpath( fullfile( filesep, 'home', 'pcs', 'util' ) );
addpath( fullfile( filesep, 'home', 'pcs', 'util', 'log') );
addpath( fullfile( filesep, 'home', 'pcs', 'jm', 'CodedMod', 'src' ) );
addpath( fullfile( filesep, 'home', 'pcs', 'jm', 'plbp', 'src' ) );
addpath( fullfile( filesep, 'home', 'pcs', 'projects', 'plbp', 'mat') );
addpath( fullfile( filesep, 'home', 'pcs', 'projects', 'plbp', 'Model') );

PlbpJMObj = PLBPJobManager( cfgFile, queueCfg );

PlbpJMObj.RunJobManager();

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
