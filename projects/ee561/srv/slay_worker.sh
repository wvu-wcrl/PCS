#!/bin/bash
# slay_worker.sh
#
# Inputs
#  1. hostname


# Input variables.
hostname=$1

# Connect to the node and stop the worker.
#ssh $hostname "ps aux|grep -i matlab| awk '{print $2}' |xargs kill"
PIDS=`ssh $hostname "ps aux|grep -i matlab" | awk '{print $2}'`
ssh $hostname "kill -9 "$PIDS""