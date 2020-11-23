#!/bin/bash



#-- define utc timestamp
epoch=$(date -u +%d%b%Y_%H%M%S | tr '[:lower:]' '[:upper:]')

#-- ctl usage
usage_msg="usage: $0 [ --help | -h ] [ stop ] [[ start ] [ restart ] [ --host ADDR] [ --port PORT ]]"



#-- get localhost ip
ip_local=$(ifconfig eth0 | grep inet | grep broadcast | awk '{print $2}')


#-- defaults
action=
addr=


#-- default connection
hostname=$ip_local
port=12222


#-- -=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=- --#


#-- parse params
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            shift
            echo "${usage_msg}"
            exit 0
            ;;
        start|stop|restart)
            action=$1
            shift
            ;;
        --host)
            hostname=$2
            shift ; shift ;
            ;;
        --port)
            port=$2
            shift ; shift ;
            ;;
         *)
            echo "Error: unknown option '$1'"
            exit 1
        esac
done


#-- -=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=- --#


restart() {
#    echo "restart() -->"
#    printf "pid=[%s] addr=[%s] hostname_curr=[%s] port_curr=[%s] hostname=[%s] port=[%s]\n" "$pid" "$addr" "$hostname_curr" "$port_curr" "$hostname" "$port"
    netstat -pltn

    local addr_diff=""
    [[ "$hostname" = "$hostname_curr" && "$port" = "$port_curr" ]] && addr_diff=" (same)"

    if [[ -z "$pid" ]]; then
        printf "Server not running, starting now on [%s:%d]...\n" "${hostname}" $port

    else
        printf "Restarting server (%d) currently on [%s:%d] with [%s:%d]%s..." $pid "$hostname_curr" $port_curr "$hostname" $port "$addr_diff"
        stop && echo
    fi

    start
}



start() {
    local hist_log=/var/log/socketchat/history.log
    local err_log=/var/log/socketchat/error.log
    [[ ! -z "$pid" ]] && printf "Server already running (%d) on [%s:%d], exiting...\n" $pid $hostname_curr $port_curr && exit 1

    printf "Server starting up on [%s:%d]...\n" "${hostname}" $port

    cd /home/pi/socketchat
    /usr/bin/python3 server.py 2>> $err_log >> $hist_log
}



stop() {
#    printf "pid=[%s] addr=[%s] hostname=[%s] port=[%s]\n" "$pid" "$hostname_curr" "$port_curr"

    [[ -z "$pid" ]] && printf "Server not running, exiting...\n" && exit 1
    printf "Stopping server (%d) on [%s:%d]..." $pid "$hostname_curr" $port_curr
    kill -9 $pid && echo
}


#-- -=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=- --#



#-- log file
act_log=/var/log/socketchat/actions.log


#-- has pid, get current addr
pid=$(ps ax | grep python3 | grep server.py | grep -v grep | awk '{print $1}')
if [[ ! -z "$pid" ]]; then
    addr=$(netstat -pltn 2> /dev/null | grep "$pid" | awk '{print $4}' | tr ':' ' ')
    hostname_curr=$(echo -e $addr | cut -d\  -f1)
    port_curr=$(echo -e $addr | cut -d\  -f2)
fi


#-- append log w/ timestamp / action / addr
printf "%s\t%s\t[%s:%d]\n" "${epoch}" "${action}" "${hostname}" $port >> $act_log
#cat $act_log

#-- -=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=- --#


#-- route base on action
[[ "$action" = "start" ]] && start
[[ "$action" = "restart" ]] && restart
[[ "$action" = "stop" ]] && stop



#-- terminate w/o error
exit 0;

#-- -=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=- --#
