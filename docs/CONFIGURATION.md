# HomeLab-Infra Configuration Guide

## Project Overview
**Personal Home Lab Project** - Infrastructure as Code for managing game servers and web services on Ryzen 5 7430U hardware.

## Hardware & Network Specifications
- **Primary Server:** Ryzen 5 7430U (12 vCPUs), 16GB RAM, Ubuntu 24.04 LTS (Headless)
- **Control Devices:** 
  - MacBook Air M4 (Primary control center)
  - Thinkpad T14 with Arch Linux (Secondary control device)
- **Storage:** 512GB total available space
- **Network:** 1Gb/s symmetric internet connection

## Service Configuration Holders

### IMPORTANT: Resource Management
- **Maximum concurrent Minecraft servers:** 2 (due to 16GB RAM limitation)
- **Always running:** Portainer + fiw_SMPweb
- **Minecraft servers:** Rotate based on usage - never run more than 2 simultaneously

### Port Configuration Table

| Service | External Port | Internal Port | Purpose | Notes |
|---------|---------------|---------------|---------|-------|
| Portainer | 9000 | 9000 | Docker management UI | Always running |
| fiw_SMPweb | 8080 | 80 | Minecraft dashboard | Always running |
| Pixelmon | 25565 | 25565 | Minecraft Pixelmon server | Use when active |
| ATM10 | 25566 | 25565 | Minecraft ATM10 server | Use when active |
| Vanilla | 25567 | 25565 | Minecraft Vanilla server | Use when active |
| Test Paper | 25568 | 25565 | Testing server | Use when testing |
| Test Fabric | 25569 | 25565 | Testing server | Use when testing |

### Password Holders Replacement

Replace these placeholders in your docker-compose.yml files:

| Service | Holder | Recommended Value | Notes |
|---------|--------|-------------------|-------|
| All Minecraft | PASSWORD_HOLDER | `secure_mc_password_123` | Use strong unique passwords |
| Portainer | PORTAINER_HOLDER | `9000:9000` | Default port mapping |

### Environment Configuration File (.env.example)

Create a `.env` file in the root directory (DO NOT COMMIT THIS FILE):

```bash
# Minecraft Server Passwords
PIXELMON_RCON_PASSWORD=secure_pixelmon_rcon_123
ATM10_RCON_PASSWORD=secure_atm10_rcon_123
VANILLA_RCON_PASSWORD=secure_vanilla_rcon_123
TEST_PAPER_RCON_PASSWORD=secure_test_paper_123
TEST_FABRIC_RCON_PASSWORD=secure_test_fabric_123

# Service Ports
PORTAINER_PORT=9000
FIW_SMPWEB_PORT=8080
PIXELMON_PORT=25565
ATM10_PORT=25566
VANILLA_PORT=25567
TEST_PAPER_PORT=25568
TEST_FABRIC_PORT=25569

# Resource Limits
MAX_CONCURRENT_MC_SERVERS=2
DEFAULT_MC_MEMORY=6G
```

### Volume Configuration
Create these directories before starting services:

```bash
# Backup directory
sudo mkdir -p /backup/minecraft
sudo chown -R $USER:$USER /backup/minecraft

# Minecraft data directories
mkdir -p docker/pixelmon/data
mkdir -p docker/atm10/data  
mkdir -p docker/vanilla/data
mkdir -p docker/test_paper/data
mkdir -p docker/test_fabric/data

# Portainer data
docker volume create portainer_data
```

### Startup Script Example
Create `start-selected.sh` to manage which Minecraft servers run:

```bash
#!/bin/bash
# start-selected.sh <server1> <server2>

if [ $# -ne 2 ]; then
    echo "Usage: $0 <minecraft-server1> <minecraft-server2>"
    echo "Example: $0 pixelmon atm10"
    exit 1
fi

# Stop all Minecraft servers first
for server in pixelmon atm10 vanilla test_paper test_fabric; do
    docker-compose -f "docker/$server/docker-compose.yml" down
done

# Start selected servers
for server in "$1" "$2"; do
    echo "Starting $server..."
    docker-compose -f "docker/$server/docker-compose.yml" up -d
done

# Always run these
docker-compose -f docker/portainer/docker-compose.yml up -d
# fiw_SMPweb would be started here when Dockerfile is built
```

### System Resource Monitoring
Check resource usage:

```bash
# View Docker resource usage
docker stats

# Check disk space
df -h /

# Monitor memory usage
free -h

# Check running processes
htop
```

### Backup Strategy
1. **Daily incremental backups** of active Minecraft servers
2. **Weekly full backups** to external storage
3. **Monthly archive** of old backups
4. Use `scripts/backup-minecraft.sh` for automated backups

### Security Notes
1. **Firewall configuration:**
   ```bash
   # Allow only necessary ports
   sudo ufw allow 9000/tcp    # Portainer
   sudo ufw allow 8080/tcp    # fiw_SMPweb
   sudo ufw allow 25565:25569/tcp  # Minecraft servers (as needed)
   sudo ufw enable
   ```

2. **Regular updates:**
   ```bash
   # Update all services weekly
   ./scripts/update-all.sh
   
   # System updates
   sudo apt update && sudo apt upgrade -y
   ```

### Troubleshooting
1. **Out of memory:** Stop one Minecraft server if running more than 2
2. **Port conflicts:** Ensure unique ports for each service
3. **Performance issues:** Monitor with `docker stats` and adjust memory limits
4. **Backup failures:** Check disk space and permissions

### Maintenance Schedule
- **Daily:** Check service status with `./scripts/status-all.sh`
- **Weekly:** Update services and run full backups
- **Monthly:** Review logs and clean old backups
- **Quarterly:** Security audit and password rotation