#!/bin/bash

# This script adds an 80% opacity (0xCC) alpha channel to all 6-digit hex color
# codes in the given Mako configuration file.
#
# It only modifies #RRGGBB colors and ignores colors that already have an alpha channel (#RRGGBBAA).

set -e

MAKO_CONFIG_FILE="$HOME/.config/mako/config"
# 80% opacity in hex (0.8 * 255 = 204, which is 0xCC)
OPACITY_HEX="CC"

if [ ! -f "$MAKO_CONFIG_FILE" ]; then
  echo "Error: File not found: $MAKO_CONFIG_FILE"
  exit 1
fi

# Use sed to find all 6-digit hex codes (e.g., #RRGGBB) and append the opacity value.
# The \b word boundary is crucial to prevent matching on 8-digit codes that already have opacity.
sed -i -E "s/(#[0-9a-fA-F]{6})\b/\1${OPACITY_HEX}/g" "$MAKO_CONFIG_FILE"

