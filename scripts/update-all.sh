#!/bin/bash

# Update all Docker services
# Usage: ./update-all.sh

set -e

echo "Updating all Docker services..."

# Update Portainer
if [ -f "docker/portainer/docker-compose.yml" ]; then
    echo "Updating Portainer..."
    docker-compose -f docker/portainer/docker-compose.yml pull
    docker-compose -f docker/portainer/docker-compose.yml up -d
fi

# Update Minecraft servers (pull latest images)
for server in pixelmon atm10 vanilla test_paper test_fabric; do
    if [ -f "docker/$server/docker-compose.yml" ]; then
        echo "Updating $server..."
        docker-compose -f "docker/$server/docker-compose.yml" pull
    fi
done

echo "All services updated. Restart services if needed with:"
echo "  docker-compose -f docker/<service>/docker-compose.yml up -d"