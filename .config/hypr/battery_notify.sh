#!/bin/bash

STATE_FILE="/tmp/battery_notify_state"

# Get battery status and level
BATTERY_LEVEL=$(cat /sys/class/power_supply/BAT0/capacity)
STATUS=$(cat /sys/class/power_supply/BAT0/status)

# Load last state
LAST_STATE="none"
if [ -f "$STATE_FILE" ]; then
    LAST_STATE=$(cat "$STATE_FILE")
fi

function notify() {
    notify-send "🔋 Battery Update" "$1"
}

# -------------------
# Charging: notify every +5% above 70%
# -------------------
if [[ "$STATUS" == "Charging" ]]; then
    if (( BATTERY_LEVEL >= 70 && BATTERY_LEVEL <= 100 && BATTERY_LEVEL % 5 == 0 )); then
        CURRENT_STATE="charging_$BATTERY_LEVEL"
        if [[ "$LAST_STATE" != "$CURRENT_STATE" ]]; then
            if (( BATTERY_LEVEL == 90 )); then
                notify "Battery at 90% — You can unplug the charger 🔌"
            else
                notify "Charging: Battery at $BATTERY_LEVEL%"
            fi
            echo "$CURRENT_STATE" > "$STATE_FILE"
        fi
    fi
fi

# -------------------
# Discharging: notify every -5% below 90%
# -------------------
if [[ "$STATUS" == "Discharging" ]]; then
    if (( BATTERY_LEVEL <= 90 && BATTERY_LEVEL >= 70 && BATTERY_LEVEL % 5 == 0 )); then
        CURRENT_STATE="discharging_$BATTERY_LEVEL"
        if [[ "$LAST_STATE" != "$CURRENT_STATE" ]]; then
            if (( BATTERY_LEVEL == 70 )); then
                notify "Battery at 70% — Plug in the charger 🔌"
            else
                notify "Discharging: Battery at $BATTERY_LEVEL%"
            fi
            echo "$CURRENT_STATE" > "$STATE_FILE"
        fi
    fi
fi

# -------------------
# Reset state when out of range
# -------------------
if (( BATTERY_LEVEL < 65 || BATTERY_LEVEL > 95 )); then
    echo "none" > "$STATE_FILE"
fi
