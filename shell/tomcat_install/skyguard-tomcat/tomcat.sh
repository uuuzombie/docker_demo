#!/bin/sh
#
# /etc/init.d/tomcat7 -- startup script for the Tomcat 8 servlet engine
#
# Written by Qijun based on the script of tomcat7 of debian
#
### BEGIN INIT INFO
# Provides:          tomcat
# Required-Start:    $local_fs $remote_fs $network postgresql
# Required-Stop:     $local_fs $remote_fs $network
# Should-Start:      $named
# Should-Stop:       $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start Tomcat.
# Description:       Start the Tomcat servlet engine.
### END INIT INFO

set -e

PATH=/bin:/usr/bin:/sbin:/usr/sbin
NAME=tomcat
DESC="Tomcat servlet engine"
JVM_TMP=/tmp/tomcat7-$NAME-tmp

if [ `id -u` -ne 0 ]; then
	echo "You need root privileges to run this script"
	exit 1
fi
 
# Make sure tomcat is started with system locale
if [ -r /etc/default/locale ]; then
	. /etc/default/locale
	export LANG
fi

. /lib/lsb/init-functions

if [ -r /etc/default/rcS ]; then
	. /etc/default/rcS
fi

# Predefined environment parameter
TOMCAT_USER=tomcat
TOMCAT_GROUP=tomcat
JAVA_HOME=/usr/skyguardtools/java
JRE_HOME=$JAVA_HOME/jre
CATALINA_HOME=/opt/skyguard/tomcat
CATALINA_BASE=/opt/skyguard/tomcat

export JAVA_HOME JRE_HOME CATALINA_HOME CATALINA_BASE

# Use the Java security manager? (yes/no, default: no)
TOMCAT_SECURITY=no

# You may pass JVM startup parameters to Java here. If unset, the default
# options will be: -Djava.awt.headless=true -Xmx128m -XX:+UseConcMarkSweepGC
#
# Use "-XX:+UseConcMarkSweepGC" to enable the CMS garbage collector (improved
# response time). If you use that option and you run Tomcat on a machine with
# exactly one CPU chip that contains one or two cores, you should also add
# the "-XX:+CMSIncrementalMode" option.
JAVA_OPTS="-Djava.awt.headless=true -Xmx2048m -Xms1024m -XX:+UseConcMarkSweepGC"

# To enable remote debugging uncomment the following line.
# You will then be able to use a java debugger on port 8000.
#JAVA_OPTS="${JAVA_OPTS} -Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n"

# Java compiler to use for translating JavaServer Pages (JSPs). You can use all
# compilers that are accepted by Ant's build.compiler property.
JSP_COMPILER=javac

# Number of days to keep logfiles in /var/log/tomcat7. Default is 14 days.
#LOGFILE_DAYS=14

# If you run Tomcat on port numbers that are all higher than 1023, then you
# do not need authbind.  It is used for binding Tomcat to lower port numbers.
# NOTE: authbind works only with IPv4.  Do not enable it when using IPv6.
# (yes/no, default: no)
#AUTHBIND=no

# POLICY_CACHE="$CATALINA_BASE/conf/catalina.policy"

if [ -z "$CATALINA_TMPDIR" ]; then
	CATALINA_TMPDIR="$JVM_TMP"
fi

# Set the JSP compiler if set in the tomcat7.default file
if [ -n "$JSP_COMPILER" ]; then
	JAVA_OPTS="$JAVA_OPTS -Dbuild.compiler=\"$JSP_COMPILER\""
fi

SECURITY=""
if [ "$TOMCAT_SECURITY" = "yes" ]; then
	SECURITY="-security"
fi

# Define other required variables
CATALINA_PID="/var/run/$NAME.pid"
CATALINA_SH="$CATALINA_HOME/bin/catalina.sh"

# Look for Java Secure Sockets Extension (JSSE) JARs
if [ -z "${JSSE_HOME}" -a -r "${JAVA_HOME}/jre/lib/jsse.jar" ]; then
    JSSE_HOME="${JAVA_HOME}/jre/"
fi

