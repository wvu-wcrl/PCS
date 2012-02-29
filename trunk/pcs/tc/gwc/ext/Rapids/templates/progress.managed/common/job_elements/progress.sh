#!/bin/sh

progress=".00"
echo "reporting progress: ${progress}"
runtime-request progress ${progress}
for i in {1..4}; do
  echo "sleeping..."
  sleep 60 
  progress=`echo "scale=2;$i/4" | bc`
  echo "reporting progress: ${progress}"
  runtime-request progress ${progress}
done 

exit 0
