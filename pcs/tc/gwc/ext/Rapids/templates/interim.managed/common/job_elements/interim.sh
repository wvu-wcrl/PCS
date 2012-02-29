#!/bin/sh

progress=".00"
echo "reporting interim results: ${progress}" > result.txt
runtime-request interim-result ${progress}
for i in {1..4}; do
  echo "sleeping..."
  sleep 60 
  progress=`echo "scale=2;$i/4" | bc`
  echo "reporting interim results : ${progress}" >> result.txt
  runtime-request interim-result ${progress}
done 

exit 0
