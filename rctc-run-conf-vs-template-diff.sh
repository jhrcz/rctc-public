#!/bin/bash

tempfile="`mktemp -p /tmp rctc-runconf-diff.XXXXXX`"
tar xf /usr/lib/rctc/instance-template/rctc.tgz ./run.conf -O > "$tempfile"
diff -Nru "$tempfile" run.conf

