#!/bin/bash
# AI Security Toolkit - Login Security Analysis
# Runs Claude analysis on latest security log

LOG_FILE="/var/log/security-check.log"
TOOLKIT_DIR="/opt/ai-security-toolkit"
TEMPLATE="$TOOLKIT_DIR/templates/claude-security-analysis.md"
CLAUDE_CMD="claude"

# Check if log exists and is recent (less than 25 hours old)
if [[ ! -f "$LOG_FILE" ]]; then
    echo "⚠️  No security log found. Run: security-check.sh"
    exit 1
fi

# Check log age
LOG_AGE=$(find "$LOG_FILE" -mmin +1500 2>/dev/null)
if [[ -n "$LOG_AGE" ]]; then
    echo "⚠️  Security log is older than 25 hours. Running fresh scan..."
    "$TOOLKIT_DIR/scripts/security-check.sh"
fi

echo "🔍 Analyzing security status with Claude..."
echo "📊 Log timestamp: $(stat -c %y "$LOG_FILE" | cut -d. -f1)"
echo

# Combine template with log data and send to Claude
{
    cat "$TEMPLATE"
    echo
    echo "## Security Log Data:"
    echo '```'
    cat "$LOG_FILE"
    echo '```'
} | "$CLAUDE_CMD"

echo
echo "💡 Tip: Run 'security-check.sh' for fresh scan anytime"