#!/bin/bash

# Variables
CONTAINER_NAME="vanilla"
RESTART_INTERVAL=$((3*60*60))  # Not used directly; countdown defines timing
WAIT_AFTER_STOP=180            # Wait 3 minutes for shutdown

# Countdown times in seconds
WARNING_TIMES=(7200 3600 1800 900 600 300 60 30 15) # 2h, 1h, 30m, 15m, 10m, 5m, 1m, 30s, 15s

while true; do
    for t in "${WARNING_TIMES[@]}"; do
        sleep $(( t < 15 ? 0 : t - 15 ))  # Sleep until 15s before next message
        # Send main warning
        if [ $t -ge 60 ]; then
            MIN=$(( t / 60 ))
            docker exec $CONTAINER_NAME rcon-cli "tellraw @a {\"text\":\"Server restarting in $MIN minute(s)!\",\"color\":\"red\"}"
        else
            docker exec $CONTAINER_NAME rcon-cli "tellraw @a {\"text\":\"Server restarting in $t second(s)!\",\"color\":\"red\"}"
        fi
    done

    # Last 15 seconds countdown (15 → 1)
    for s in $(seq 15 -1 1); do
        docker exec $CONTAINER_NAME rcon-cli "tellraw @a {\"text\":\"Server restarting in $s second(s)!\",\"color\":\"red\"}"
        sleep 1
    done

    # Stop server gracefully
    docker exec $CONTAINER_NAME rcon-cli "say Server restarting now..."
    docker exec $CONTAINER_NAME rcon-cli "stop"

    # Wait for shutdown
    sleep $WAIT_AFTER_STOP

    # Restart container
    docker compose -f /srv/mc/vanilla/docker-compose.yml up -d

    # Wait a little for server to fully start
    sleep 30

    # Notify players
    docker exec $CONTAINER_NAME rcon-cli "tellraw @a {\"text\":\"Server restarted successfully! Next restart in 3 hours.\",\"color\":\"green\"}"
done
