% startup_long.m
%
% initialize the long queue worker controller
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.

rootdir = pwd;
cd ..; cd ..; cd ..;
cd util/;
addpath(pwd);



cfg_file = 'pcs_long_384.cfg';

cd(rootdir); cd ..; cd ..; cd cfg/;

cfg_file = strcat(pwd, '/', cfg_file);

cd(rootdir);

cwcobj = cwc(cfg_file);



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
