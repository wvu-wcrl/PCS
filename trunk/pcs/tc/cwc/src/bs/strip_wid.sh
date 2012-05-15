#!/bin/bash
# strip_wid.sh
# 
# remove worker ids from task filenames

input_dir=$1

cd $input_dir


(for i in $input_dir/*.mat;
do
IFS='_';
unset newname
cnt=1


  for word in $i
  do


  if [ $cnt -eq 1 ]
     then
        newname=$word
     elif [ $cnt -eq 3 ]
     then
        newname=$newname
     else
        newname=$newname\_$word
  fi

  cnt=$(($cnt+1))

  done

  # move to new filename                                                                                                                               \
                                                                                                                                                        
IFS=' ';
   mv $i $newname

 done
)
