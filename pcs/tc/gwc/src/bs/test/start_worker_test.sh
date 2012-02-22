#!/bin/bash
# start_worker_test.sh

# test the worker startup script



# Input variables.
hostname=node03
worker_path=/rhome/pcs/iscml/wvu_pcs/wc/gw
worker_exe=gw
worker_id=1
iq=/rhome/pcs/queue/iq
rq=/rhome/pcs/queue/rq
oq=/rhome/pcs/queue/oq
lf=/rhome/pcs/log/1.log


# Connect to the node and start the worker as a daemon.
ssh $hostname "export MATLABPATH=$worker_path; nohup matlab -nosplash -r $worker_exe\($worker_id,\'$iq\',\'$rq\',\'$oq\'\) >> $lf 2>&1 &"
#ssh $hostname "export MATLABPATH=$worker_path; nohup matlab -r $worker_exe\($worker_id,\'$iq\',\'$rq\',\'$oq\'\)"

# Get the process ID.
ssh $hostname "ps -ef" |grep -i "matlab -r $worker_exe($worker_id," | awk '{ print $2 }'
