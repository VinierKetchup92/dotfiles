#!/bin/bash

WALLDIR="$HOME/Pictures/wallpapers"
RANDOM_WALL=$(ls "$WALLDIR" | shuf -n 1)
FILE="$WALLDIR/$RANDOM_WALL"

# Hyprpaper apply
hyprctl hyprpaper preload "$FILE"
hyprctl hyprpaper wallpaper "eDP-1,$FILE"

# Wallust sync
wallust run "$FILE"

