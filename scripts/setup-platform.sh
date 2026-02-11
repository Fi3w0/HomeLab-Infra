#!/bin/bash

# HomeLab-Infra Platform Setup Script
# Initializes the platform with proper directory structure and permissions

set -e

echo "=== HomeLab-Infra Platform Setup ==="
echo "Platform: Ryzen 5 7430U (12 vCPUs, 16GB RAM)"
echo "Purpose: Server-Side Infrastructure as Code"
echo ""

# Check Docker installation
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   Visit: https://docs.docker.com/engine/install/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose."
    echo "   Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"

# Create directory structure
echo ""
echo "Creating directory structure..."
mkdir -p /backup/minecraft
mkdir -p docker/pixelmon/data
mkdir -p docker/atm10/data
mkdir -p docker/vanilla/data
mkdir -p docker/test_paper/data
mkdir -p docker/test_fabric/data
mkdir -p /var/log/homelab

echo "✅ Directory structure created"

# Set permissions
echo ""
echo "Setting permissions..."
sudo chown -R $USER:$USER /backup/minecraft
sudo chown -R $USER:$USER /var/log/homelab
chmod 755 /backup/minecraft
chmod 755 /var/log/homelab

echo "✅ Permissions configured"

# Create environment template
echo ""
echo "Creating environment configuration..."
if [ ! -f .env ]; then
    cat > .env.example << 'EOF'
# HomeLab-Infra Environment Configuration
# DO NOT COMMIT THIS FILE - Use .env for actual values

# === Service Ports ===
PORTAINER_PORT=9000
FIW_SMPWEB_PORT=8080
PIXELMON_PORT=25565
ATM10_PORT=25566
VANILLA_PORT=25567
TEST_PAPER_PORT=25568
TEST_FABRIC_PORT=25569

# === Minecraft RCON Passwords ===
PIXELMON_RCON_PASSWORD=secure_pixelmon_rcon_$(openssl rand -hex 8)
ATM10_RCON_PASSWORD=secure_atm10_rcon_$(openssl rand -hex 8)
VANILLA_RCON_PASSWORD=secure_vanilla_rcon_$(openssl rand -hex 8)
TEST_PAPER_RCON_PASSWORD=secure_test_paper_$(openssl rand -hex 8)
TEST_FABRIC_RCON_PASSWORD=secure_test_fabric_$(openssl rand -hex 8)

# === Resource Limits ===
MAX_CONCURRENT_MC_SERVERS=2
PIXELMON_MEMORY=6G
ATM10_MEMORY=10G
VANILLA_MEMORY=4G
TEST_PAPER_MEMORY=2G
TEST_FABRIC_MEMORY=8G

# === Backup Configuration ===
BACKUP_DIR=/backup/minecraft
BACKUP_RETENTION_DAYS=7
BACKUP_COMPRESSION=gzip

# === Network Configuration ===
DOCKER_NETWORK=homelab-network
EOF
    
    echo "✅ Created .env.example template"
    echo "   Copy to .env and edit with your values:"
    echo "   cp .env.example .env"
    echo "   nano .env"
else
    echo "✅ .env file already exists"
fi

# Create Docker network
echo ""
echo "Creating Docker network..."
if ! docker network ls | grep -q homelab-network; then
    docker network create homelab-network
    echo "✅ Created 'homelab-network' Docker network"
else
    echo "✅ 'homelab-network' already exists"
fi

# Setup systemd timers
echo ""
echo "Setting up systemd timers..."
if [ -d systemd ]; then
    sudo cp systemd/* /etc/systemd/system/ 2>/dev/null || true
    echo "✅ Systemd files copied (if any exist)"
else
    echo "⚠️  No systemd directory found - scheduled backups not configured"
fi

# Make scripts executable
echo ""
echo "Making scripts executable..."
chmod +x scripts/*.sh

echo "✅ Scripts are executable"

# Platform verification
echo ""
echo "=== Platform Verification ==="
echo "1. Docker status: $(docker info >/dev/null 2>&1 && echo '✅ Running' || echo '❌ Not running')"
echo "2. Backup directory: $(ls -ld /backup/minecraft >/dev/null 2>&1 && echo '✅ Exists' || echo '❌ Missing')"
echo "3. Script permissions: $(ls -la scripts/*.sh >/dev/null 2>&1 && echo '✅ Executable' || echo '❌ Issues')"
echo "4. Docker network: $(docker network ls | grep -q homelab-network && echo '✅ Created' || echo '❌ Missing')"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Configure your environment:"
echo "   cp .env.example .env"
echo "   nano .env  # Edit with your values"
echo ""
echo "2. Start the platform:"
echo "   ./scripts/start-selected.sh pixelmon atm10"
echo ""
echo "3. Verify operation:"
echo "   ./scripts/status-all.sh"
echo ""
echo "4. Monitor resources:"
echo "   docker stats"
echo ""
echo "Documentation:"
echo "  - README.md - Platform overview"
echo "  - docs/CONFIGURATION.md - Service configuration"
echo "  - docs/OPERATIONS.md - Runbook and procedures"
echo ""
echo "Platform ready for deployment! 🚀"