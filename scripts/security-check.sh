#!/bin/bash
# Security Toolkit - Main Security Scanner
# Comprehensive security check with AI-ready output
# System: rob-Latitude-5430 (Ubuntu 24.04.3 LTS)
# Last updated: 2025-12-09

LOG="/var/log/security-check.log"
DATE=$(date "+%Y-%m-%d %H:%M:%S")
HOSTNAME=$(hostname)

# Set up environment for tools that need user context (kubectl, etc.)
# This allows the script to work both as root and as regular user
REAL_USER=${SUDO_USER:-$(whoami)}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
export KUBECONFIG="${REAL_HOME}/.kube/config"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG")"

# Generate current security state
echo "=== SECURITY CHECK $DATE ==="
echo "=== SECURITY CHECK $DATE ===" > $LOG
echo "Hostname: $HOSTNAME" >> $LOG
echo "" >> $LOG

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
echo "" >> $LOG

# === NEW CHECKS FOR THIS SYSTEM ===

echo "Checking Docker container health..."
echo "Docker Container Status:" >> $LOG
if command -v docker >/dev/null 2>&1; then
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" >> $LOG 2>&1

    # Check for unhealthy or restarting containers
    UNHEALTHY=$(docker ps --filter "health=unhealthy" --format "{{.Names}}" 2>/dev/null)
    RESTARTING=$(docker ps --filter "status=restarting" --format "{{.Names}}" 2>/dev/null)

    if [[ -n "$UNHEALTHY" ]]; then
        echo "WARNING: Unhealthy containers: $UNHEALTHY" >> $LOG
    fi
    if [[ -n "$RESTARTING" ]]; then
        echo "WARNING: Restarting containers: $RESTARTING" >> $LOG
    fi
else
    echo "Docker not installed" >> $LOG
fi
echo "" >> $LOG

echo "Checking Kubernetes cluster status..."
echo "Kubernetes Cluster Status:" >> $LOG
if command -v kubectl >/dev/null 2>&1; then
    # Check node status
    NODE_STATUS=$(kubectl get nodes --no-headers 2>/dev/null)
    if [[ -n "$NODE_STATUS" ]]; then
        echo "$NODE_STATUS" >> $LOG

        # Check for NotReady nodes
        NOTREADY=$(echo "$NODE_STATUS" | grep -v "Ready" | grep -v "^$")
        if [[ -n "$NOTREADY" ]]; then
            echo "CRITICAL: Kubernetes nodes not ready!" >> $LOG
        fi
    else
        echo "Kubernetes cluster not accessible (k3d may be stopped)" >> $LOG
    fi
else
    echo "kubectl not installed" >> $LOG
fi
echo "" >> $LOG

echo "Checking database connectivity..."
echo "Database Connectivity:" >> $LOG

# Redis check
if command -v redis-cli >/dev/null 2>&1; then
    REDIS_PING=$(redis-cli -p 6379 PING 2>&1)
    if [[ "$REDIS_PING" == "PONG" ]]; then
        echo "Redis (port 6379): OK" >> $LOG
    elif [[ "$REDIS_PING" == *"NOAUTH"* ]]; then
        echo "Redis (port 6379): OK (requires authentication - good security)" >> $LOG
    else
        echo "WARNING: Redis (port 6379): UNREACHABLE - $REDIS_PING" >> $LOG
    fi
else
    # Try with nc if redis-cli not installed
    if nc -z localhost 6379 2>/dev/null; then
        echo "Redis (port 6379): Port open (redis-cli not installed for full check)" >> $LOG
    else
        echo "WARNING: Redis (port 6379): Port closed" >> $LOG
    fi
fi

# MongoDB check
if command -v mongosh >/dev/null 2>&1; then
    MONGO_PING=$(mongosh --port 27019 --quiet --eval "db.adminCommand('ping')" 2>/dev/null | grep -o '"ok" : 1')
    if [[ -n "$MONGO_PING" ]]; then
        echo "MongoDB (port 27019): OK" >> $LOG
    else
        echo "WARNING: MongoDB (port 27019): UNREACHABLE" >> $LOG
    fi
else
    # Try with nc if mongosh not installed
    if nc -z localhost 27019 2>/dev/null; then
        echo "MongoDB (port 27019): Port open (mongosh not installed for full check)" >> $LOG
    else
        echo "WARNING: MongoDB (port 27019): Port closed" >> $LOG
    fi
fi

# PostgreSQL check
if command -v pg_isready >/dev/null 2>&1; then
    if pg_isready -h localhost -p 5441 >/dev/null 2>&1; then
        echo "PostgreSQL (port 5441): OK" >> $LOG
    else
        echo "WARNING: PostgreSQL (port 5441): UNREACHABLE" >> $LOG
    fi
else
    # Try with nc if pg_isready not installed
    if nc -z localhost 5441 2>/dev/null; then
        echo "PostgreSQL (port 5441): Port open (pg_isready not installed for full check)" >> $LOG
    else
        echo "WARNING: PostgreSQL (port 5441): Port closed" >> $LOG
    fi
fi
echo "" >> $LOG

echo "Checking monitoring stack..."
echo "Monitoring Stack Status:" >> $LOG

# Node exporter check (port 9100)
if curl -s --max-time 2 http://localhost:9100/metrics >/dev/null 2>&1; then
    echo "Node Exporter (port 9100): OK" >> $LOG
else
    echo "INFO: Node Exporter (port 9100): Not responding (may run inside k3d)" >> $LOG
fi

# Check if Prometheus/Grafana pods are running in k3d
if command -v kubectl >/dev/null 2>&1; then
    PROM_PODS=$(kubectl get pods -A 2>/dev/null | grep -E "(prometheus|grafana)" | head -5)
    if [[ -n "$PROM_PODS" ]]; then
        echo "Kubernetes monitoring pods:" >> $LOG
        echo "$PROM_PODS" >> $LOG
    fi
fi
echo "" >> $LOG

echo "=== SECURITY CHECK COMPLETE ==="
echo "Results saved to: $LOG"
