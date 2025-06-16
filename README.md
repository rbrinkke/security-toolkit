# 🛡️ Security Toolkit

**Intelligent Server Security with Automated Analysis**

Automated security monitoring and analysis for Ubuntu servers using Claude AI. Simple, reliable security automation.

## ✨ Features

- 🤖 **Automated Analysis** - Claude analyzes security logs with intelligent insight
- ⏰ **Automated Scanning** - Daily security checks via cron
- 🔍 **Comprehensive Monitoring** - UFW, Fail2ban, SSH, Docker, Rootkits
- 🚀 **Instant Setup** - One-command installation
- 📊 **Smart Reporting** - Risk scoring with actionable recommendations
- 🔗 **Login Integration** - Security status shown on SSH login

## 🚀 Quick Start

```bash
# Clone and install
git clone https://github.com/rbrinkke/claude-security-toolkit.git
cd claude-security-toolkit
sudo ./install.sh
```

**Requirements:**
- Ubuntu 18.04+ (tested on 24.04 LTS)  
- Claude Code CLI (`npm install -g @anthropic-ai/claude-code`)
- Root/sudo access
- Internet connection for package installation

## 📋 What It Monitors

| Component | Tool Used | Purpose |
|-----------|-----------|---------|
| **UFW Firewall** | `ufw status` | Port access and rule validation |
| **Fail2ban** | `fail2ban-client status` | Intrusion prevention and jail status |
| **SSH Security** | `grep /var/log/auth.log` | Failed login attempts and patterns |
| **Port Scanning** | `ss -tlnp` | Unexpected open services |
| **Docker Config** | `/etc/docker/daemon.json` | Container security settings |
| **RKHunter** | `rkhunter --check` | Rootkit and malware detection |
| **System Processes** | `ps aux` | Critical security service health |

## 🎯 Usage

### Manual Commands
```bash
security-check          # Run full security scan
security-interactive    # Interactive security menu
security-login          # Get Claude AI analysis
```

### Automated Operation
- **Daily scans** at 3:00 AM (configurable)
- **Login analysis** when connecting via SSH
- **Logs stored** in `/var/log/security-check.log`

## 🧠 AI Analysis Example

```
SECURITY ANALYSIS REPORT - 2025-06-13 11:30:15

RISK LEVEL: MEDIUM (Score: 5/10)

IMMEDIATE ACTIONS REQUIRED:
- Update UFW rule: ufw allow 443/tcp
- Restart fail2ban: systemctl restart fail2ban

FINDINGS:
🔴 CRITICAL: Port 3306 exposed to internet
🟡 MEDIUM: 15 failed SSH attempts from 192.168.1.100
🟢 VERIFIED: Docker daemon security enabled

METRICS:
- Failed SSH attempts: 15
- Active Fail2ban jails: 2/3
- Open external ports: 4
- RKHunter warnings: 0

NEXT SCAN: +24h
```

## 📁 Directory Structure

```
security-toolkit/
├── scripts/
│   ├── security-check.sh           # Main security scanner
│   ├── interactive-security-check.sh # Interactive menu
│   └── login-security-check.sh     # Claude analysis wrapper
├── templates/
│   ├── claude-security-analysis.md # AI analysis prompt
│   └── security-template.json     # Security baseline configuration
├── configs/
│   └── security-cron              # Cron job definitions
├── docs/
│   └── README.md                  # This file
└── install.sh                     # One-command installer
```

## ⚙️ Configuration

### Custom Scan Schedule
Edit cron job:
```bash
sudo crontab -e
# Default: 0 3 * * * (daily at 3 AM)
```

### Custom Analysis Template
Modify the Claude prompt:
```bash
sudo nano /opt/security-toolkit/templates/security-template.json
```

### Login Hook Toggle
Enable/disable SSH login analysis:
```bash
# Enable
echo 'security-login' >> ~/.bashrc

# Disable
sed -i '/security-login/d' ~/.bashrc
```

## 🔧 Advanced Usage

### Integration with Monitoring
```bash
# Parse log for metrics (example)
grep "Failed password" /var/log/security-check.log | wc -l

# Custom integrations (modify security-check.sh)
# Add your webhook/API calls to the script
```

### Custom Security Rules
Add your own checks to `security-check.sh`:
```bash
# Example: Check custom service
echo "Checking MyApp status..." >> $LOG
systemctl is-active myapp >> $LOG 2>&1
```

## 🛠️ Troubleshooting

### Claude Analysis Not Working
```bash
# Check Claude CLI
claude --version

# Test with simple prompt
echo "Hello" | claude

# Verify template exists
ls -la /opt/security-toolkit/templates/
```

### Missing Security Tools
```bash
# Reinstall dependencies
sudo apt update
sudo apt install ufw fail2ban rkhunter net-tools
```

### Log Permission Issues
```bash
# Fix log permissions
sudo chown root:root /var/log/security-check.log
sudo chmod 644 /var/log/security-check.log
```

## 🤝 Contributing

Built with collaborative development principles - human and AI working together.

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-security`
3. Commit changes: `git commit -m 'Add amazing security feature'`
4. Push branch: `git push origin feature/amazing-security`
5. Open Pull Request

## 📜 License

MIT License - Free for all, because security should be accessible to everyone.

## 🛡️ Philosophy

Built with the principle that security should be **simple, intelligent, and accessible**.

This toolkit focuses on practical security values:
- **Automated** - Security that doesn't interrupt workflows
- **Intelligent** - AI-powered analysis with human oversight  
- **Open** - Built for the community, by the community
- **Reliable** - Always there, protecting in the background

---

**Open Source Security Intelligence**

*Reliable server protection for everyone* 🛡️