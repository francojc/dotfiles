#!/usr/bin/env bash

# Utility to check battery status
# Uses pmset and pretty prints the output

# Function to get battery icon based on percentage
get_battery_icon() {
    local percentage=$1
    if [ $percentage -ge 90 ]; then
        echo "󰁹"
    elif [ $percentage -ge 70 ]; then
        echo "󰂀"
    elif [ $percentage -ge 50 ]; then
        echo "󰁾"
    elif [ $percentage -ge 30 ]; then
        echo "󰁼"
    elif [ $percentage -ge 10 ]; then
        echo "󰁺"
    else
        echo "󰂎"
    fi
}

# Function to get color based on percentage
get_color() {
    local percentage=$1
    if [ $percentage -ge 70 ]; then
        echo "\033[32m"  # Green
    elif [ $percentage -ge 30 ]; then
        echo "\033[33m"  # Yellow
    else
        echo "\033[31m"  # Red
    fi
}

# Get battery information using pmset
battery_info=$(pmset -g batt)
percentage=$(echo "$battery_info" | grep -o '[0-9]*%' | tr -d '%')
status=$(echo "$battery_info" | grep -o 'AC Power\|Battery Power')
time_remaining=$(echo "$battery_info" | grep -o '[0-9:]* remaining' | awk '{print $1}')

# Determine charging status and icon
if [[ "$status" == "AC Power" ]]; then
    charging_status="Charging"
    charging_icon="󰂄"
else
    charging_status="Discharging"
    charging_icon=""
fi

# Get battery icon and color
icon=$(get_battery_icon $percentage)
color=$(get_color $percentage)
reset="\033[0m"

# Format output
output="${color}${icon} ${percentage}% ${charging_icon}${reset} "
output+="[${charging_status}]"

if [[ -n "$time_remaining" && "$time_remaining" != "0:00" ]]; then
    if [[ "$charging_status" == "Charging" ]]; then
        output+=" | Time to full: ${time_remaining}"
    else
        output+=" | Time remaining: ${time_remaining}"
    fi
fi

echo -e "$output"
