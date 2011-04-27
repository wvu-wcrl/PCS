#!/bin/bash
# start_worker.sh
# Inputs
#  1. Worker path
#  2. hostname
#  3. Worker ID


# Input variables.
hostname=$1
worker_path=$2
worker_exe=$3
worker_id=$4
cml_path=$5

# Connect to the node and start the worker as a daemon.
ssh $hostname "export MATLABPATH=$worker_path; nohup matlab -r $worker_exe\($worker_id,\'$cml_path\'\) > /dev/null 2>&1 &"

# Get the process ID.
ssh $hostname "ps -ef" |grep -i "matlab -r $worker_exe($worker_id," | awk '{ print $2 }'
