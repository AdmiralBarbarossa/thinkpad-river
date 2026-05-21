#!/bin/bash
RICEDIR="${RICEDIR:-$HOME/.config}"

if pgrep -x swayidle > /dev/null; then
    pkill -x swayidle
    notify-send -t 1500 "Idle inhibited"
else
    swayidle -w -C "$RICEDIR/swayidle/config" &
    notify-send -t 1500 "Idle enabled"
fi
