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
mkdir $webuser_home/Projects
mkdir $webuser_home/Projects/figures
mkdir $webuser_home/Projects/JobIn
mkdir $webuser_home/Projects/JonRunning
mkdir $webuser_home/Projects/JobOut
mkdir $webuser_home/Projects/data
mkdir $webuser_home/Projects/archive
########################





# paths to configuration files #
cfg_filename=$projname\_cfg.txt

root_cfg_path=/home/pcs/tc/jm/$projname/user/cfg/$cfg_filename
user_cfg_path=$webuser_home/$cfg_filename
#####################



# copy initial configuration file project root to user home
#    assumed that config filename has structure $projname\_cfg.txt
cp $root_cfg_path $user_cfg_path



# populate fields with default values
sed -i "s/\/home\/mfanaei/\/home\/web_users\/$username/g" $user_cfg_path 




