#!/usr/bin/env bash
# Temperatura da GPU (°C)
nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null \
  | awk '{printf "%d°C\n", $1}'
