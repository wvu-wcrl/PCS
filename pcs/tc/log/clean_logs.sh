#!/bin/bash
# remove MATLAB splash text from log files.
# running this script on an active worker's log file will crash the worker

for file in `ls -d *.log` ; do

sed -i '/Warning/,/>>/ d' $file

done
