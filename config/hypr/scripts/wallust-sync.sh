#!/bin/bash

# Get current wallpaper path from swww
FILE=$(swww query | grep "image:" | awk '{print $2}')

# Run wallust on the current wallpaper
if [[ -n "$FILE" ]]; then
    wallust run "$FILE"
fi

