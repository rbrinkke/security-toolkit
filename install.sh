#!/bin/bash
# AI Security Toolkit - Intelligent Server Security
# Installation script for Ubuntu servers

set -e

echo "🛡️ AI Security Toolkit Installation"
echo "====================================="
echo

# Check requirements
echo "📋 Checking requirements..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root"
   exit 1
fi

# Check Ubuntu version
if ! grep -q "Ubuntu" /etc/os-release; then
    echo "⚠️  Warning: Not Ubuntu detected. Continuing anyway..."
fi

# Check Claude Code CLI
if ! command -v claude &> /dev/null; then
    echo "❌ Claude Code CLI not found!"
    echo "💡 Install with: npm install -g @anthropic-ai/claude-code"
    exit 1
fi

echo "✅ Requirements check passed"
echo

# Install security tools if missing
echo "🔧 Installing security dependencies..."

if ! apt update -qq; then
    echo "⚠️  Warning: apt update failed, continuing anyway..."
fi

if ! apt install -y ufw fail2ban rkhunter net-tools > /dev/null 2>&1; then
    echo "⚠️  Warning: Some packages failed to install"
fi

echo "✅ Dependencies installed"
echo

# Create directories
echo "📁 Setting up toolkit structure..."

TOOLKIT_DIR="/opt/ai-security-toolkit"
mkdir -p "$TOOLKIT_DIR"/{scripts,templates,configs,logs}

# Check current directory has our files
if [[ ! -d "scripts" ]] || [[ ! -d "templates" ]] || [[ ! -d "configs" ]]; then
    echo "❌ Error: Must run from ai-security-toolkit directory"
    echo "💡 Make sure you have scripts/, templates/, and configs/ folders"
    exit 1
fi

# Copy scripts
cp scripts/* "$TOOLKIT_DIR/scripts/"
cp templates/* "$TOOLKIT_DIR/templates/"
cp configs/* "$TOOLKIT_DIR/configs/"

# Make scripts executable
chmod +x "$TOOLKIT_DIR/scripts/"*.sh

# Create symlinks for easy access
ln -sf "$TOOLKIT_DIR/scripts/security-check.sh" /usr/local/bin/security-check
ln -sf "$TOOLKIT_DIR/scripts/interactive-security-check.sh" /usr/local/bin/security-interactive
ln -sf "$TOOLKIT_DIR/scripts/login-security-check.sh" /usr/local/bin/security-login

echo "✅ Toolkit installed to $TOOLKIT_DIR"
echo

# Setup cron job
echo "⏰ Setting up automated scans..."

crontab -l > /tmp/current_cron 2>/dev/null || touch /tmp/current_cron
if ! grep -q "ai-security-toolkit" /tmp/current_cron; then
    cat "$TOOLKIT_DIR/configs/security-cron" >> /tmp/current_cron
    crontab /tmp/current_cron
    echo "✅ Daily security scans scheduled (3:00 AM)"
else
    echo "⚠️  Cron job already exists"
fi
rm -f /tmp/current_cron

echo

# Setup login hook (optional)
read -p "🔗 Add security check to SSH login? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    LOGIN_HOOK='
# AI Security Toolkit - Show security status on login
if [[ -n "$SSH_CONNECTION" ]] && [[ "$USER" == "root" ]]; then
    /opt/ai-security-toolkit/scripts/login-security-check.sh
fi'
    
    if ! grep -q "AI Security Toolkit" ~/.bashrc; then
        echo "$LOGIN_HOOK" >> ~/.bashrc
        echo "✅ Login hook added to ~/.bashrc"
    else
        echo "⚠️  Login hook already exists"
    fi
fi

echo

# Run initial scan
echo "🚀 Running initial security scan..."
"$TOOLKIT_DIR/scripts/security-check.sh"

echo
echo "🎉 AI Security Toolkit installed successfully!"
echo
echo "📚 Available commands:"
echo "   security-check          - Run full security scan"
echo "   security-interactive    - Interactive security check"
echo "   security-login          - Claude analysis of logs"
echo
echo "📊 Logs location: /var/log/security-check.log"
echo "⚙️  Config location: $TOOLKIT_DIR"
echo
echo "🛡️ Professional security automation for modern servers"