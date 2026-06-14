#!/usr/bin/env bash
# Uso da GPU (%)
nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null \
  | awk '{printf "%2d%%\n", $1}'
