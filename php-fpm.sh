#!/bin/bash

PWD=$(cd $(dirname $0) || return;pwd)
START="/usr/local/sbin/php-fpm -y $PWD/conf/php-fpm.conf -c $PWD/conf/php.ini -D"

check_status() {
  PID=$(ps ux | grep "$PWD" | awk '/php-fpm.conf/ {print $2}')
  if [ -n "$PID" ]; then
    echo "php-fpm (pid $PID) is runing... "
  else
    echo "php-fpm is stopped"
  fi
}

check_start() {
  PID=$(ps ux | grep "$PWD" | awk '/php-fpm.conf/ {print $2}')
  if [ -n "$PID" ]; then
    echo "php-fpm (pid $PID) is runing... "
    exit 1
  else
    $START
    check_status
  fi
}

check_stop() {
  PID=$(ps ux | grep "$PWD" | awk '/php-fpm.conf/ {print $2}')
  if [ -z "$PID" ]; then
    echo "php-fpm is stopped"
    exit 1
  else
    kill $PID
    check_status
  fi
}

check_restart() {
  PID=$(ps ux | grep "$PWD" | awk '/php-fpm.conf/ {print $2}')
  if [ -n "$PID" ]; then
    kill "$PID"
    check_status
  fi
  $START
  check_status

}

case "$1" in
start)
  check_start
  ;;
stop)
  check_stop
  ;;
restart)
  check_restart
  ;;
status)
  check_status
  ;;
*)
  echo "Usage:$0 start|stop|restart|status"
  ;;
esac
