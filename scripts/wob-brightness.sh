#!/bin/bash
WOB_SOCK="${XDG_RUNTIME_DIR}/wob.sock"
brightnessctl set "$1" | grep -oP '(?<=\()\d+(?=%)' > "$WOB_SOCK"
