#!/bin/bash
killall -9 ags gjs
while true; do
  ags run . &
  inotifywait -e modify -r .
  killall -9 ags gjs
done
