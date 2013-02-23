#!/bin/bash

tempfile="`mktemp -p /tmp rctc-runconf-diff.XXXXXX`"
tar xf /usr/lib/rctc/instance-template/rctc.tgz ./run.conf -O > "$tempfile"
diff -Nru "$tempfile" $(pwd)/run.conf

echo "INFO: file $tempfile was left on disk"
echo
echo "for easy merging with vimdiff run:"
echo "    vimdiff $tempfile $(pwd)/run.conf"
