#!/bin/bash
INT="eDP-1"
EXT="DP-1"
STATE="/tmp/display-mode"

if ! wlr-randr | grep -q "^$EXT"; then
    notify-send -t 2000 "No external display connected"
    exit 0
fi

WAYBAR_INT="$HOME/thinkpad-river/waybar/config"
WAYBAR_EXT="$HOME/thinkpad-river/waybar/config-ext"

restart_waybar() {
    killall waybar
    for cfg in "$@"; do waybar -c "$cfg" & done
}

current=$(cat "$STATE" 2>/dev/null || echo "extend")

case "$current" in
    internal)
        wlr-randr --output "$INT" --off --output "$EXT" --on --scale 1
        echo "external" > "$STATE"
        restart_waybar "$WAYBAR_EXT"
        notify-send -t 1500 "External only"
        ;;
    external)
        wlr-randr --output "$INT" --on --scale 1.25 --mode 2880x1800@120.000 \
                  --output "$EXT" --on --scale 1 --pos 2304,0
        echo "extend" > "$STATE"
        restart_waybar "$WAYBAR_INT" "$WAYBAR_EXT"
        notify-send -t 1500 "Extend"
        ;;
    extend)
        wlr-randr --output "$INT" --on --scale 1.25 --mode 2880x1800@120.000 \
                  --output "$EXT" --off
        echo "internal" > "$STATE"
        restart_waybar "$WAYBAR_INT"
        notify-send -t 1500 "Internal only"
        ;;
esac