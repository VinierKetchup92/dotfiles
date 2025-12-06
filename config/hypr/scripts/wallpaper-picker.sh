#!/usr/bin/env bash

WALLDIR="$HOME/Pictures/wallpapers"
CACHE="$HOME/.cache/wallthumbs"
HYPRPAPER_SOCK="$(ls /run/user/$UID/hypr/*/ -d | head -n 1)/.hyprpaper.sock"

mkdir -p "$CACHE"

# Generate missing thumbnails
for img in "$WALLDIR"/*; do
    name=$(basename "$img")
    thumb="$CACHE/$name.png"
    if [[ ! -f "$thumb" ]]; then
        magick "$img" -thumbnail 400x225 "$thumb"
    fi
done

# Use rofi to choose
CHOICE=$(ls "$CACHE" | rofi -dmenu \
    -theme ~/.config/rofi/black-red.rasi \
    -markup-rows \
    -i \
    -p "Pick Wallpaper:" \
    -show-icons \
    -icon-theme Papirus \
    -mesg "Scroll / Search / Enter to apply")

[[ -z "$CHOICE" ]] && exit

FILE="${CHOICE%.png}"

# Apply wallpaper via hyprctl (always works)
hyprctl hyprpaper preload "eDP-1,$WALLDIR/$FILE"
sleep 0.15
hyprctl hyprpaper wallpaper "eDP-1,$WALLDIR/$FILE"

# Generate colors
wallust run "$WALLDIR/$FILE"

