#!/bin/bash
# Apply Hyperland System to an existing Arch Linux install (no reinstall).
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
exec sudo HL_OVERLAY="$REPO/overlay" HL_PACKAGES="$REPO/packages.txt" \
    bash "$REPO/overlay/usr/local/bin/hl-configure"
