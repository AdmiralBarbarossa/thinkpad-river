#!/bin/bash
mkdir /tmp/slurp.lock 2>/dev/null || exit 0
sel=$(slurp)
rm -rf /tmp/slurp.lock
[ -z "$sel" ] && exit 0
grim -g "$sel" - | swappy -f -
