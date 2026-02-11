#!/bin/bash

# Stop all services
# Usage: ./stop-all.sh

set -e

echo "=== Stopping All HomeLab Services ==="
echo ""

# Stop Minecraft servers
echo "Stopping Minecraft servers..."
for server in pixelmon atm10 vanilla test_paper test_fabric; do
    if [ -f "docker/$server/docker-compose.yml" ]; then
        echo "  Stopping $server..."
        docker-compose -f "docker/$server/docker-compose.yml" down
    fi
done

# Stop web services
echo ""
echo "Stopping web services..."
if [ -f "docker/portainer/docker-compose.yml" ]; then
    echo "  Stopping Portainer..."
    docker-compose -f docker/portainer/docker-compose.yml down
fi

# Stop fiw_SMPweb if running
if docker ps --format "{{.Names}}" | grep -q "fiw-smpweb"; then
    echo "  Stopping fiw_SMPweb..."
    docker stop fiw-smpweb
    docker rm fiw-smpweb
fi

echo ""
echo "=== All Services Stopped ==="
echo ""
echo "To start services again:"
echo "  ./scripts/start-selected.sh <server1> <server2>"
echo ""
echo "Current resource usage:"
docker ps --format "table {{.Names}}\t{{.Status}}"