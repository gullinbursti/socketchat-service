#!/bin/bash



#-- define utc timestamp
epoch=$(date -u +%d%b%Y_%H%M%S | tr '[:lower:]' '[:upper:]')


#-- default action
action=


#-- default connection
hostname=localhost
port=12222


#-- background flags to 0
b_flg=0


#-- -=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=- --#


#-- parse params
while [ $# -gt 0 ]; do
    case "$1" in
        "-?"|-h|--help)
            shift
            echo "usage: $0 [ --help | -? ] [ -t | --stop ] [[ --start | -s ] [ -restart | -r ] [ --bg | -b ] [ --host ADDR] [ --port PORT ]]"
            exit 0
            ;;
        -t|--stop)
            action=stop
            shift ;
            ;;
        -s|--start)
            action=start
            shift ;
            ;;
        -r|--restart)
            action=restart
            shift ;
            ;;
        -b|--bg)
            b_flg=1
            shift ;
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
    local addr_diff=""
    [[ "$hostname" = "$homename_curr" && "$port" = "$port_curr" ]] && addr_diff=" (same)"

    if [[ -z "$pid" ]]; then
        printf "Server not running, starting now on [%s:%d]...\n" "${hostname}" $port

    else
        printf "Restarting server (%d) currently on [%s:%d] with [%s:%d]%s..." $pid "$hostname_curr" $port_curr "$hostname" $port "$addr_diff"
        stop && echo
    fi

    start
}



start() {
    [[ ! -z "$pid" ]] && printf "Server already running (%d) on [%s:%d], exiting...\n" $pid $hostname_curr $port_curr ; exit 1

    printf "Server starting up on [%s:%d]...\n" "${hostname}" $port
    /usr/bin/python3 /home/pi/socketchat/server.py
#// [[ "$b_flg" -eq 1 ]] && 
}



stop() {
    [[ -z "$pid" ]] && printf "Server not running, exiting...\n" ; exit 1;
    printf "Stopping server (%d) on [%s:%d]..." $pid "$homename_curr" $port_curr
    kill -9 $pid && echo
}


#-- -=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=- --#



#-- log file
log_path=/var/log/socketchat/history.log
echo "${log_path}"


#-- has pid, get current addr
pid=$(ps ax | grep python3 | grep server.py | grep -v grep | cut -d\  -f2)
if [[ ! -z "$pid" ]]; then
    addr=$(netstat 2> /dev/null | grep "$pid" | awk '{print $4}' | tr ':' ' ')
    hostname_curr=$(echo -e $addr | cut -d\  -f1)
    port_curr=$(echo -e $addr | cut -d\  -f2)
fi


#-- append log w/ timestamp / action / addr / bg flag
printf "%s %s\t[%s:%d] [b_flg=%d]\n" "${epoch}" "${action}" "${hostname}" $port $b_flg >> log
cat log

#-- -=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=- --#


#-- use action value as function call
[[ ! -z "$action" ]] && $action



#-- terminate w/o error
exit 0;

#-- -=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=- --#
