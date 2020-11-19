#!/bin/bash



#-- find pid of server if running
pid=$(ps ax | grep server.py | grep -v grep | awk '{print $1}')

#-- stop server if running
[[ ! -z "$pid" ]] && /usr/local/bin/server-stop

#-- start server
/usr/local/bin/server-start


#-- terminate w/o error
exit 0;
