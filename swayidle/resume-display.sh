#!/bin/bash
mode=$(cat /tmp/display-mode 2>/dev/null)
[ "$mode" = "external" ] && exit 0
for i in 1 2 3 4 5; do
    wlr-randr --output eDP-1 --on --scale 1.25 --mode 2880x1800@120.000 2>/dev/null && break
    sleep 1
done
