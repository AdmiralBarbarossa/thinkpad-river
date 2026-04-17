#!/bin/bash
mkdir /tmp/grim.lock 2>/dev/null || exit 0
grim "$HOME/Pictures/$(date +%Y%m%d-%H%M%S).png" && notify-send -t 2000 "Screenshot saved"
rm -rf /tmp/grim.lock