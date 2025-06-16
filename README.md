# 🛡️  Security Toolkit

**Automated Security Monitoring with AI Analysis**

## What This Does

This toolkit runs automated security scans on your Linux server every night and uses Claude AI to analyze the results when you log in via SSH. You get an instant security assessment based on YOUR custom prompt template.

The principle is simple: any log file can be analyzed by Claude using a prompt you write. This toolkit automates that process specifically for security logs - the nightly script collects all security data, and Claude analyzes it according to your instructions when you log in.

### Security Flow

```
Night: Security scan → Log generation → SSH Login: Analysis trigger → Security report
```

**The Process:**

1. **Automated Security Collection**
   - Nightly script at 3 AM scans your entire server
   - Checks firewall, ports, SSH attempts, rootkits, services
   - Saves everything to `/var/log/security-check.log`

2. **Login Analysis** 
   - SSH login triggers analysis (max 1x daily via timestamp check)
   - Your prompt template tells the AI what to analyze
   - Results appear instantly in your terminal

3. **Custom Prompt Template**
   - YOU write the security baseline in `security-template.json`
   - YOU define what's normal vs abnormal for your server
   - YOU control the output format and focus areas

The principle: it's automated log analysis with AI. The nightly script collects data, your prompt defines the analysis, and you see results when you log in.

## 🎯 What You Get

When you log in to your server, Claude analyzes your security status and shows you exactly what matters. Here's an example of what you might see:

```
> Compare /var/log/security-check.log against /etc/security-template.json and provide security assessment.

STATUS: WARNING

• Stale RKHunter Warning: The file '/usr/bin/lynx' exists but is not in the rkhunter.dat file - this is NOT in
  the acceptable warnings list and should be investigated
  
• Hidden Directory Found: RKHunter detected a hidden directory at /dev/.system/.cache - this requires
  investigation as it's not in the acceptable warnings list
  
• Unusual SSH Activity: 42 failed login attempts from IP 185.234.x.x in the last 6 hours - exceeds normal
  threshold. Consider adding to Fail2ban blacklist

The log is current (from today), UFW is active, Fail2ban is running with SSH jail, and Docker ports are properly
configured as expected.
```

Or when everything is secure:

```
STATUS: OK

No anomalies found based on the security template. All systems operating within defined baseline parameters:
• UFW firewall: Active with expected rules
• Docker containers: All on expected ports
• SSH: Minimal failed attempts (2 in 24h)
• Fail2ban: Active with sshd jail operational
• RKHunter: Only acceptable warnings present
```

## ✨ Key Benefits

- **Practical Analysis**: AI helps interpret logs and identifies what needs attention
- **Instant Awareness**: Know your security status the moment you log in
- **Clear Communication**: Get straightforward information about issues
- **Customizable**: Adapt the AI prompt to YOUR specific setup
- **Automated Monitoring**: Runs checks while you sleep

This toolkit combines automated security scanning with AI analysis to give you a clear picture of your server's security status.

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
git clone https://github.com/rbrinkke/security-toolkit.git
cd security-toolkit
sudo ./install.sh
```

### Requirements

- Linux-based system (tested on Ubuntu 18.04+, 24.04 LTS)
- Claude CLI (`npm install -g @anthropic-ai/claude`)
- Root/sudo access
- Internet connection for package installation

## 📋 How It Works

The AI Security Toolkit uses an **AI prompt template** (`security-template.json`) that instructs Claude how to analyze your security logs. This is NOT a configuration file - it's a structured prompt that tells Claude:

- What your specific security setup looks like
- What to consider normal vs abnormal
- How to prioritize findings
- What format to use for reporting

### Example Prompt Template Structure

The `security-template.json` contains a complete AI prompt with:

1. **Analysis Instructions** - Claude's role and analysis steps
2. **System Context** - Description of YOUR security setup
3. **Analysis Rules** - What to focus on vs ignore

> **💡 Key Point**: This is a PROMPT for Claude AI, not a config file. You're literally telling Claude in natural language what your security baseline is and how to analyze it!

### Default Template Example

The included template assumes:
- Ubuntu server with UFW firewall
- Docker containers on various ports
- SSH with YubiKey authentication
- Fail2ban and RKHunter installed

**But you can change EVERYTHING!** Just edit the prompt to describe YOUR setup:
- Different firewall? Update the prompt
- No Docker? Remove those sections
- Different auth method? Describe it
- Custom services? Add them to the baseline

The beauty is that you're just editing a prompt in natural language - no complex configuration syntax needed!

## 🎯 Usage

### Manual Commands

```bash
security-check          # Run full security scan
security-interactive    # Interactive security menu
security-login          # Get Claude AI analysis
```

### Automated Operation

- Daily scans at 3:00 AM (configurable)
- Login analysis when connecting via SSH
- Logs stored in `/var/log/security-check.log`



## 📁 Directory Structure

```
security-toolkit/
├── scripts/
│   ├── security-check.sh           # Main security scanner
│   ├── interactive-security-check.sh # Interactive menu
│   └── login-security-check.sh     # Claude analysis wrapper
├── templates/
│   ├── claude-security-analysis.md # AI analysis prompt
│   └── security-template.json      # Security baseline configuration
├── configs/
│   └── security-cron               # Cron job definitions
├── docs/
│   └── README.md                   # This file
└── install.sh                      # One-command installer
```

## ⚙️ Configuration

### Custom Scan Schedule

```bash
sudo crontab -e
# Default: 0 3 * * * (daily at 3 AM)
```

### Custom Analysis Template

```bash
sudo nano /opt/security-toolkit/templates/security-template.json
```

### Login Hook Toggle

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

Built with the principle that security should be simple, intelligent, and accessible.

This toolkit focuses on practical security values:

- **Automated** - Security that doesn't interrupt workflows
- **Intelligent** - AI-powered analysis with human oversight
- **Open** - Built for the community, by the community
- **Reliable** - Always there, protecting in the background

---

**Open Source Security Intelligence**

*Reliable server protection for everyone* 🛡️
