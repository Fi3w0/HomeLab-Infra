# HomeLab-Infra

## Infrastructure as Code (IaC) for Home Lab

**Owner:** Junior Engineer on Server-Side Platform  
**Hardware:** Ryzen 5 7430U (12 vCPUs), 16GB RAM, Ubuntu 24.04 LTS (Headless)  
**Control Center:** MacBook Air M4 (Unix-like control)  
**Core Stack:** Docker, Portainer, Systemd Timers, Bash/Fish, Minecraft (Java/Neoforge)  
**License:** MIT

## Repository Structure

```
HomeLab-Infra/
├── docker/              # Docker services and configurations
│   └── <service-name>/  # Each service in its own directory
│       └── docker-compose.yml
├── scripts/             # Maintenance and automation scripts
├── systemd/             # Systemd service and timer files
└── README.md           # This file
```

## Service Table

| Service Name | Port | Purpose | Status |
|--------------|------|---------|--------|
| Portainer | PORTAINER_HOLDER | Docker container management UI | Ready |
| Pixelmon (NeoForge) | PORT_HOLDER | Minecraft Pixelmon modpack server | Ready |
| ATM10 | PORT_HOLDER | Minecraft All The Mods 10 modpack server | Ready |
| Vanilla | PORT_HOLDER | Standard Minecraft server | Ready |
| Test Paper | PORT_HOLDER | Minecraft Paper server for testing | Ready |
| Test Fabric | PORT_HOLDER | Minecraft Fabric server for testing | Ready |
| fiw_SMPweb | 80 | Minecraft server web dashboard | Ready |

## Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Fi3w0/HomeLab-Infra.git
   ```

2. **Set up environment:**
   - Ensure Docker and Docker Compose are installed
   - Create necessary volumes and networks as specified per service

3. **Deploy services:**
   ```bash
   cd docker/<service-name>
   docker-compose up -d
   ```

## Security Notes

- **NEVER** commit real passwords, tokens, or IP addresses
- Use `PLACEHOLDER_VALUE` for sensitive information
- Store actual credentials in secure environment variables or secrets management

## Maintenance

### Available Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `backup-minecraft.sh` | Backup Minecraft server worlds | `./scripts/backup-minecraft.sh <server-name>` |
| `update-all.sh` | Update all Docker images | `./scripts/update-all.sh` |
| `status-all.sh` | Check status of all services | `./scripts/status-all.sh` |

### Systemd Integration
- Place `.service` files in `/systemd/` for service management
- Use `.timer` files in `/systemd/` for scheduled tasks
- Example: Daily Minecraft backups via systemd timer

### Resource Management
- Minecraft servers configured with 6GB RAM each
- Monitor resource usage with `docker stats`
- Adjust `MEMORY` environment variable in docker-compose.yml as needed

## Contributing

Follow Conventional Commits format:
- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `chore:` for maintenance tasks