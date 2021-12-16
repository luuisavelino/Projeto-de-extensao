#!/bin/bash
while : ; do 
	SENSOR_TEMPERATURA=$((RANDOM%35+10))
	sudo docker container exec mosquitto mosquitto_pub -h localhost -t "sensor/temperatura" -m "$SENSOR_TEMPERATURA";
	sleep 20;
done
