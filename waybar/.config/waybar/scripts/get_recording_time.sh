#!/bin/bash

pid=$(pgrep -x wl-screenrec)
if [ -n "$pid" ]; then
  start_time=$(ps -p "$pid" -o lstart=)
  start_seconds=$(date --date="$start_time" +%s)
  current_seconds=$(date +%s)
  duration=$((current_seconds - start_seconds))
  formatted_duration=$(date -u -d @"$duration" +%H:%M:%S)
  echo "🔴 $formatted_duration"
fi