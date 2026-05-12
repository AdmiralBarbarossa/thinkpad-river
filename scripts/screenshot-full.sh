#!/bin/bash
mkdir /tmp/grim.lock 2>/dev/null || exit 0
trap 'rm -rf /tmp/grim.lock' EXIT
SAVEDIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
grim "$SAVEDIR/$(date +%Y%m%d-%H%M%S).png" && notify-send -t 2000 "Screenshot saved"