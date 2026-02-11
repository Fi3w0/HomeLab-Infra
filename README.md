# 🏗️ HomeLab-Infra: Server-Side Platform

**Infrastructure as Code (IaC)** for managing high-performance game servers and web services. Optimized for AMD Ryzen Zen 3 architecture and constrained memory environments.

**Platform Owner:** Junior Engineer on Server-Side Platform  
**Core Stack:** Docker, Portainer, Systemd Timers, Bash/Fish, Minecraft (Java/Neoforge)  
**License:** MIT

## 📊 Platform Resource Matrix
| Component | Specification | Role |
| :--- | :--- | :--- |
| **Host** | Ryzen 5 7430U (12 vCPUs) | Compute Node |
| **Memory** | 16GB DDR4 | **Hard Limit: Max 2 MC Servers** |
| **Storage** | 512GB NVMe | Data & Backups |
| **Control** | MacBook Air M4 | Management Console |
| **Secondary** | Thinkpad T14 (Arch Linux) | Backup Control |
| **Network** | 1Gb/s Symmetric | Edge Connectivity |

## 🌐 Network Topology
- **Edge:** Cloudflare Tunnels (HTTPS) → Porkbun DNS
- **Firewall:** UFW restricted to Ports 9000, 8080, and 25565-25569
- **Internal:** Docker Bridge Network (Isolation between Game & Web layers)
- **Security:** Zero-trust model with service isolation

## 🏗️ Repository Architecture
```
HomeLab-Infra/
├── docker/                    # Containerized Services
│   ├── pixelmon/             # NeoForge Pixelmon Server
│   ├── atm10/                # All The Mods 10 Server  
│   ├── vanilla/              # Vanilla Minecraft Server
│   ├── test_paper/           # PaperMC Test Environment
│   ├── test_fabric/          # Fabric Test Environment
│   ├── portainer/            # Docker Management UI
│   └── fiw_SMPweb/           # Server Dashboard (Dockerfile)
├── scripts/                  # Orchestration & Automation
│   ├── start-selected.sh     # Dynamic Server Rotation
│   ├── backup-minecraft.sh   # Backup Lifecycle Management
│   ├── status-all.sh         # Health Monitoring
│   ├── update-all.sh         # Container Updates
│   └── stop-all.sh          # Graceful Shutdown
├── systemd/                  # Scheduled Operations
│   ├── minecraft-backup.timer    # 2-hour Backup Schedule
│   └── minecraft-backup.service  # Backup Execution
└── docs/                     # Platform Documentation
    ├── CONFIGURATION.md      # Service Configuration
    └── OPERATIONS.md         # Runbook & Procedures
```

## 🚀 Service Orchestration

### Core Services (Always Running)
| Service | Port | Protocol | Purpose | Resource Allocation |
| :--- | :--- | :--- | :--- | :--- |
| **Portainer** | 9000 | TCP | Docker Management UI | 512MB RAM |
| **fiw_SMPweb** | 8080 | TCP | Server Dashboard | 256MB RAM |

### Game Server Environments (Rotational)
| Environment | Port | Modloader | Memory | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Pixelmon** | 25565 | NeoForge | 6GB | Pokémon Modpack Server |
| **ATM10** | 25566 | CurseForge | 10GB | All The Mods 10 Pack |
| **Vanilla** | 25567 | Paper | 4GB | Standard Minecraft |
| **Test Paper** | 25568 | Paper | 2GB | Testing Environment |
| **Test Fabric** | 25569 | Fabric | 8GB | Mod Development |

## 🎯 Orchestration & Management

### Server Rotation Logic
Due to the **16GB RAM constraint**, this platform uses a **Dynamic Rotation Strategy**. The orchestration script `scripts/start-selected.sh` ensures:

1. **Graceful Shutdown:** All non-essential game containers are stopped
2. **Memory Reclamation:** JVM Heap is fully released before new deployment
3. **Controlled Deployment:** Only two selected environments are activated
4. **Health Validation:** Services are verified before marking as operational

```bash
# Rotation Command
./scripts/start-selected.sh pixelmon atm10
```

### Backup Lifecycle
Managed via **Systemd Timers** calling `scripts/backup-minecraft.sh`:

| Aspect | Specification |
| :--- | :--- |
| **Frequency** | Every 2 hours |
| **Compression** | `.tar.gz` (LZ4 optional) |
| **Retention** | 8 rotating copies (FIFO) |
| **Storage** | `/backup/minecraft/` |
| **Verification** | MD5 checksum validation |

```bash
# Backup Schedule
systemctl enable minecraft-backup.timer
systemctl start minecraft-backup.timer
```

## ⚡ Quick Deployment

### Platform Bootstrap
```bash
# 1. Repository Clone
git clone https://github.com/Fi3w0/HomeLab-Infra.git
cd HomeLab-Infra

# 2. Environment Preparation
./scripts/setup-platform.sh  # Creates volumes, networks, directories

# 3. Service Deployment
./scripts/start-selected.sh pixelmon atm10  # Deploy with rotation logic

# 4. Monitoring Setup
./scripts/status-all.sh  # Verify platform health
```

