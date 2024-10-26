#!/bin/bash

# Create timestamp in format YYYYMMDD_HHMMSS
timestamp=$(date +%Y%m%d_%H%M%S)

# Perform the backup
mkdir /home/berkerz/FTLSaves
cp /home/berkerz/.local/share/FasterThanLight/ae_prof.sav /home/berkerz/FTLSaves/filebackup_${timestamp}.sav

# Optional: Print confirmation message
notify-send "Faster Than Light" "Backup created for FTL saves."