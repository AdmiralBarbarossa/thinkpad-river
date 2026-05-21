#!/bin/bash
RICEDIR="$(dirname "$(readlink -f "$0")")/.."

if pgrep -x swayidle > /dev/null; then
    pkill -x swayidle
    notify-send -t 1500 "Idle inhibited"
else
    swayidle -w -C "$RICEDIR/swayidle/config" &
    notify-send -t 1500 "Idle enabled"
fi
