#!/bin/bash
set -euo pipefail

BG_DIR="${HOME}/Documents/images/wallpapers"

# Count connected monitors
MONCOUNT=$(xrandr --query | grep -w "connected" | wc -l)

# Sanity check
(( MONCOUNT > 0 )) || exit 0

# Read random images into an array
mapfile -t files < <(
  find "$BG_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) \
  | shuf -n "$MONCOUNT"
)

# Defensive check: do we actually have enough images?
(( ${#files[@]} == MONCOUNT )) || exit 1

# Apply wallpapers (one per monitor, order matters)
feh --no-fehbg --bg-fill "${files[@]}" >/dev/null 2>&1
