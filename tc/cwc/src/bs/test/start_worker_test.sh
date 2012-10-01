#!/bin/bash
# start_worker_test.sh

# test the worker startup script
#
#     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
#     For full copyright information see the bottom of this file.


# Input variables.
hostname=node01
worker_path=/rhome/pcs/tc/cwc/src/gw
worker_exe=gw
worker_id=1
iq=/rhome/pcs/tc/queue/cluster/iq
rq=/rhome/pcs/tc/queue/cluster/rq
oq=/rhome/pcs/tc/queue/cluster/oq
lf=/rhome/pcs/tc/log/short/1.log
lfup=604800
log_period=604800
num_logs=6
verbose_mode=0





# Connect to the node and start the worker as a daemon.
ssh $hostname "export MATLABPATH=$worker_path; nohup matlab -singleCompThread -r $worker_exe\($worker_id,\'$iq\',\'$rq\',\'$oq\',\'$lfup\',\'$lf\'\
,\'$log_period\',\'$num_logs\',\'$verbose_mode\'\)"

# Get the process ID.
ssh $hostname "ps -ef" |grep -i "matlab -r $worker_exe($worker_id," | awk '{ print $2 }'



#     This library is free software;
#     you can redistribute it and/or modify it under the terms of
#     the GNU Lesser General Public License as published by the
#     Free Software Foundation; either version 2.1 of the License,
#     or (at your option) any later version.
#
#     This library is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#     Lesser General Public License for more details.
#
#     You should have received a copy of the GNU Lesser General Public
#     License along with this library; if not, write to the Free Software
#     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
