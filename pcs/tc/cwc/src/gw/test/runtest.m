%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.

rootdir = pwd;

cd ..; addpath(pwd); cd(rootdir);  % add gw to path

% set queue paths
cd iq; iq = pwd; cd(rootdir);
cd oq; oq = pwd; cd(rootdir);
cd rq; rq = pwd; cd(rootdir);

% copy input to input queue
cs = ['cp' ' ' 'test_task_1.mat' ' ' iq '/' 'tferrett_' 'test_task_1.mat'];
system(cs);

lfup = '/home/tferrett/proj/iscml/pcs/util/log';
lfip = '/home/tferrett/';
LOG_PERIOD = 10000;
NUM_LOGS = 2;
VERBOSE_MODE = 0;

% start generic worker
cd(rootdir);


gw(1, iq, rq, oq, lfup, lfip, LOG_PERIOD, NUM_LOGS, VERBOSE_MODE);


% observe queues




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
