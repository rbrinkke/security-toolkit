# Security Toolkit

Linux security monitoring + Claude AI analysis. Shell scripts + cron.

## Commands

```bash
sudo ./install.sh              # Install (requires root + Claude CLI)
./test-install.sh              # Dry-run validation
security-check                 # Collect security data
security-login                 # Claude analysis on SSH login
security-interactive           # Claude analysis (24hr throttle)
```

## Configuration

Target: `rob-Latitude-5430` Ubuntu dev workstation (NOT production!)

```
Template: /opt/security-toolkit/templates/security-template.json
Log: /var/log/security-check.log
Throttle: /var/log/.claude_security_timestamp (24hr)
Cron: 0 2 * * * (daily at 2:00 AM)
```

## What It Checks

- UFW firewall (intentionally INACTIVE - behind NAT)
- fail2ban status
- SSH auth logs
- Open ports (expected list in template)
- Docker containers
- k3d cluster status
- Database connectivity
- Monitoring stack (Prometheus/Grafana)

## Critical Gotchas

1. **Root install but Claude runs as user** - kubeconfig may not exist
2. **24-hour throttle on Claude runs** - fresh logs ≠ fresh analysis
3. **Baseline mismatch is silent** - verify template matches your system
4. **Log freshness check is mandatory** - 25+ hours triggers CRITICAL
5. **Claude CLI failure is silent** - test after install

## Baseline Template

The template defines expected state for THIS dev workstation:
- UFW inactive (intentional, behind NAT)
- All Docker ports 0.0.0.0 expected
- k3d cluster running locally
- Expected ports: 22, 5441, 6379, 6443, 8080, etc.

Edit template for different systems!
