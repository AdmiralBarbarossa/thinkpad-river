#!/bin/bash
RICEDIR="$(dirname "$(readlink -f "$0")")/.."
INT="eDP-1"
EXT="DP-1"
INTMODE="2880x1800@120.000"
INTSCALE="1.25"
STATE="/tmp/display-mode"

if ! wlr-randr | grep -q "^$EXT"; then
    notify-send -t 2000 "No external display connected"
    exit 0
fi

WAYBARI="$RICEDIR/waybar/config"
WAYBARE="$RICEDIR/waybar/config-ext"

restartwaybar() {
    killall waybar
    for cfg in "$@"; do waybar -c "$cfg" & done
}

current=$(cat "$STATE" 2>/dev/null || echo "extend")

case "$current" in
    internal)
        wlr-randr --output "$INT" --off --output "$EXT" --on --scale 1
        echo "external" > "$STATE"
        restartwaybar "$WAYBARE"
        notify-send -t 1500 "External only"
        ;;
    external)
        wlr-randr --output "$INT" --on --scale "$INTSCALE" --mode "$INTMODE" \
                  --output "$EXT" --on --scale 1 --pos 2304,0
        echo "extend" > "$STATE"
        restartwaybar "$WAYBARI" "$WAYBARE"
        notify-send -t 1500 "Extend"
        ;;
    extend)
        wlr-randr --output "$INT" --on --scale "$INTSCALE" --mode "$INTMODE" \
                  --output "$EXT" --off
        echo "internal" > "$STATE"
        restartwaybar "$WAYBARI"
        notify-send -t 1500 "Internal only"
        ;;
esac