#!/bin/bash
#set -x
if [ "$DEBUG" = "YES" ]
then
	set -x
fi

die()
{
	echo "ERROR: $1"
	exit 1
}

[ -f run.conf ] || die "config file not found"
. run.conf 

log()
{
	echo "$(date +"%Y-%m-%d %H:%M:%S") $@" >> logs/run.log
}


##
# add specific token for process identification
#

export CATALINA_OPTS="-Dtcid=${USER#tc} $CATALINA_OPTS"
export TOMCAT_INSTANCE_PREFIX=/srv/tc

###
# report sourced variables
#

echo "executing catalina.sh $1 with environment variables:"
echo "  CATALINA_HOME: $CATALINA_HOME"
echo "  JAVA_HOME:     $JAVA_HOME"
echo "  CATALINA_OPTS: $CATALINA_OPTS"
echo "  JAVA_OPTS: $JAVA_OPTS"
echo
echo "  REMOTE_DEBUG:      $REMOTE_DEBUG"
echo "  REMOTE_DEBUG_PORT: $REMOTE_DEBUG_PORT"
echo 

##
# check corrent uid
#

RUNAS="tc$(basename $(pwd))"
[ -n $RUNAS ] || die "could not detect user i should run as (RUNAS variable)"

[ "$USER" = "$RUNAS" ] || die "bad user i run as (i should run as \"$RUNAS\" user)"

##
# some aditional environment variables
#

export PATH=$JAVA_HOME/bin:$PATH
export CATALINA_BASE="${TOMCAT_INSTANCE_PREFIX}/${USER#tc}"

log "$@; PATH=$PATH ; CATALINA_BASE=$CATALINA_BASE ; CATALINA_OPTS=$CATALINA_OPTS ; JAVA_HOME=$JAVA_HOME ; JAVA_OPTS=$JAVA_OPTS ; RUNAS=$RUNAS"

if [ "$1" = "start" -a "$CLEAN_WORK_DIR" = "YES" ]
then
	echo "cleaning work directory..."
	rm -rf work/*
fi

if [ "$REMOTE_DEBUG" = "YES" -a "$1" = "start" ]
then
	export JPDA_ADDRESS="$REMOTE_DEBUG_PORT"
	$CATALINA_HOME/bin/catalina.sh jpda $1 &
else
	$CATALINA_HOME/bin/catalina.sh $1 &
fi

if [ "$1" = "stop" ]
then
	sleep $TC_KILL_WAIT_SOFT
	if pgrep -f "Dtcid=${USER#tc} " > /dev/null
	then
		log "soft kill phase required"
		echo "WARN: soft kill phase required"
		pkill -u $USER -f "Dtcid=${USER#tc} "
	fi

	sleep $TC_KILL_WAIT_SOFT
	if pgrep -f "Dtcid=${USER#tc} " > /dev/null
	then
		sleep $TC_KILL_WAIT_HARD
		log "hard kill phase required"
		echo "WARN: hard kill phase required"
		pkill -9 -u $USER -f "Dtcid=${USER#tc} "
	fi
fi

echo $1 done.
