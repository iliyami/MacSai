#!/bin/bash
# Rebuild Resources/AppIcon.icns from the 1024x1024 master icon.
#
# Usage: ./scripts/build-icon.sh
#
# The master (assets/app_icon.png) follows Apple's macOS icon grid: the
# artwork is an 824x824 rounded rect centered on a transparent 1024 canvas.
# Everything outside the rounded shape must stay transparent, or the Dock
# shows a square behind the icon (issue #248). AppIconTests checks this.
set -euo pipefail

cd "$(dirname "$0")/.."
MASTER="assets/app_icon.png"
ICONSET="$(mktemp -d)/AppIcon.iconset"
mkdir -p "$ICONSET"

for size in 16 32 128 256 512; do
    sips -z "$size" "$size" "$MASTER" --out "$ICONSET/icon_${size}x${size}.png" > /dev/null
    double=$((size * 2))
    sips -z "$double" "$double" "$MASTER" --out "$ICONSET/icon_${size}x${size}@2x.png" > /dev/null
done

iconutil -c icns "$ICONSET" -o Resources/AppIcon.icns
rm -rf "$(dirname "$ICONSET")"
echo "Wrote Resources/AppIcon.icns from $MASTER"
