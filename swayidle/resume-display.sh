#!/bin/bash
INT="eDP-1"
INTMODE="2880x1800@120.000"
INTSCALE="1.25"

mode=$(cat /tmp/display-mode 2>/dev/null)
[ "$mode" = "external" ] && exit 0

for i in 1 2 3 4 5; do
    wlr-randr --output "$INT" --on --scale "$INTSCALE" --mode "$INTMODE" 2>/dev/null && break
    sleep 1
done
