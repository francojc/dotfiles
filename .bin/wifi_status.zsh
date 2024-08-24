#!/usr/bin/env bash

# Get SSID of the connected network
SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep ' SSID:' | cut -d ':' -f 2 | tr -d ' ')

# Get the signal strength (RSSI)
RSSI=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep ' agrCtlRSSI:' | cut -d ':' -f 2 | tr -d ' ')

# Convert RSSI to emoji
if [[ $RSSI -ge -50 ]]; then
    SIGNAL="📶"  # Strong
elif [[ $RSSI -ge -65 ]]; then
    SIGNAL="📶"  # Good
elif [[ $RSSI -ge -75 ]]; then
    SIGNAL="📶"  # Fair
else
    SIGNAL="📶"  # Weak
fi

# Print SSID and signal strength as emoji
echo "Connected to: $SSID"
echo "Signal Strength: $SIGNAL"
