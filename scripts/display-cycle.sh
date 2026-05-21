#!/bin/bash
RICEDIR="$(dirname "$(readlink -f "$0")")/.."
if [ ! -f "$RICEDIR/river/init.local" ]; then
    notify-send -t 3000 "display-cycle: init.local not found — run install.sh first"
    exit 1
fi
source "$RICEDIR/river/init.local"
STATE="${XDG_RUNTIME_DIR:-/tmp}/display-mode"

EXTPOS=$(awk -v mode="$INTMODE" -v scale="$INTSCALE" '
    BEGIN { split(mode, a, /[x@]/); printf "%d", a[1] / scale }
')

if ! wlr-randr | grep -q "^$EXT"; then
    notify-send -t 2000 "No external display connected"
    exit 0
fi

WAYBARI="$RICEDIR/waybar/config"
WAYBARE="$RICEDIR/waybar/config-ext"

restartwaybar() {
    pkill -x waybar
    for cfg in "$@"; do waybar -c "$cfg" & done
}

current=$(cat "$STATE" 2>/dev/null || echo "extend")

case "$current" in
    internal)
        if wlr-randr --output "$INT" --off --output "$EXT" --on --scale 1; then
            echo "external" > "$STATE"
            restartwaybar "$WAYBARE"
            notify-send -t 1500 "External only"
        else
            notify-send -t 2000 "Display switch failed"
        fi
        ;;
    external)
        if wlr-randr --output "$INT" --on --scale "$INTSCALE" --mode "$INTMODE" \
                     --output "$EXT" --on --scale 1 --pos "${EXTPOS},0"; then
            echo "extend" > "$STATE"
            restartwaybar "$WAYBARI" "$WAYBARE"
            notify-send -t 1500 "Extend"
        else
            notify-send -t 2000 "Display switch failed"
        fi
        ;;
    extend)
        if wlr-randr --output "$INT" --on --scale "$INTSCALE" --mode "$INTMODE" \
                     --output "$EXT" --off; then
            echo "internal" > "$STATE"
            restartwaybar "$WAYBARI"
            notify-send -t 1500 "Internal only"
        else
            notify-send -t 2000 "Display switch failed"
        fi
        ;;
esac
