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
| *No services configured yet* | | | |

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

- Use scripts in `/scripts/` for automated backups and maintenance
- Systemd timers in `/systemd/` handle scheduled tasks
- Regular updates and monitoring recommended

## Contributing

Follow Conventional Commits format:
- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `chore:` for maintenance tasks