#!/bin/bash

# Backup script for Minecraft servers
# Usage: ./backup-minecraft.sh <server-name>

set -e

SERVER_NAME="$1"
BACKUP_DIR="/backup/minecraft"
DATE=$(date +%Y%m%d_%H%M%S)

if [ -z "$SERVER_NAME" ]; then
    echo "Usage: $0 <server-name>"
    echo "Available servers: pixelmon, atm10, vanilla, test_paper, test_fabric"
    exit 1
fi

echo "Backing up Minecraft server: $SERVER_NAME"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Stop the server
echo "Stopping $SERVER_NAME server..."
docker-compose -f "docker/$SERVER_NAME/docker-compose.yml" down

# Create backup archive
BACKUP_FILE="$BACKUP_DIR/${SERVER_NAME}_${DATE}.tar.gz"
echo "Creating backup: $BACKUP_FILE"
tar -czf "$BACKUP_FILE" -C "docker/$SERVER_NAME" .

# Start the server
echo "Starting $SERVER_NAME server..."
docker-compose -f "docker/$SERVER_NAME/docker-compose.yml" up -d

echo "Backup completed: $BACKUP_FILE"

# Clean old backups (keep last 7 days)
find "$BACKUP_DIR" -name "${SERVER_NAME}_*.tar.gz" -mtime +7 -delete
echo "Old backups cleaned"