#!/bin/bash
find "${XDG_PICTURES_DIR:-$HOME/Pictures}" -maxdepth 1 -name "*.png" -mtime +14 -delete