#!/bin/bash
INT="eDP-1"
EXT="DP-1"
STATE="/tmp/display-mode"

if ! wlr-randr | grep -q "^$EXT"; then
    notify-send -t 2000 "No external display connected"
    exit 0
fi

current=$(cat "$STATE" 2>/dev/null || echo "extend")

case "$current" in
    internal)
        wlr-randr --output "$INT" --off --output "$EXT" --on
        echo "external" > "$STATE"
        notify-send -t 1500 "External only"
        ;;
    external)
        wlr-randr --output "$INT" --on --scale 1.25 --mode 2880x1800@120.000 \
                  --output "$EXT" --on --same-as "$INT"
        echo "mirror" > "$STATE"
        notify-send -t 1500 "Mirror"
        ;;
    mirror)
        wlr-randr --output "$INT" --on --scale 1.25 --mode 2880x1800@120.000 \
                  --output "$EXT" --on --pos 2304,0
        echo "extend" > "$STATE"
        notify-send -t 1500 "Extend"
        ;;
    extend)
        wlr-randr --output "$INT" --on --scale 1.25 --mode 2880x1800@120.000 \
                  --output "$EXT" --off
        echo "internal" > "$STATE"
        notify-send -t 1500 "Internal only"
        ;;
esac