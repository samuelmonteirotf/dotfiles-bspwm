#!/usr/bin/env bash
# Temperatura da CPU (°C) — Package id 0 do coretemp.
# Acha o hwmon do coretemp dinamicamente (a numeração muda entre boots).
for h in /sys/class/hwmon/hwmon*; do
  if [ "$(cat "$h/name" 2>/dev/null)" = "coretemp" ]; then
    t=$(cat "$h/temp1_input" 2>/dev/null)
    [ -n "$t" ] && printf "%d°C\n" "$((t / 1000))"
    exit 0
  fi
done
