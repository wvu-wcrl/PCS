#!/bin/bash
# create_web_user.sh
#
# script to create a web-based webcml user
# called from web application

# inputs
# 1. username

un=$1                 #username

wup=/home/web_users   #web user path


home=$wup/$un
# create user home directory
mkdir $home


# create task directory structure
mkdir $home/tasks
mkdir $home/tasks/input
mkdir $home/tasks/running
mkdir $home/tasks/output


# create ctc configuration file
echo [paths] >> $home/.ctc_cfg
echo input = $home/tasks/input >> $home/.ctc_cfg
echo active = $home/tasks/running >> $home/.ctc_cfg
echo output = $home/tasks/output >> $home/.ctc_cfg


chown -R web_users:web_users $home   # change ownership to web_users
