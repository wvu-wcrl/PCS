#!/bin/bash
# stop_worker.sh
# Inputs
#  1. hostname
#  2. Process ID


# Input variables.
hostname=$1
process_id=$2

# Connect to the node and stop the worker.
ssh $hostname "kill -9 $process_id"