### Configuration Management
```bash
# Copy configuration template
cp .env.example .env

# Edit environment variables
nano .env  # Set ports, passwords, resource limits

# Apply configuration
docker-compose -f docker/portainer/docker-compose.yml up -d
```

## 🔒 Security & Compliance

### Zero-Trust Architecture
- **Network Isolation:** Docker bridge networks separate game and web layers
- **Firewall Rules:** UFW restricts access to essential ports only
- **Secret Management:** Environment variables with `.env` file (excluded from Git)
- **Access Control:** SSH key-based authentication only

### Security Practices
1. **Never commit** real passwords, tokens, or IP addresses
2. Use `PLACEHOLDER_VALUE` in all configuration files
3. Store credentials in `.env` with restricted permissions (`chmod 600 .env`)
4. Regular security updates via `./scripts/update-all.sh`
5. Audit logs stored in `/var/log/homelab/`

### Compliance Checklist
- [ ] All services run as non-root users
- [ ] Network traffic encrypted (HTTPS via Cloudflare)
- [ ] Regular backup verification
- [ ] Access logs enabled and monitored
- [ ] Security patches applied within 7 days

## 🛠️ Platform Operations

### Orchestration Scripts
| Script | Purpose | Usage | Resource Impact |
| :--- | :--- | :--- | :--- |
| `start-selected.sh` | Dynamic Server Rotation | `./start-selected.sh <env1> <env2>` | Enforces 2-server limit |
| `backup-minecraft.sh` | Backup Lifecycle | `./backup-minecraft.sh <server>` | Compressed, incremental |
| `status-all.sh` | Health Monitoring | `./status-all.sh` | Read-only, no impact |
| `update-all.sh` | Container Updates | `./update-all.sh` | Requires service restart |
| `stop-all.sh` | Graceful Shutdown | `./stop-all.sh` | Releases all resources |

### Systemd Integration
```bash
# Scheduled Backups (Every 2 hours)
systemctl enable /systemd/minecraft-backup.timer
systemctl start minecraft-backup.timer

# Service Monitoring
systemctl enable homelab-monitor.service
```

### Performance Optimization
1. **JVM Tuning:** Aikar's flags for Minecraft servers
2. **Memory Management:** Swap usage monitoring and prevention
3. **Disk I/O:** NVMe optimization for world saves
4. **Network:** QoS for game traffic prioritization

## 📈 Resource Governance

### Capacity Planning
| Resource | Allocation | Utilization | Threshold |
| :--- | :--- | :--- | :--- |
| **CPU** | 12 vCPUs | ~60% peak | 85% alert |
| **Memory** | 16GB DDR4 | **Hard cap: 14GB** | 90% critical |
| **Storage** | 512GB NVMe | ~200GB used | 80% warning |
| **Network** | 1Gb/s | ~200Mb/s peak | 70% alert |

### Service Resource Matrix
| Service | RAM | CPU | Storage | Network |
| :--- | :--- | :--- | :--- | :--- |
| **Portainer** | 512MB | 0.5 vCPU | 1GB | Low |
| **fiw_SMPweb** | 256MB | 0.25 vCPU | 500MB | Medium |
| **Pixelmon** | 6GB | 2 vCPUs | 50GB | High |
| **ATM10** | 10GB | 3 vCPUs | 80GB | High |
| **Vanilla** | 4GB | 1 vCPU | 20GB | Medium |
| **Test Paper** | 2GB | 1 vCPU | 10GB | Low |
| **Test Fabric** | 8GB | 2 vCPUs | 30GB | Medium |

### Alert Thresholds
- **Memory:** >14GB total usage triggers rotation
- **CPU:** >85% sustained for 5 minutes
- **Disk:** >80% capacity triggers cleanup
- **Network:** >500Mb/s sustained traffic

## 🔄 Platform Evolution

### Change Management
All modifications follow **Conventional Commits**:
- `feat:` New service or capability
- `fix:` Bug resolution or patch
- `perf:` Performance optimization  
- `docs:` Documentation updates
- `chore:` Maintenance tasks
- `refactor:` Code restructuring

### Roadmap
| Quarter | Focus Area | Objectives |
| :--- | :--- | :--- |
| **Q1 2025** | Platform Stability | Backup automation, monitoring |
| **Q2 2025** | Performance | JVM optimization, network tuning |
| **Q3 2025** | Scalability | Load testing, resource scaling |
| **Q4 2025** | Automation | CI/CD, self-healing systems |

## 📞 Support & Monitoring

### Health Dashboard
- **Portainer:** `http://<server-ip>:9000`
- **fiw_SMPweb:** `http://<server-ip>:8080`
- **Grafana:** Planned for Q2 2025
- **Prometheus:** Resource metrics collection

### Incident Response
1. **Check status:** `./scripts/status-all.sh`
2. **Review logs:** `journalctl -u homelab-*`
3. **Resource check:** `docker stats`
4. **Backup verification:** `ls -la /backup/minecraft/`

### Contact
- **Platform Owner:** Junior Engineer (Server-Side)
- **Emergency:** SSH access via authorized keys only
- **Documentation:** [CONFIGURATION.md](CONFIGURATION.md)

---
**Platform Version:** 1.0.0  
**Last Updated:** February 2025  
**Status:** **Operational** ✅