#!/usr/bin/env bash
sleep_time=1
while true; do
  jupyter notebook list | sed -E 's|http://[^:]*:|http://localhost:|; s|\s+::.*$||'
  sleep "$sleep_time"
  sleep_time=$(( sleep_time * 2 ))
done
