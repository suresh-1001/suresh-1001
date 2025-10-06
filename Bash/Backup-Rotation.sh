#!/bin/bash
# Simple 7-day backup rotation script
LOGDIR="/var/log/archive"
mkdir -p "$LOGDIR"
tar czf "$LOGDIR/backup_$(date +%Y%m%d).tar.gz" /var/log
find "$LOGDIR" -type f -mtime +7 -delete
