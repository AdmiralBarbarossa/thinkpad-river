#!/bin/bash
mkdir /tmp/slurp.lock 2>/dev/null || exit 0
trap 'rm -rf /tmp/slurp.lock' EXIT
sel=$(slurp)
[ -z "$sel" ] && exit 0
grim -g "$sel" - | swappy -f -
