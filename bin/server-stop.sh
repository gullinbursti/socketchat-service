#!/bin/bash



#-- find pid of server if running
pid=$(ps ax | grep server.py | grep -v grep | awk '{print $1}')

#-- force kill server
[[ ! -z "$pid" ]] && kill -9 $pid


#-- terminate w/o error
exit 0;
