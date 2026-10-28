#!/bin/bash
# Inspect every shipped Mach-O, including Sparkle's framework and four helpers.
# Pass an app bundle (preferred), its main executable, or a SwiftPM executable.
# SwiftPM checks also require its menu helper and all five pinned Sparkle files.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec python3 "$SCRIPT_DIR/check-network-surface.py" "$@"
