#!/bin/bash



usage_msg="socketchat-logger [ --port=NUM | -p NUM ] [ --help | -h ]"


#-- log base dir
base_dir=/var/log/socketchat


#-- default port
port=12221


#--parse params
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            shift
            echo "${usage_msg}"
            exit 0
            ;;
        -p|--port)
            port=$2
            shift ; shift ;
            ;;
         *)
            echo "Error: unknown option '$1'"
            exit 1
        esac
done


#-- -=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=- --#

#-- broadcast log files using netcat
tail -f ${base_dir}/actions.log ${base_dir}/history.log ${base_dir}/error.log | nc -vkl $port


#-- terminate w/o error
exit 0;

#-- -=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=- --#
