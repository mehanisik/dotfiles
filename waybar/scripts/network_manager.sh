

#!/bin/bash

# Check current network status
current=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)

# Generate list of available networks
networks=$(nmcli -t -f ssid,signal dev wifi | awk -F':' '{printf "%s (%s%%)\n", $1, $2}')

# Create a menu for network selection (using rofi or dmenu)

selected=$(echo -e "$networks" | rofi -dmenu -p "Available Networks:")

if [[ -n "$selected" ]]; then
    # Extract SSID from selection
    ssid=$(echo "$selected" | sed 's/ (.*)//')

    # Attempt to connect (assume WPA2 for simplicity)
    nmcli dev wifi connect "$ssid" password "$(rofi -dmenu -p 'Enter Password:')"
fi

# Print current network or fallback message
if [[ -n "$current" ]]; then
    echo " $current"
else
    echo "󰖪 Disconnected"
fi
