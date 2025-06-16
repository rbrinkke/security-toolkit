#!/bin/bash
#
# Simpel script dat Claude 1x per dag uitvoert voor security-analyse
#
TIMESTAMP_FILE="/var/log/.claude_security_timestamp"
CHECK_INTERVAL_SECONDS=86400 # 24 uur

# Check of de laatste run meer dan 24 uur geleden was
if [ ! -f "$TIMESTAMP_FILE" ] || [ $(($(date +%s) - $(stat -c %Y "$TIMESTAMP_FILE"))) -gt $CHECK_INTERVAL_SECONDS ]; then
    echo "Starting daily Claude security analysis..."
    
    # Voer Claude uit
    claude "Compare /var/log/security-check.log against /opt/security-toolkit/templates/security-template.json and provide security assessment."
    
    # Update timestamp
    touch "$TIMESTAMP_FILE"
    
    echo "Claude analysis completed."
else
    echo "Claude security analysis already ran today. Next run scheduled in $((CHECK_INTERVAL_SECONDS - ($(date +%s) - $(stat -c %Y "$TIMESTAMP_FILE")))) seconds."
fi