catalina_sh() {
	# Escape any double quotes in the value of JAVA_OPTS
	JAVA_OPTS="$(echo $JAVA_OPTS | sed 's/\"/\\\"/g')"

	AUTHBIND_COMMAND=""
	if [ "$AUTHBIND" = "yes" -a "$1" = "start" ]; then
		JAVA_OPTS="$JAVA_OPTS -Djava.net.preferIPv4Stack=true"
		AUTHBIND_COMMAND="/usr/bin/authbind --deep /bin/bash -c "
	fi

	# Define the command to run Tomcat's catalina.sh as a daemon
	# set -a tells sh to export assigned variables to spawned shells.
	TOMCAT_SH="set -a; JAVA_HOME=\"$JAVA_HOME\"; \
		CATALINA_HOME=\"$CATALINA_HOME\"; \
		CATALINA_BASE=\"$CATALINA_BASE\"; \
		JAVA_OPTS=\"$JAVA_OPTS\"; \
		CATALINA_PID=\"$CATALINA_PID\"; \
		CATALINA_TMPDIR=\"$CATALINA_TMPDIR\"; \
		LANG=\"$LANG\"; JSSE_HOME=\"$JSSE_HOME\"; \
		cd \"$CATALINA_BASE\"; \
		\"$CATALINA_SH\" $@"

	if [ "$AUTHBIND" = "yes" -a "$1" = "start" ]; then
		TOMCAT_SH="'$TOMCAT_SH'"
	fi

	# Run the catalina.sh script as a daemon
	set +e
	touch "$CATALINA_PID" "$CATALINA_BASE"/logs/catalina.out
	chown $TOMCAT_USER "$CATALINA_PID" "$CATALINA_BASE"/logs/catalina.out
	start-stop-daemon --start -b -u "$TOMCAT_USER" -g "$TOMCAT_GROUP" \
		-c "$TOMCAT_USER" -d "$CATALINA_TMPDIR" -p "$CATALINA_PID" \
		-x /bin/bash -- -c "$AUTHBIND_COMMAND $TOMCAT_SH"
	status="$?"
	set +a -e
	return $status
}

case "$1" in
  start)
	if [ -z "$JAVA_HOME" ]; then
		log_failure_msg "no JDK found - please set JAVA_HOME"
		exit 1
	fi

	if [ ! -d "$CATALINA_BASE/conf" ]; then
		log_failure_msg "invalid CATALINA_BASE: $CATALINA_BASE"
		exit 1
	fi

	log_daemon_msg "Starting $DESC" "$NAME"

	if start-stop-daemon --test --start --pidfile "$CATALINA_PID" \
		--user $TOMCAT_USER --exec "$JRE_HOME/bin/java" \
		>/dev/null; then

		# Regenerate POLICY_CACHE file
		# umask 022
		# echo "// AUTO-GENERATED FILE from /etc/tomcat7/policy.d/" \
		# 	> "$POLICY_CACHE"
		# echo ""  >> "$POLICY_CACHE"
		# cat $CATALINA_BASE/conf/policy.d/*.policy \
		# 	>> "$POLICY_CACHE"

		# Remove / recreate JVM_TMP directory
		rm -rf "$JVM_TMP"
		mkdir -p "$JVM_TMP" || {
			log_failure_msg "could not create JVM temporary directory"
			exit 1
		}

		chown $TOMCAT_USER "$JVM_TMP"

		catalina_sh start $SECURITY

		sleep 5
        if start-stop-daemon --test --start --pidfile "$CATALINA_PID" \
			--user $TOMCAT_USER --exec "$JRE_HOME/bin/java" \
			>/dev/null; then
			if [ -f "$CATALINA_PID" ]; then
				rm -f "$CATALINA_PID"
			fi
			log_end_msg 1
		else
			log_end_msg 0
			PID="`cat $CATALINA_PID`"
			echo -17 > /proc/$PID/oom_adj
			echo 0 > /proc/$PID/oom_score			
		fi
	else
	    log_progress_msg "(already running)"
		log_end_msg 0
	fi
	;;
  stop)
	log_daemon_msg "Stopping $DESC" "$NAME"

	set +e
	if [ -f "$CATALINA_PID" ]; then 
		start-stop-daemon --stop --pidfile "$CATALINA_PID" \
			--user "$TOMCAT_USER" \
			--retry=TERM/20/KILL/5 >/dev/null
		if [ $? -eq 1 ]; then
			log_progress_msg "$DESC is not running but pid file exists, cleaning up"
		elif [ $? -eq 3 ]; then
			PID="`cat $CATALINA_PID`"
			log_failure_msg "Failed to stop $NAME (pid $PID)"
			exit 1
		fi
		rm -f "$CATALINA_PID"
		rm -rf "$JVM_TMP"
	else
		log_progress_msg "(not running)"
	fi
	log_end_msg 0
	set -e
	;;
   status)
	set +e
	start-stop-daemon --test --start --pidfile "$CATALINA_PID" \
		--user $TOMCAT_USER --exec "$JRE_HOME/bin/java" \
		>/dev/null 2>&1
	if [ "$?" = "0" ]; then

		if [ -f "$CATALINA_PID" ]; then
		    log_success_msg "$DESC is not running, but pid file exists."
			exit 1
		else
		    log_success_msg "$DESC is not running."
			exit 3
		fi
	else
		log_success_msg "$DESC is running with pid `cat $CATALINA_PID`"
	fi
	set -e
        ;;
  restart|force-reload)
	if [ -f "$CATALINA_PID" ]; then
		$0 stop
		sleep 1
	fi
	$0 start
	;;
  try-restart)
        if start-stop-daemon --test --start --pidfile "$CATALINA_PID" \
		--user $TOMCAT_USER --exec "$JRE_HOME/bin/java" \
		>/dev/null; then
		$0 start
	fi
        ;;
  *)
	log_success_msg "Usage: $0 {start|stop|restart|try-restart|force-reload|status}"
	exit 1
	;;
esac

exit 0
