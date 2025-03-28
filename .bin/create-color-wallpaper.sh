#!/usr/bin/env bash

# Use magick to create a set of solid-color wallpaper backgrounds and adds the wallpaper
# files to the current directory. The colors
# are read in hex format (e.g. #FF0000) from
# a piped list.
# Requires ImageMagick.
# Usage: create-color-wallpaper.sh < colors.txt
#
# colors.txt should be a list of colors in hex format, one per line.

while read color; do
    magick -size 1920x1080 xc:"${color}" "color-${color}.png"
done

# End of create-color-wallpaper.sh
