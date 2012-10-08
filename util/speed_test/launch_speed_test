#!/bin/bash
# launch_speed_test.sh
#
# Execute CML simulation record using cluster and single-core operation.
#
# Inputs
#  1. CML Scenario
#  2. Record
#  3. Path to CML Root
#
#  Calling Example
#   > ./speed_test.sh t_BerSim 1 /home/tferrett/cml
#                                                               
#     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti   
#     For full copyright information see the bottom of this file.



########## variables ############
# inputs
SCENARIO=$1    #cml scenario and record to simulate
RECORD=$2


# paths to cml root and output directory
ST_ROOT=/home/pcs/util/speed_test      # speed test root
OUTPUT=$ST_ROOT/output                 # speed test result output


# screen session names
LOCAL_SIM=$SCENARIO\_$RECORD"_L"
CLUSTER_SIM=$SCENARIO\_$RECORD"_C"
SIM_MONITOR=$SCENARIO\_$RECORD\_"M"

# path to cml
CMLROOT=/home/pcs/projects/cml


# Output PDF file name
PDF_FN=$SCENARIO\_$RECORD".pdf"
##################################



#### functions         
start_local_sim(){
screen -S $LOCAL_SIM -m -d matlab -r "cd $CMLROOT; CmlStartup; CmlSimulate('$SCENARIO',$RECORD); exit"
}


start_cluster_sim(){
screen -S $CLUSTER_SIM -m -d matlab -r "cd $CMLROOT; CmlStartup; CmlClusterSubmit('$SCENARIO', $RECORD); CmlClusterRetrieve; exit"
}


stop_screen_session(){
screen -ls |grep $1 | awk -F . '{print $1}' |xargs kill
}


destroy_existing_speed_test(){
stop_screen_session $LOCAL_SIM
stop_screen_session $CLUSTER_SIM
stop_screen_session $SIM_MONITOR
}



##### main execution flow (continuous)

destroy_existing_speed_test

start_local_sim $SCENARIO $RECORD

start_cluster_sim $SCENARIO $RECORD

screen -S $SIM_MONITOR -m -d ./monitor_sims $LOCAL_SIM $CLUSTER_SIM


#####




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
#     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  US


