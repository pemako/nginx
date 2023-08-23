#!/bin/bash

CURRDIR=$(dirname "$0")
BASEDIR=$(cd "$CURRDIR" || return;pwd)
NAME="openresty"
CMD=/usr/local/bin/openresty
if [ "$1" = "-d" ]; then
  shift
  EXECUTEDIR=$1
  shift
else
  EXECUTEDIR=$BASEDIR
fi

if [ ! -d "$EXECUTEDIR" ]; then
  echo "ERROR: $EXECUTEDIR is not a dir"
  exit
fi

if [ ! -d "$EXECUTEDIR"/conf ]; then
  echo "ERROR: could not find $EXECUTEDIR/conf/"
  exit
fi

if [ ! -d "$EXECUTEDIR"/logs ]; then
  mkdir "$EXECUTEDIR"/logs
fi

cd "$EXECUTEDIR" || return 

PID_FILE="$EXECUTEDIR"/logs/${NAME}.pid

check_pid() {
  STOPED=1
  if [ -f "${PID_FILE}" ]; then
    PID=$(cat "$PID_FILE")
    if [[ $(uname) == 'Darwin' ]]; then
      if vmmap "$PID" &>/dev/null; then
        STOPED=0
      fi
    else
      if ls /proc/"$PID" &>/dev/null; then
        STOPED=0
      fi
    fi
  fi
}

check_running() {
  PID=0
  check_pid
  if [ $STOPED -eq 0 ]; then
    echo "$CMD is running as $PID, we'll do nothing"
  fi
}

start() {
  check_running
  if [ $STOPED -eq 1 ]; then
    if !  "$CMD" -c "$EXECUTEDIR/conf/nginx.conf" -p "$EXECUTEDIR/"; then
      echo "nginx start fails"
      exit 1
    else
      PID=$(cat "$PID_FILE")
      echo "nginx (pid $PID) is running..."
    fi
  fi
}

stop() {
  check_pid
  if [ $STOPED -eq 0 ]; then
    if !  "$CMD" -c "$EXECUTEDIR/conf/nginx.conf" -p "$EXECUTEDIR/" -s stop; then
      echo "nginx stop fails"
      exit 1
    else
      echo "nginx shutting down is done..."
    fi
  else
    echo "nginx is not running"
  fi
}

status() {
  check_pid
  if [ $STOPED -eq 0 ]; then
    echo "nginx (pid $PID) is running ..."
  else
    echo "nginx is not running"
  fi
}

reload() {
  if ! "$CMD" -c "$EXECUTEDIR/conf/nginx.conf" -p "$EXECUTEDIR/" -t; then
    echo "test nginx conf fail. please check it first, we won't reload it"
    exit 1
  fi
  "$CMD" -c "$EXECUTEDIR/conf/nginx.conf" -p "$EXECUTEDIR/" -s reload
}

reopen() {
  "$CMD" -c "$EXECUTEDIR/conf/nginx.conf" -p "$EXECUTEDIR/" -s reopen
}

STOPED=0
case "$1" in
start)
  start
  ;;
stop)
  stop
  ;;
restart)
  stop
  sleep 1
  start
  ;;
status)
  status
  ;;
reload)
  reload
  ;;
reopen)
  reopen
  ;;
*)
  echo "Usage: $0 {start|stop|restart|status|reload|reopen}"
  exit 1
  ;;
esac

exit 0
