#!/bin/bash
#
# chkconfig: 345 80 20
# description: Starts and stops all tomcat/rctc instances.
#


if [ "$DEBUG" = "YES" ]
then
	set -x
fi
ulimit -n 10000

die()
{
    echo "ERROR: $1" >&2
    exit 1
}

# it's possible to redirect to custom config via enviroment variable
# if env variable not defined, use hardcoded config location
if [ -z "$RCTC_GLOBAL_CONF" ]
then
	RCTC_GLOBAL_CONF=/etc/rctc.conf
fi

source $RCTC_GLOBAL_CONF
[ -n "$INSTANCES_DIR" ] || die "configuration error, INSTANCES_DIR not definned"

#LOGFILE=/var/log/rctc.log

get_jvm_pid()
{
	local tcname=$1
	pgrep -f Dtcid="$tcname "
}

print_thread_dump()
{
	local tcname=$1
	local jvm_pid

	jvm_pid=$(get_jvm_pid $tcname)
	if [ -n "$jvm_pid" ]
	then
		echo "INFO: thread dump for JVM pid $jvm_pid"
	else
		echo "ERROR: thread dump for JVM failed, PID error"
		return 1
	fi
	if jps | grep -q "^$jvm_pid "
	then
		echo "INFO: PID looks OK"
	else
		echo "ERROR: PID error"
		return 1
	fi

	cd "$INSTANCES_DIR"/"$tcname" || die "missing directory"
	sudo -u tc$tcname $JAVA_HOME/bin/jstack ${THREAD_DUMP_JSTACK_PARAMS} $jvm_pid
	
}

get_tclist()
{
    cd "$INSTANCES_DIR" || exit 1
    find -L -mindepth 2 -maxdepth 2 -name run.conf | cut -d / -f 2
}

get_tcstatus()
{
	local tcname=$1
	grep  '<Server port=' "$INSTANCES_DIR"/"$tcname"/conf/server.xml | sed -e 's#.*port="\([[:digit:]]*\)" .*#\1#g' | head -n 1 | while read port
	do
		( netstat -nlt | grep -q :$port ) && echo tomcat up || echo tomcat down
	done
}

get_server_port()
{
	xmlstarlet sel -t -m "/Server" -v "@port" server.xml 
}


#log()
#{
#	timestamp=$(date +"%Y-%m-%d %H:%M:%S")
#	echo "$timestamp $1" >> $LOGFILE
#}

# possible to use /etc/init.d/rctc-tcname <command>
if echo $0 | grep -q rctc-.*
then
	rctc $1 $(echo $(basename $0) | cut -d - -f 2)
	exit $?
fi

if [ "$2" = "ALL" ]
then
    tclist=$(get_tclist)
else
    tmpargs=$@
    shift
    tclist=$@
    set -- $tmpargs
fi

if [ "$1" = "list" -a "$2" = "" ]
then
    tclist=$(get_tclist)
fi


