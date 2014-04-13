% LDPCBEC_jm_startup.m
% Startup script for LDPC-BEC job manager.
%
% Inputs
%  cfgFile          (Optional) Full path to task controlelr configuration file.
%
% Outputs
%  LdpcBecJMObj     LDPC-BEC job manager object.
%
%
%     Last updated on 4/12/2014
%
%     Copyright (C) 2014, Mohammad Fanaei and Matthew C. Valenti.
%     For full copyright information see the bottom of this file.



function LdpcBecJMObj = LDPCBEC_jm_startup(cfgFile, queueCfg)
% Usage: LdpcBecJMObj = LDPCBEC_jm_startup('/home/pcs/jm/LDPC-BEC/cfg/LDPC-BECJobManager_cfg','/home/pcs/tc/cfg/pcs_short_384.cfg');
if( nargin<1 || isempty(cfgFile) )
    cfgFile = fullfile(filesep, 'home', 'pcs', 'jm', 'LDPC-BEC', 'cfg', 'LDPC-BECJobManager_cfg');
end

addpath( fullfile( filesep, 'home', 'pcs', 'util' ) );
addpath( fullfile( filesep, 'home', 'pcs', 'jm', 'CodedMod', 'src' ) );
addpath( fullfile( filesep, 'home', 'pcs', 'util', 'log') );

LdpcBecJMObj = BECJobManager( cfgFile, queueCfg );

LdpcBecJMObj.RunJobManager();

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