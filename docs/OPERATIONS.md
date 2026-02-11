# 🛠️ HomeLab-Infra Operations Runbook

## Platform Overview
**Infrastructure as Code** platform for game server management on constrained hardware (16GB RAM, Ryzen 5 7430U).

## Emergency Procedures

### Service Outage
```bash
# 1. Check platform status
./scripts/status-all.sh

# 2. Check Docker daemon
sudo systemctl status docker

# 3. Check resource usage
docker stats
free -h
df -h /

# 4. Restart services if needed
./scripts/stop-all.sh
./scripts/start-selected.sh <primary> <secondary>
```

### Memory Exhaustion (Critical)
```bash
# 1. Identify memory hog
docker stats --no-stream | sort -k3 -h -r

# 2. Force stop problematic container
docker stop <container-name>

# 3. Clear Docker cache (if needed)
docker system prune -a --volumes

# 4. Restart with rotation
./scripts/start-selected.sh <env1> <env2>
```

### Backup Failure
```bash
# 1. Check backup directory
ls -la /backup/minecraft/

# 2. Check disk space
df -h /

# 3. Manual backup
./scripts/backup-minecraft.sh <server-name>

# 4. Verify backup integrity
tar -tzf /backup/minecraft/latest_backup.tar.gz
```

## Routine Operations

### Daily Checks
```bash
# 1. Platform health
./scripts/status-all.sh

# 2. Resource monitoring
docker stats --no-stream
free -h

# 3. Backup verification
ls -lh /backup/minecraft/ | head -5

# 4. Log review
journalctl -u docker --since "24 hours ago" | tail -50
```

### Weekly Maintenance
```bash
# 1. Container updates
./scripts/update-all.sh

# 2. System updates
sudo apt update && sudo apt upgrade -y

# 3. Log rotation
sudo logrotate -f /etc/logrotate.d/homelab

# 4. Cleanup old backups
find /backup/minecraft/ -type f -mtime +30 -delete
```

### Monthly Tasks
```bash
# 1. Security audit
./scripts/security-audit.sh

# 2. Performance review
./scripts/performance-report.sh

# 3. Documentation update
git pull && git status

# 4. Password rotation
# Update .env file and restart services
```

## Deployment Procedures

### New Service Deployment
```bash
# 1. Create service directory
mkdir -p docker/new-service/

# 2. Create docker-compose.yml
nano docker/new-service/docker-compose.yml

# 3. Update configuration
# Add to .env file
# Update README.md service table

# 4. Test deployment
docker-compose -f docker/new-service/docker-compose.yml up -d

# 5. Verify operation
docker ps | grep new-service
curl http://localhost:<port>/
```

### Service Rotation
```bash
# Standard rotation (2 servers max)
./scripts/start-selected.sh pixelmon atm10

# Emergency rotation (single server)
./scripts/stop-all.sh
docker-compose -f docker/pixelmon/docker-compose.yml up -d
docker-compose -f docker/portainer/docker-compose.yml up -d
```

## Monitoring & Alerts

### Key Metrics
| Metric | Warning | Critical | Action |
| :--- | :--- | :--- | :--- |
| **Memory Usage** | >12GB | >14GB | Rotate servers |
| **CPU Usage** | >80% for 5min | >90% for 2min | Scale down |
| **Disk Usage** | >70% | >85% | Cleanup backups |
| **Network In** | >500Mb/s | >800Mb/s | QoS adjustment |

### Alert Configuration
```bash
# Create monitoring script
nano /usr/local/bin/monitor-homelab.sh

# Systemd timer for monitoring
sudo cp systemd/homelab-monitor.* /etc/systemd/system/
sudo systemctl enable homelab-monitor.timer
```

## Backup & Recovery

### Backup Schedule
- **Frequency:** Every 2 hours
- **Retention:** 8 copies (16 hours coverage)
- **Compression:** gzip (LZ4 for performance)
- **Verification:** MD5 checksums

### Recovery Procedure
```bash
# 1. Stop service
docker-compose -f docker/<service>/docker-compose.yml down

# 2. Restore backup
tar -xzf /backup/minecraft/<service>_backup.tar.gz -C docker/<service>/

# 3. Start service
docker-compose -f docker/<service>/docker-compose.yml up -d

# 4. Verify
docker ps | grep <service>
```

## Security Operations

### Access Control
```bash
# Add new SSH key
echo "ssh-rsa <public-key>" >> ~/.ssh/authorized_keys

# Revoke access
# Remove line from ~/.ssh/authorized_keys

# Audit access
last | head -20
```

### Security Updates
```bash
# Weekly security scan
sudo apt update
sudo apt list --upgradable | grep security

# Docker image updates
docker scan <image-name>
```

## Performance Tuning

### JVM Optimization
```bash
# Aikar's flags (already in docker-compose.yml)
JAVA_OPTS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200"

# Memory allocation
# Adjust MEMORY environment variable per service
```

### Network Optimization
```bash
# QoS for game traffic
sudo tc qdisc add dev eth0 root handle 1: htb default 30
sudo tc class add dev eth0 parent 1: classid 1:1 htb rate 1000mbit
sudo tc class add dev eth0 parent 1:1 classid 1:10 htb rate 800mbit priority 0
```

## Troubleshooting Guide

### Common Issues

#### Docker Container Won't Start
```bash
# Check logs
docker logs <container-name>

# Check port conflicts
sudo netstat -tulpn | grep :<port>

# Check resource limits
docker info | grep -i memory
```

#### High Memory Usage
```bash
# Identify process
docker stats --no-stream

# Check JVM heap
docker exec <container> jstat -gc <pid> 1000 5

# Adjust memory limits
# Edit docker-compose.yml MEMORY variable
```

#### Network Connectivity Issues
```bash
# Check firewall
sudo ufw status

# Check Docker network
docker network ls
docker network inspect <network-name>

# Test connectivity
curl -v http://localhost:<port>/
```

### Diagnostic Commands
```bash
# Full system check
./scripts/diagnostic-check.sh

# Resource snapshot
./scripts/resource-snapshot.sh

# Performance baseline
./scripts/performance-baseline.sh
```

## Change Management

### Procedure for Changes
1. **Document:** Update relevant documentation
2. **Test:** Deploy in test environment first
3. **Backup:** Create backup before changes
4. **Implement:** Apply changes during maintenance window
5. **Verify:** Confirm functionality post-change
6. **Monitor:** Watch for issues 24 hours post-change

### Rollback Procedure
```bash
# 1. Stop changed service
docker-compose -f docker/<service>/docker-compose.yml down

# 2. Restore from backup
cp -r docker/<service>.backup/* docker/<service>/

# 3. Restart service
docker-compose -f docker/<service>/docker-compose.yml up -d

# 4. Verify rollback
./scripts/status-all.sh
```

---
**Last Updated:** February 2025  
**Next Review:** March 2025  
**Operational Status:** ✅ Green