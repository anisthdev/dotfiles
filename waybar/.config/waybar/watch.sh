#!/bin/bash
while true; do
  pid=$(pidof waybar)
  if [ -n "$pid" ]; then
    kill -USR2 "$pid"
  else
    waybar >/dev/null 2>&1 &
  fi
  inotifywait -e modify .
done
