#!/bin/bash
echo "INFO: running as nonprivileged user, wrapping with sudo..."
sudo /usr/sbin/rctc "$@"

