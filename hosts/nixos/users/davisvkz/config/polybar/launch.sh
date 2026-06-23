#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    case $m in
      HDMI-1)
        MONITOR=$m polybar --reload MAIN & # Barra com módulo extra
        ;;
      eDP-1)
        MONITOR=$m polybar --reload ALT &
        ;;
      *)
        MONITOR=$m polybar --reload MAIN &   # Fallback pros outros monitores
        ;;
    esac
  done
else
  polybar --reload BAR_MAIN &
fi
