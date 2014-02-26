#!/usr/bin/env bash

! [[ -f "$1" && "$1" =~ \.png$ ]] && echo "Missing or bad icon" && exit 1
! [[ -d "$2" ]] && echo "Missing destination folder" && exit 1

icon="$1"
dest="${2%/}"

conv() {
    local s=$1
    local s2=$((s*2))
    convert "$icon" -thumbnail ${s}x${s} "$dest/Icon-${s}.png"
    convert "$icon" -thumbnail ${s2}x${s2} "$dest/Icon-${s}@2x.png"
}

## universal
convert "$icon" -thumbnail 120x120 "$dest/Icon-60@2x.png"
conv 76
conv 40
convert "$icon" -thumbnail 29x29 "$dest/Icon-Small.png"
convert "$icon" -thumbnail 58x58 "$dest/Icon-Small@2x.png"

## universal <= 6.1
convert "$icon" -thumbnail 57x57 "$dest/Icon.png"
convert "$icon" -thumbnail 114x114 "$dest/Icon@2x.png"

conv 72
convert "$icon" -thumbnail 50x50 "$dest/Icon-Small-50.png"
convert "$icon" -thumbnail 100x100 "$dest/Icon-Small-50@2x.png"
