#!/bin/bash

# Start selected Minecraft servers (max 2) with always-on services
# Usage: ./start-selected.sh <server1> <server2>
# Example: ./start-selected.sh pixelmon atm10

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <minecraft-server1> <minecraft-server2>"
    echo "Available servers: pixelmon, atm10, vanilla, test_paper, test_fabric"
    echo ""
    echo "IMPORTANT: Due to 16GB RAM limitation, maximum 2 Minecraft servers can run concurrently"
    echo "Portainer and fiw_SMPweb will always run alongside selected servers"
    exit 1
fi

SERVER1="$1"
SERVER2="$2"

# Validate server names
VALID_SERVERS="pixelmon atm10 vanilla test_paper test_fabric"
if [[ ! " $VALID_SERVERS " =~ " $SERVER1 " ]] || [[ ! " $VALID_SERVERS " =~ " $SERVER2 " ]]; then
    echo "Error: Invalid server name. Valid options: $VALID_SERVERS"
    exit 1
fi

if [ "$SERVER1" = "$SERVER2" ]; then
    echo "Error: Cannot start the same server twice"
    exit 1
fi

echo "=== HomeLab Server Management ==="
echo "Primary Server: Ryzen 5 7430U (12 vCPUs, 16GB RAM)"
echo "Control Devices: MacBook Air M4 + Thinkpad T14 (Arch Linux)"
echo "Network: 1Gb/s symmetric"
echo "Storage: 512GB total"
echo ""
echo "Starting configuration:"
echo "  - Always running: Portainer + fiw_SMPweb"
echo "  - Minecraft servers: $SERVER1 + $SERVER2 (max 2 concurrent)"
echo ""

# Stop all Minecraft servers first
echo "Stopping all Minecraft servers..."
for server in $VALID_SERVERS; do
    if [ -f "docker/$server/docker-compose.yml" ]; then
        echo "  Stopping $server..."
        docker-compose -f "docker/$server/docker-compose.yml" down >/dev/null 2>&1 || true
    fi
done

# Start always-on services
echo ""
echo "Starting always-on services:"
echo "  Starting Portainer (Docker management)..."
docker-compose -f docker/portainer/docker-compose.yml up -d

echo "  Note: fiw_SMPweb requires building from Dockerfile"
echo "    To build: cd docker/fiw_SMPweb && docker build -t fiw-smpweb ."
echo "    To run: docker run -d -p 8080:80 --name fiw-smpweb fiw-smpweb"

# Start selected Minecraft servers
echo ""
echo "Starting selected Minecraft servers:"
echo "  Starting $SERVER1..."
docker-compose -f "docker/$SERVER1/docker-compose.yml" up -d

echo "  Starting $SERVER2..."
docker-compose -f "docker/$SERVER2/docker-compose.yml" up -d

echo ""
echo "=== Startup Complete ==="
echo ""
echo "Service Status:"
echo "  Portainer: http://localhost:9000"
echo "  fiw_SMPweb: http://localhost:8080 (when built)"
echo "  $SERVER1: localhost:$(get_port "$SERVER1")"
echo "  $SERVER2: localhost:$(get_port "$SERVER2")"
echo ""
echo "Resource Monitoring:"
echo "  Check resources: ./scripts/status-all.sh"
echo "  Docker stats: docker stats"
echo ""
echo "To stop all services: ./scripts/stop-all.sh"
echo ""

# Helper function to get port from docker-compose
get_port() {
    local server="$1"
    case $server in
        pixelmon) echo "25565" ;;
        atm10) echo "25566" ;;
        vanilla) echo "25567" ;;
        test_paper) echo "25568" ;;
        test_fabric) echo "25569" ;;
        *) echo "25565" ;;
    esac
}