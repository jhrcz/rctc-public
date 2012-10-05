#!/bin/bash

current_timestamp=$(date +%Y-%m-%d)
echo "current timestamp: $current_timestamp"
echo "archived files:"

find /srv/tc/*/logs/ -maxdepth 1 -mindepth 1 -type f -iname '*.gz' | grep '\.20..-' | grep -v "$current_timestamp" | while read logfile
do
        echo "$logfile"
        mv "$logfile" "$(dirname $logfile)/logs.ARCHIVE/"
done
echo done.
