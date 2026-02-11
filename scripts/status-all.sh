#!/bin/bash

# Check status of all services
# Usage: ./status-all.sh

echo "=== Docker Service Status ==="
echo ""

# Check Docker daemon
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker daemon is not running"
    exit 1
fi

echo "✅ Docker daemon is running"
echo ""

# List all containers
echo "Running containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

# Check specific services
echo "Service status:"
for service_dir in docker/*/; do
    service=$(basename "$service_dir")
    if [ -f "$service_dir/docker-compose.yml" ]; then
        if docker-compose -f "$service_dir/docker-compose.yml" ps | grep -q "Up"; then
            echo "  ✅ $service: Running"
        else
            echo "  ❌ $service: Stopped"
        fi
    fi
done

echo ""
echo "System resources:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" | head -10