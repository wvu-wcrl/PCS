#!/bin/bash
# create_proj.sh
#
# create a project directory structure and configuration file for web user

# inputs
# 1. username
# 2. projname
#
# outputs
# 1. project configuration file


### console input#
username=$1    
projname=$2
##################



# path to web user home directory
webuser_home=/home/web_users/$username
###############################



# create project directory structure
mkdir -p $webuser_home/Projects
mkdir -p $webuser_home/Projects/$projname/figures
mkdir $webuser_home/Projects/$projname/JobIn
mkdir $webuser_home/Projects/$projname/JobRunning
mkdir $webuser_home/Projects/$projname/JobOut
mkdir $webuser_home/Projects/$projname/data
mkdir $webuser_home/Projects/$projname/archive
########################





# paths to configuration files #
cfg_filename=$projname\User\_cfg.txt

root_cfg_path=/home/pcs/jm/$projname/cfg/$cfg_filename
user_cfg_path=$webuser_home/$cfg_filename
#####################



# copy initial configuration file project root to user home
#    assumed that config filename has structure $projname\_cfg.txt
cp $root_cfg_path $user_cfg_path



# populate fields with default values
sed -i "s/\/home\/mfanaei/\/home\/web_users\/$username/g" $user_cfg_path 




