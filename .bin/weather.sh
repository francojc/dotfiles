#!/bin/bash

# Default location if none provided
LOCATION=${1:-"Winston-Salem, NC"}

# Function to get ASCII art based on weather condition
get_weather_art() {
    condition="$1"
    case "$(echo "$condition" | tr '[:upper:]' '[:lower:]')" in
        *"clear"*|*"sunny"*)
            echo "    \   /
     .-.
  ― (   ) ―
     '-'
    /   \    "
            ;;
        *"rain"*|*"drizzle"*)
            echo "     .-.
    (   ).
   (___(__)
    ' ' ' '
   ' ' ' '   "
            ;;
        *"snow"*)
            echo "     .-.
    (   ).
   (___(__)
    *  *  *
   *  *  *   "
            ;;
        *"cloud"*|*"overcast"*)
            echo "    .--.
 .-(    ).
(___.__)__) "
            ;;
        *"thunder"*|*"lightning"*)
            echo "     .-.
    (   ).
   (___(__)
  ⚡⚡⚡⚡
    ' ' '    "
            ;;
        *)
            echo "    .-.
   (   ).
  (___(__) "
            ;;
    esac
}

# ASCII art for weather dashboard
echo "
╭──────────────────────────────────╮
│        Weather Dashboard         │
╰──────────────────────────────────╯
"

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install curl first."
    exit 1
fi

# Fetch weather data
echo "Fetching weather for: $LOCATION"
echo "────────────────────────────────────"

# Using wttr.in with format specifiers
# %C: weather condition
# %t: temperature
# %h: humidity
# %w: wind
# %l: location
# %p: precipitation

# First get just the condition for ASCII art
CONDITION=$(curl -s --connect-timeout 10 "wttr.in/$LOCATION?format=%C") || {
    echo "Error: Failed to connect to weather service"
    exit 1
}
WEATHER_DATA=$(curl -s --connect-timeout 10 "wttr.in/$LOCATION?format=%l:+%C+%t\n💧Humidity:+%h\n🌪️Wind:+%w\n🌧️Precipitation:+%p") || {
    echo "Error: Failed to connect to weather service"
    exit 1
}

if [ $? -eq 0 ] && [ -n "$WEATHER_DATA" ]; then
    # Display ASCII art for the weather condition
    get_weather_art "$CONDITION"
    echo
    echo "$WEATHER_DATA" | while IFS= read -r line; do
        echo "│ $line"
    done
    echo "────────────────────────────────────"
    echo "Data from wttr.in"
else
    echo "Error: Failed to fetch weather data"
    exit 1
fi

