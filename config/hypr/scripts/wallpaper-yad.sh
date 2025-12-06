#!/bin/bash

WALLDIR="$HOME/Pictures/wallpapers"
THUMBDIR="$HOME/.cache/wallthumbs"

mkdir -p "$THUMBDIR"

# Generate thumbnails if missing
for img in "$WALLDIR"/*; do
    base=$(basename "$img")
    thumb="$THUMBDIR/$base.png"

    if [[ ! -f "$thumb" ]]; then
        magick "$img" -thumbnail 300x300 "$thumb"
    fi
done

# Use YAD in icon grid mode
selection=$(yad --title="Choose Wallpaper" \
 --image-preview --width=900 --height=600 \
 --center --list --column="Image":IMG \
 $(printf '%s ' "$THUMBDIR"/*))

# Exit if nothing picked
[ -z "$selection" ] && exit 0

file=$(basename "$selection" .png)

# Apply wallpaper
hyprctl hyprpaper preload "$WALLDIR/$file"
hyprctl hyprpaper wallpaper "eDP-1,$WALLDIR/$file"

# Apply theming
wallust run "$WALLDIR/$file"
