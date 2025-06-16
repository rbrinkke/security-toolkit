#!/bin/bash
# Security Toolkit - Main Security Scanner
# Comprehensive security check with AI-ready output

LOG="/var/log/security-check.log"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

# Ensure log directory exists
mkdir -p "$(dirname "$LOG")"

# Generate current security state
echo "=== SECURITY CHECK $DATE ==="
echo "=== SECURITY CHECK $DATE ===" > $LOG

echo "Checking UFW Status..."
echo "UFW Status:" >> $LOG
ufw status >> $LOG 2>&1
echo "" >> $LOG

echo "Checking Fail2ban..."
echo "Fail2ban Status:" >> $LOG  
fail2ban-client status >> $LOG 2>&1
echo "" >> $LOG

echo "Checking SSH attempts..."
echo "SSH Failed attempts (last hour):" >> $LOG
grep -a "Failed password" /var/log/auth.log | grep "$(date '+%b %d %H')" >> $LOG 2>&1 || echo "No failed attempts found" >> $LOG
echo "" >> $LOG

echo "Scanning open ports..."
echo "Open ports scan:" >> $LOG
ss -tlnp | grep "0.0.0.0" >> $LOG 2>&1
echo "" >> $LOG

echo "Checking Docker config..."
echo "Docker daemon config:" >> $LOG
if [[ -f /etc/docker/daemon.json ]]; then
    cat /etc/docker/daemon.json >> $LOG 2>&1
else
    echo "Docker daemon.json not found (default config)" >> $LOG
fi
echo "" >> $LOG

echo "Running RKHunter scan..."
echo "RKHunter warnings:" >> $LOG
if command -v rkhunter >/dev/null 2>&1; then
    rkhunter --check --report-warnings-only --skip-keypress >> $LOG 2>&1 || echo "RKHunter scan completed with warnings" >> $LOG
else
    echo "RKHunter not installed - skipping rootkit scan" >> $LOG
fi
echo "" >> $LOG

echo "Checking system processes..."
echo "System processes:" >> $LOG
ps aux | grep -E "(ssh|fail2ban|docker)" | grep -v grep >> $LOG 2>&1

echo "=== SECURITY CHECK COMPLETE ==="
echo "Results saved to: $LOG"
