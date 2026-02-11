#!/bin/bash

CONTAINER_NAME="neoforge"

echo "Minecraft console for container '$CONTAINER_NAME'. Type commands or 'exit' to quit."

while true; do
    read -p "> " CMD
    if [[ "$CMD" == "exit" ]]; then
        break
    fi
    if [[ -z "$CMD" ]]; then
        continue
    fi
    docker exec $CONTAINER_NAME rcon-cli "$CMD"
done
