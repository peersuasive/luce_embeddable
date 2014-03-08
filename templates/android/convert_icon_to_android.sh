#!/usr/bin/env bash

! [[ -f "$1" && "$1" =~ \.png$ ]] && echo "Missing or bad icon" && exit 1
! [[ -d "$2" ]] && echo "Missing destination folder" && exit 1

icon="$1"
r_dest="${2%/}"/res

dest="${r_dest}"/drawable-ldpi
mkdir -p "$dest"
convert "$icon" -thumbnail 384x384 "$dest/icon.png"

dest="${r_dest}"/drawable-mdpi
mkdir -p "$dest"
convert "$icon" -thumbnail 512x512 "$dest/icon.png"

dest="${r_dest}"/drawable-hdpi
mkdir -p "$dest"
convert "$icon" -thumbnail 768x768 "$dest/icon.png"

dest="${r_dest}"/drawable-xhdpi
mkdir -p "$dest"
convert "$icon" -thumbnail 1024x1024 "$dest/icon.png"
