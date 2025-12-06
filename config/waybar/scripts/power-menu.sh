#!/usr/bin/env bash

choice=$(printf "Lock\nSuspend\nReboot\nShutdown\nLogout" | wofi --dmenu -p "Power")

case "$choice" in
  "Lock")
    # Will work after you set up hyprlock
    hyprlock 2>/dev/null
    ;;
  "Suspend")
    systemctl suspend
    ;;
  "Reboot")
    systemctl reboot
    ;;
  "Shutdown")
    systemctl poweroff
    ;;
  "Logout")
    hyprctl dispatch exit 0
    ;;
esac

