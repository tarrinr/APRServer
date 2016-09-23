#!/bin/bash

run=$(ps -ef | grep APRS2MySQL.pl | grep -v grep)
if [ -z "$run" ]; then
perl /home/APRS/APRS2MySQL.pl >> /home/APRS/aprs.log 2>&1 &
echo "Restarted APRS2MySQL.pl $(date)" >> /home/APRS/aprs.log
fi

run=$(ps -ef | grep SPOT2MySQL.pl | grep -v grep)
if [ -z "$run" ]; then
perl /home/APRS/SPOT2MySQL.pl >> /home/APRS/spot.log 2>&1 &
echo "Restarted SPOT2MySQL.pl $(date)" >> /home/APRS/spot.log
fi

