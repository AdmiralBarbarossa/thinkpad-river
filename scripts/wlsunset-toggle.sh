#!/bin/bash
TEMP=3200

if pgrep -x wlsunset > /dev/null; then
    pkill -x wlsunset
    notify-send -t 1500 "Night light OFF"
else
    wlsunset -t $TEMP -T 6500 -S 00:00 -s 00:01 &
    notify-send -t 1500 "Night light ON"
fi
pkill -SIGUSR1 -x waybar
