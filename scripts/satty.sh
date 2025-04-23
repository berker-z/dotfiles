#!/usr/bin/env bash

grim -g "$(slurp)" -t ppm - | satty \
  --filename - \
  --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H%M%S').png \
  --action-on-enter save-to-clipboard \
  --copy-command "wl-copy --type image/png" \
  --early-exit \
  --save-after-copy \
  --corner-roundness 0 \
  --primary-highlighter block \
  --font-family "Iosevka Nerd Font Mono" \
  --font-style Regular
