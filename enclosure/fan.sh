#! /bin/bash
# path: /etc/init.d/fan
# usage: /etc/init.d/fan start|stop|restart

### BEGIN INIT INFO
# Provides:          fan
# Required-Start:    $all 
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: fan
### END INIT INFO

GPIO_NUM=30
TEMPERATURE_HIGH=54000
TEMPERATURE_LOW=51000
GPIO_PATH=/sys/class/gpio
READ_TEMPERATURE="/sys/class/hwmon/hwmon0/device/temp1_input"

start () {
	if [ ! -e "$GPIO_PATH/gpio$GPIO_NUM" ]
	then
		echo "$GPIO_NUM" > "$GPIO_PATH/export"
		echo out > "$GPIO_PATH/gpio$GPIO_NUM/direction"
	else
		echo "Fan is already running"
		exit 1
	fi

	while true
	do
		CURRENT_TEMPERATURE="$(<$READ_TEMPERATURE)"
		if [ "$CURRENT_TEMPERATURE" -ge "$TEMPERATURE_HIGH" ] 
			then echo 1 > "$GPIO_PATH/gpio$GPIO_NUM/value"
		elif [ "TEMPERATURE_LOW" -ge "$CURRENT_TEMPERATURE" ] 
			then
			echo 0 > "$GPIO_PATH/gpio$GPIO_NUM/value"
		fi
	sleep 1m
	done
}

stop () {
	if [ -e "$GPIO_PATH/gpio$GPIO_NUM" ]
	then
		echo 0 > "$GPIO_PATH/gpio$GPIO_NUM/value"
		echo "$GPIO_NUM" > "$GPIO_PATH/unexport"
		killall fan
	else
		echo "Fan is already off"
		exit 1
	fi
}

case "$1" in
  start)
    echo "Starting Fan"
    start &
    exit 0
    ;;
  stop)
    echo "Stopping Fan"
    stop
    exit 0
    ;;
  restart)
    echo "Restarting Fan Script"
    stop
    start
    exit 0
	;;
  *)
    echo "Usage: /etc/init.d/fan {start|stop|restart}"
    exit 1
    ;;
esac

exit 0