case $1 in
	start|stop|force-stop)
		#log "$1 tclist=$tclist"
		[ "$1" = "stop" -a "$THREAD_DUMP_ON_STOP" = "YES" -a "$SKIP_THREAD_DUMP" != "YES" ] \
			&& $0 thread-dump $tclist
		for tcname in $tclist
		do
			cd "$INSTANCES_DIR"/"$tcname" || die "missing directory"
			test -f run.conf || die "missing run.conf"

			if [ -f run.sh ]
			then
				echo "WARN: using local run.sh"
				RUNSH_PATH=.
			else
				RUNSH_PATH=/usr/libexec/rctc
			fi

			su - tc"$tcname" -c "cd "$INSTANCES_DIR"/\"$tcname\" && $RUNSH_PATH/run.sh \"$1\""
		done
	;;
	restart|force-restart)
		#log "$1 tclist=$tclist"
		[ "$THREAD_DUMP_ON_RESTART" = "YES" -a "$SKIP_THREAD_DUMP" != "YES" ] \
			&& $0 thread-dump $tclist
		$0 stop $tclist
		sleep 2
		$0 start $tclist
	;;
	fast-restart)
		#log "$1 tclist=$tclist"
		SKIP_THREAD_DUMP=YES $0 restart $tclist
	;;
	list)
		echo "$tclist"
	;;
	kill)
		#log "$1 tclist=$tclist"
		[ "$THREAD_DUMP_ON_KILL" = "YES" ] \
			&& $0 thread-dump $tclist
		for tcname in $tclist
		do
			cd "$INSTANCES_DIR"/"$tcname" || die "missing directory"
			test -f run.conf || die "missing run.conf"

			pkill -9 -u "tc$tcname" -f "Dtcid=$tcname "
		done
	;;
	status)
		for tcname in $tclist
		do
			echo "$tcname: $(get_tcstatus $tcname)"
		done
	;;
	logtail)
		echo "$tclist"
		export GLOBIGNORE='*.gz'
		exec tail -n 3 -F "$INSTANCES_DIR"/$tclist/logs/*
		#logtail $( for i $(find /srv/tc/$tclist/logs -type f -maxdepth 1 ) ; do echo -n "-f $i " ; done ; echo)
	;;
	init)
		#log "$1 tclist=$tclist"
		if [ "$(echo "$tclist" | wc -w)" -eq 1 ]
		then
			# temporary - we are working only with 1 name per run
			tcname=$tclist
			
			mkdir -p "$INSTANCES_DIR"/$tcname
			cd "$INSTANCES_DIR"/"$tcname" || die "Instance directory not found. Please create it by hand and run init again."
			[ "$(ls | wc -l)" -eq 0 ] || die "Instance directory already populated."
			grep -q "^tc$tcname:" /etc/passwd || die "Instance user not found. Please add it by hand and run init again."

			echo -n "populating "$INSTANCES_DIR"/$tcname: "
			if [ -z "$INSTANCE_TEMPLATE_FILES" ]
			then
				INSTANCE_TEMPLATE_FILES=/usr/lib/rctc/instance-template/*.tgz
			fi
			for templatefile in $INSTANCE_TEMPLATE_FILES
			do
				echo -n "$(basename $templatefile) "
				tar xzf $templatefile
			done
			echo "."
			if [ -n "$INSTANCE_SERVERXML_GENERATOR" ]
			then
				echo "generating server.xml from template..."
				eval $INSTANCE_SERVERXML_GENERATOR > conf/server.xml
			fi

			echo -n "fixing permissions: "
			chown -R tc$tcname: "$INSTANCES_DIR"/"$tcname"
			echo "done."
			
		else
			die "I could init only one instance."
		fi
			
	;;
	init-user)
		if [ "$(echo "$tclist" | wc -w)" -eq 1 ]
		then
			# temporary - we are working only with 1 name per run
			tcname=$tclist
			adduser --system -m -d "$INSTANCES_DIR/$tcname" tc$tcname
		else
			die "I could init only one user."
		fi
	;;
	thread-dump)
		for tcname in $tclist
		do
			cd "$INSTANCES_DIR"/"$tcname" || die "missing directory"
			test -f run.conf || die "missing run.conf"

			thread_dump_logfile="logs/rctc-thread-dump.$(date "+%F_%T").log"
			echo "INFO: thread dump file: $thread_dump_logfile"
			print_thread_dump $tcname > $thread_dump_logfile
		done
	;;
	running)
		ps -ef | grep tcid
	;;
	*)
		echo "Tomcat instance manager - rctc"
		echo "Usage:  $0 <cmd> <tclist>"
		echo ""
		echo "  cmd "
		echo "     * start 		no-comment"
		echo "     * stop 		no-comment"
		echo "     * restart 		no-comment"
		echo "     * fast-restart 	no-comment"
		echo "     * kill 		no-comment"
		echo "     * status 		print instance status"
		echo "     * logtail 		log all logs/\*.log logs"
		echo "     * init 		initialize new instance"
		echo "     * running 		list running instances "
		echo "     * thread-dump 	prints thread dump with jstack "
		echo ""
		echo "   tclist "
		echo "     * <tcname> ... tomcat intsance name"
		echo "     * ALL ... expanded to all available instances"
		echo ""
	;;
esac
