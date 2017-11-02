#!/bin/sh
### BEGIN INIT INFO
# Provides:          parsoid
# Required-Start:    $local_fs $network $remote_fs $syslog
# Required-Stop:     $local_fs $network $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Web service converting HTML+RDFa to MediaWiki wikitext and back
# Description:       Bidirectional conversion between HTML+RDFa and the
#					 MediaWiki flavor of wikitext in a node.js web service.
#					 See https://www.mediawiki.org/wiki/Parsoid.
### END INIT INFO

# Author: Gabriel Wicke <gwicke@wikimedia.org>

# Do NOT "set -e"

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="Parsoid HTTP service"
NAME=parsoid
SCRIPT_PATH=/usr/lib/parsoid/src/bin/server.js
DAEMON="/usr/bin/nodejs $SCRIPT_PATH"
DAEMON_ARGS=""
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

# Exit if the package is not installed
[ -e "$SCRIPT_PATH" ] || exit 0

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

# export the port and host env vars, if set
export PORT
export INTERFACE

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.2-14) to ensure that this file is present
# and status_of_proc is working.
. /lib/lsb/init-functions

#
# Function that starts the daemon/service
#
do_start()
{
	# up the number of fds [sockets] from 1024
	ulimit -n 64000

	# Return
	#   0 if daemon has been started
	#   1 if daemon was already running
	#   2 if daemon could not be started

	# calling /bin/sh is a hack needed to get output redirection on Ubuntu
	# 12.04 LTS, see below
	start-stop-daemon --start --quiet --pidfile $PIDFILE -bm \
		-c parsoid:parsoid --test \
		--exec /bin/sh -- \
		-c "$DAEMON $DAEMON_ARGS >> /var/log/parsoid/parsoid.log 2>&1" \
		|| return 1
	start-stop-daemon --start --quiet --pidfile $PIDFILE -bm \
		-c parsoid:parsoid \
		--exec /bin/sh -- \
		-c "$DAEMON $DAEMON_ARGS >> /var/log/parsoid/parsoid.log 2>&1" \
		|| return 2
	echo "Started Parsoid server on port $PORT"

	# Cleaner version of the above, but does not work with Ubuntu 12.04
	# LTS as the --no-close parameter is not yet supported there
	#start-stop-daemon --start --quiet --pidfile $PIDFILE -bm --no-close \
	#	-c parsoid:parsoid \
	#	--exec $DAEMON -- $DAEMON_ARGS >> /var/log/parsoid/parsoid.log 2>&1 \
	#	|| return 2


	# Add code here, if necessary, that waits for the process to be ready
	# to handle requests from services started subsequently which depend
	# on this one.  As a last resort, sleep for some time.
    sleep 5
}

#
# Function that stops the daemon/service
#
do_stop()
{
	# Return
	#   0 if daemon has been stopped
	#   1 if daemon was already stopped
	#   2 if daemon could not be stopped
	#   other if a failure occurred
	start-stop-daemon --stop --quiet --retry=TERM/60/KILL/5 --pidfile $PIDFILE --name $NAME
	RETVAL="$?"
	[ "$RETVAL" = 2 ] && return 2
	# Wait for children to finish too if this is a daemon that forks
	# and if the daemon is only ever run from this initscript.
	# If the above conditions are not satisfied then add some other code
	# that waits for the process to drop all resources that could be
	# needed by services started subsequently.  A last resort is to
	# sleep for some time.
	start-stop-daemon --stop --quiet --oknodo --retry=0/5/KILL/5 --exec $DAEMON
	[ "$?" = 2 ] && return 2
	# Many daemons don't delete their pidfiles when they exit.
	rm -f $PIDFILE
	return "$RETVAL"
}

#
# Function that sends a SIGHUP to the daemon/service
#
do_reload() {
	#
	# If the daemon can reload its configuration without
	# restarting (for example, when it is sent a SIGHUP),
	# then implement that here.
	#
	start-stop-daemon --stop --signal 1 --quiet --pidfile $PIDFILE --name $NAME
	return 0
}

case "$1" in
  start)
	[ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
	do_start
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  stop)
	[ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
	do_stop
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  status)
	status_of_proc -p "$PIDFILE" "$NAME"
	exit $?
	;;
  #reload|force-reload)
	#
	# If do_reload() is not implemented then leave this commented out
	# and leave 'force-reload' as an alias for 'restart'.
	#
	#log_daemon_msg "Reloading $DESC" "$NAME"
	#do_reload
	#log_end_msg $?
	#;;
  restart|force-reload)
	#
	# If the "reload" option is implemented then remove the
	# 'force-reload' alias
	#
	log_daemon_msg "Restarting $DESC" "$NAME"
	do_stop
	case "$?" in
	  0|1)
		do_start
		case "$?" in
			0) log_end_msg 0 ;;
			1) log_end_msg 1 ;; # Old process is still running
			*) log_end_msg 1 ;; # Failed to start
		esac
		;;
	  *)
		# Failed to stop
		log_end_msg 1
		;;
	esac
	;;
  *)
	#echo "Usage: $SCRIPTNAME {start|stop|restart|reload|force-reload}" >&2
	echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
	exit 3
	;;
esac

:
