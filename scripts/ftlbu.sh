#!/usr/bin/env bash

# Create timestamp in format YYYYMMDD_HHMMSS
timestamp=$(date +%Y%m%d_%H%M%S)

# Perform the backup
mkdir -p /home/berkerz/FTLSaves/${timestamp}
cp /home/berkerz/.local/share/FasterThanLight/ae_prof.sav /home/berkerz/FTLSaves/${timestamp}/ae_prof.sav
cp /home/berkerz/.local/share/FasterThanLight/continue.sav /home/berkerz/FTLSaves/${timestamp}/continue.sav


# Optional: Print confirmation message
notify-send "Faster Than Light" "Backup created for FTL saves."