#!/bin/bash
WOB_SOCK="${XDG_RUNTIME_DIR}/wob.sock"

case "$1" in
    up)   pamixer -i 2 ;;
    down) pamixer -d 2 ;;
    mute) pamixer --toggle-mute ;;
esac

if [ "$(pamixer --get-mute)" = "true" ]; then
    echo 0 > "$WOB_SOCK"
else
    pamixer --get-volume > "$WOB_SOCK"
fi
