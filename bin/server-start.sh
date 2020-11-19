#!/bin/bash



#-- define utc timestamp
epoch=$(date -u | tr ':' ' ' | awk '{printf "%02d-%s-%04d.%02d%02d%02d",$3,$2,$NF,$4,$5,$6}')

#-- move into base dir
cd /home/pi/socketchat

#-- update from git, use master
git pull &> /dev/null

#-- currrent branch
branch_git=$(git branch | grep "*" | cut -d\  -f2)

#-- not on master, change branch
[[ "$branch_git" != "master" ]] && git checkout master &> /dev/null

#-- define log paths / files
base_log=/var/log/socketchat
err_log="${base_log}/error_${epoch}.log"

#-- check log dir
[[ ! -d "$base_log" ]] && mkdir -p $base_log

#-- start python
/usr/bin/python3 server.py 2> "${err_log}"


#-- terminate w/o error
exit 0;
