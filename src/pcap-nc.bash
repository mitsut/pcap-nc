#!/usr/bin/env bash

progdir=`dirname $0`

args_nc=""
args_replay=""
args_store=""
param_no_stdin=0
param_check_reply=0
param_use_store=0

SLEEP=0

while (( $# > 0 ))
do
    case $1 in
	--after |                      --after=*)
	    if [[ "$1" =~             ^--after= ]]; then
		OPT=$(echo $1 | sed -e 's/^--after=//')
	    elif [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
		echo              "'option --after' requires an argument." 1>&2
		exit 1
	    else
		OPT="$2"
		shift
	    fi
	    args_replay="$args_replay --after=$OPT"
	    ;;
	--before |                     --before=*)
	    if [[ "$1" =~             ^--before= ]]; then
		OPT=$(echo $1 | sed -e 's/^--before=//')
	    elif [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
		echo              "'option --before' requires an argument." 1>&2
		exit 1
	    else
		OPT="$2"
		shift
	    fi
	    args_replay="$args_replay --before=$OPT"
	    ;;
	--config |                     --config=*)
	    if [[ "$1" =~             ^--config= ]]; then
		OPT=$(echo $1 | sed -e 's/^--config=//')
	    elif [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
		echo              "'option --config' requires an argument." 1>&2
		exit 1
	    else
		OPT="$2"
		shift
	    fi
	    args_replay="$args_replay --config=$OPT"
	    ;;
	--channel |                    --channel=*)
	    if [[ "$1" =~             ^--channel= ]]; then
		OPT=$(echo $1 | sed -e 's/^--channel=//')
	    elif [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
		echo              "'option --channel' requires an argument." 1>&2
		exit 1
	    else
		OPT="$2"
		shift
	    fi
	    args_replay="$args_replay --channel=$OPT"
	    ;;
	--interval |                   --interval=*)
	    if [[ "$1" =~             ^--interval= ]]; then
		OPT=$(echo $1 | sed -e 's/^--interval=//')
	    elif [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
		echo              "'option --interval' requires an argument." 1>&2
		exit 1
	    else
		OPT="$2"
		shift
	    fi
	    args_replay="$args_replay --interval=$OPT"
	    ;;
	--store-data |                 --store-data=*)
	    if [[ "$1" =~             ^--store-data= ]]; then
		OPT=$(echo $1 | sed -e 's/^--store-data=//')
	    elif [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
		echo              "'option --store-data' requires an argument." 1>&2
		exit 1
	    else
		OPT="$2"
		shift
	    fi
	    args_replay="$args_replay --store-data=$OPT"
	    ;;
	--original-time)
	    args_replay="$args_replay --original-time"
	    ;;
	--link-type | --link-type=*)
	    if [[ "$1" =~ ^--link-type= ]]; then
		OPT=$(echo $1 | sed -e 's/^--link-type=//')
	    elif [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
		echo "'option --link-type' requires an argument." 1>&2
		exit 1
	    else
		OPT="$2"
		shift
	    fi
	    case $OPT in
		diosatlm | spp | spw)
		;;
		*)
		    echo "'option --link-type' requires either diosatlm, spp, or spw." 1>&2
		    exit 1
	    esac
	    args_store="$arg_store --link-type=$OPT"
		param_use_store=1
	    ;;
	--no-stdin)
		param_no_stdin=1
	    ;;
	--check-reply)
		param_check_reply=1
	    ;;
	--receive-reply |              --receive-reply=*)
		echo              "'option --receive-reply' is prohibited." 1>&2
		exit 1
	    ;;
	--sleep |                      --sleep=*)
	    if [[ "$1" =~             ^--sleep= ]]; then
		OPT=$(echo $1 | sed -e 's/^--sleep=//')
	    elif [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
		echo              "'option --sleep' requires an argument." 1>&2
		exit 1
	    else
		OPT="$2"
		shift
	    fi
	    SLEEP=$OPT
	    ;;
	--no-spw-on-eth)
	    args_replay="$args_replay --no-spw-on-eth"
		;;
	*)
	    # pass all other arguments to nc
	    args_nc="$args_nc $1"
	    
	    # TODO fix parameter with spaces
    esac
    shift
done
							    
# echo $args_nc
# echo $args_replay
# echo args_store=$args_store

sleep $SLEEP

FIFO=/tmp/pcapnc-fifo-$$
NOBUF='stdbuf -i 0 -o 0'
NC="nc -q 0 -w 10 -N $args_nc"

if   [[ "$param_check_reply" -ne 0 ]]; then	
		mkfifo $FIFO
    	$progdir/pcap-replay $args_replay --receive-reply $FIFO | $NOBUF $NC >$FIFO
		rm $FIFO
elif [[ "$param_use_store" -eq 0 ]]; then	
    if [[ "$param_no_stdin" -eq 0 ]]; then	
		$progdir/pcap-replay $args_replay | $NOBUF $NC
	else
	    									$NOBUF $NC
	fi
else
    if [[ "$param_no_stdin" -eq 0 ]]; then	
		$progdir/pcap-replay $args_replay | $NOBUF $NC | $NOBUF $progdir/pcap-store $args_store
	else
	                                        $NOBUF $NC | $NOBUF $progdir/pcap-store $args_store
	fi
fi
