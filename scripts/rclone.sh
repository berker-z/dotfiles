#!/usr/bin/env bash

MOUNT_POINT="/home/berkerz/gDrive"
LOG_FILE="/home/berkerz/rclone_mount.log"
MAX_RETRIES=5
RETRY_DELAY=10

# Ensure the mount point exists
mkdir -p "$MOUNT_POINT"

# Function to attempt mounting

rclone mount drive: /home/berkerz/gDrive --daemon


# Clear the log file
> "$LOG_FILE"

# Wait for network
for i in $(seq 1 $MAX_RETRIES); do
    if ping -c 1 google.com &> /dev/null; then
        echo "Network is up" >> "$LOG_FILE"
        break
    fi
    echo "Waiting for network... (Attempt $i/$MAX_RETRIES)" >> "$LOG_FILE"
    sleep $RETRY_DELAY
done

# Attempt to mount
for i in $(seq 1 $MAX_RETRIES); do
    echo "Attempting to mount (Attempt $i/$MAX_RETRIES)" >> "$LOG_FILE"
    rclone mount drive: /home/berkerz/gDrive --daemon

    
    # Check if mount was successful
    if mountpoint -q "$MOUNT_POINT"; then
        echo "Mount successful" >> "$LOG_FILE"
        exit 0
    else
        echo "Mount failed. Retrying in $RETRY_DELAY seconds..." >> "$LOG_FILE"
        sleep $RETRY_DELAY
    fi
done

echo "Mount failed after $MAX_RETRIES attempts. Check $LOG_FILE for details." >> "$LOG_FILE"
exit 1