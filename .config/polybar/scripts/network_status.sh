#!/usr/bin/env bash

STATE_FILE="/tmp/polybar_net_state"

# If toggle argument is provided
if [ "$1" = "toggle" ]; then
    STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "status")
    if [ "$STATE" = "ip" ]; then
        echo "status" > "$STATE_FILE"
    else
        echo "ip" > "$STATE_FILE"
    fi
    
    # Signal the daemon to update immediately
    PIDS=$(pgrep -f "network_status.sh" | grep -v "$$")
    for pid in $PIDS; do
        kill -USR1 "$pid" 2>/dev/null
    done
    exit 0
fi

update_status() {
    STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "status")
    
    # Get the default route info
    ROUTE=$(ip route get 1.1.1.1 2>/dev/null)
    if [ -n "$ROUTE" ]; then
        IP=$(echo "$ROUTE" | grep -oP 'src \K\S+')
        
        if [ "$STATE" = "ip" ]; then
            echo "%{F#ff2b43}$IP%{F-}"
        else
            echo "%{F#ff2b43}online%{F-}"
        fi
    else
        # Try to find any active interface with an IP just in case there is no default route but still connected locally
        LOCAL_IP=$(ip -o -4 addr show | grep -v ' 127.' | grep -v 'lo' | awk '{print $4}' | cut -d/ -f1 | head -n 1)
        if [ -n "$LOCAL_IP" ]; then
            if [ "$STATE" = "ip" ]; then
                echo "%{F#ff2b43}$LOCAL_IP%{F-}"
            else
                echo "%{F#ff2b43}online (local)%{F-}"
            fi
        else
            echo "%{F#6b7079}offline%{F-}"
        fi
    fi
}

# Trap USR1 to update instantly
trap 'update_status' USR1

# Main loop
while true; do
    update_status
    # Sleep in background so we can interrupt it with USR1 trap immediately
    sleep 5 &
    wait $!
done
