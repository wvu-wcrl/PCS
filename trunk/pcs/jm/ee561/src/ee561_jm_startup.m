% ee561_jm_startup.m
% Startup script for ee561 job manager.
%
% Inputs
%  cfgFile          (Optional) Full path to job manager configuration file.
%
% Outputs
%  ee561JMObj       ee561 job manager object.
%
%
%     Last updated on 04/25/2013
%
%     Copyright (C) 2013, Mohammad Fanaei and Matthew C. Valenti.
%     For full copyright information see the bottom of this file.


function ee561JMObj = ee561_jm_startup(cfgFile, queueCfg)

if( nargin<1 || isempty(cfgFile) )
    cfgFile = fullfile(filesep, 'home', 'pcs', 'jm', 'ee561', 'cfg', 'ee561JobManager_cfg');
end

addpath( fullfile( filesep, 'home', 'pcs', 'util' ) );
addpath( fullfile( filesep, 'home', 'pcs', 'util', 'log') );
addpath( fullfile( filesep, 'home', 'pcs', 'projects', 'cml2', 'mex', lower(computer)) );
addpath( fullfile( filesep, 'home', 'pcs', 'projects', 'cml2', 'mat') );
addpath( fullfile( filesep, 'home', 'pcs', 'projects', 'ee561', 'mat') )
path( fullfile( filesep, 'home', 'pcs', 'jm', 'CodedMod', 'src' ), path );
path( fullfile( filesep, 'home', 'pcs', 'jm', 'ee561', 'src' ), path );

ee561JMObj = ee561JobManager( cfgFile, queueCfg );

ee561JMObj.RunJobManager();

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
