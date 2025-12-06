#!/bin/bash

WALLDIR="$HOME/Pictures/wallpapers"

choice=$(ls "$WALLDIR" | rofi -dmenu -i -p "Wallpaper" <<< "$(printf "RANDOM\n%s" "$(ls "$WALLDIR")")")

# Exit if nothing chosen
[ -z "$choice" ] && exit 0

# Random logic
if [[ "$choice" == "RANDOM" ]]; then
    choice=$(ls "$WALLDIR" | shuf -n 1)
fi

# Apply wallpaper
hyprctl hyprpaper preload "$WALLDIR/$choice"
hyprctl hyprpaper wallpaper "eDP-1,$WALLDIR/$choice"

# Run wallust
wallust run "$WALLDIR/$choice"
