#!/bin/bash
# start_worker.sh
# Inputs
#  1. Worker path
#  2. hostname
#  3. Worker ID
#
#     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
#     For full copyright information see the bottom of this file.


# Input variables.
hostname=$1
worker_path=$2
worker_exe=$3
worker_id=$4
iq=$5
rq=$6
oq=$7
lfup=$8
lf=$9
log_period=${10}
num_logs=${11}
verbose_mode=${12}
wsp=${13}



# Connect to the node and start the worker as a daemon.
ssh $hostname "export MATLABPATH=$worker_path; nohup matlab -singleCompThread -r $worker_exe\($worker_id,\'$iq\',\'$rq\',\'$oq\',\'$lfup\',\'$lf\',\'$log_period\',\'$num_logs\',\'$verbose_mode\',\'$wsp\'\) >> $lf 2>&1 &"



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
