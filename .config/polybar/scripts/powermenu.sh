#!/usr/bin/env bash
# Powermenu via rofi · Red Team
chosen=$(printf " Lock\n Logout\n Reboot\n Shutdown\n Suspend" \
  | rofi -dmenu -i -p "power" -theme-str 'window {width: 220px;}')

case "$chosen" in
  *Lock)     command -v betterlockscreen >/dev/null && betterlockscreen -l || loginctl lock-session ;;
  *Logout)   bspc quit ;;
  *Reboot)   systemctl reboot ;;
  *Shutdown) systemctl poweroff ;;
  *Suspend)  systemctl suspend ;;
esac
