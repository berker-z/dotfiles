#!/usr/bin/env bash
# wait for pipewire to initialize
sleep 1

# find the device id (strip trailing dot)
DEVICE_ID=$(wpctl status | grep -i "Starship/Matisse HD Audio Controller \[alsa\]" | awk '{print $2}' | sed 's/\.$//')

# find the sink id (strip trailing dot)
SINK_ID=$(wpctl status | awk '/Sinks:/,/Sources:/' | grep -i "Starship/Matisse HD Audio Controller Pro" | awk '{print $3}' | sed 's/\.$//'
)



printf "DEVICE_ID: %s\n" "$DEVICE_ID"
printf "SINK_ID: %s\n" "$SINK_ID"

# set the default sink

# set profile to off
wpctl set-profile "$DEVICE_ID" 0
# suspend the device
pw-cli set-param "$DEVICE_ID" Props Suspend 1
# set profile to pro-audio
wpctl set-profile "$DEVICE_ID" 4
# resume the device
pw-cli set-param "$DEVICE_ID" Props Suspend 0

SINK_ID=$(wpctl status | awk '/Sinks:/,/Sources:/' | grep -i "Starship/Matisse HD Audio Controller Pro" | awk '{print $2}' | sed 's/\.$//'
)
printf "SINK_ID: %s\n" "$SINK_ID"
#wpctl set-default "$SINK_ID"
# toggle mute to reset the sink
#wpctl set-mute "$SINK_ID" 1
#wpctl set-mute "$SINK_ID" 0
