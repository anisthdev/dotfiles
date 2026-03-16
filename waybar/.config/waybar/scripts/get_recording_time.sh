#!/bin/bash

pid=$(pgrep -x wl-screenrec)
if [ -n "$pid" ]; then
  start_time=$(ps -p "$pid" -o lstart=)
  start_seconds=$(date --date="$start_time" +%s)
  current_seconds=$(date +%s)
  duration=$((current_seconds - start_seconds))
  formatted_duration=$(date -u -d @"$duration" +%M:%S)
  dot=$(printf '\xef\x84\x91')
  echo "{\"text\": \"<span color='#FF0000' size='large'>${dot}</span>    <span font_family='SF Mono'>${formatted_duration}</span>\"}"
fi
