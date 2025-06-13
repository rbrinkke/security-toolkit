#!/bin/bash
# Test install script without actually installing

echo "🧪 Testing AI Security Toolkit Install Flow"
echo "============================================"

# Test 1: Check if we're in right directory
echo "📁 Test 1: Directory structure check"
BASE_DIR="$(dirname "$0")"
if [[ -d "$BASE_DIR/scripts" ]] && [[ -d "$BASE_DIR/templates" ]] && [[ -d "$BASE_DIR/configs" ]]; then
    echo "✅ Directory structure OK"
    cd "$BASE_DIR" || exit 1
else
    echo "❌ Missing required directories in $BASE_DIR"
    exit 1
fi

# Test 2: Check script syntax
echo "📜 Test 2: Script syntax validation"
for script in scripts/*.sh install.sh; do
    if bash -n "$script"; then
        echo "✅ $script syntax OK"
    else
        echo "❌ $script syntax error"
        exit 1
    fi
done

# Test 3: Check required commands exist
echo "🔧 Test 3: Required commands check"
commands=(bash mkdir cp chmod ln crontab stat find grep cat)
for cmd in "${commands[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "✅ $cmd available"
    else
        echo "❌ $cmd missing"
    fi
done

# Test 4: Check Claude CLI (if available)
echo "🤖 Test 4: Claude CLI check"
if command -v claude >/dev/null 2>&1; then
    echo "✅ Claude CLI available"
    claude --version 2>/dev/null || echo "⚠️  Claude version check failed"
else
    echo "⚠️  Claude CLI not found (required for AI analysis)"
fi

echo
echo "🎉 Install flow validation complete!"
echo "💡 Run './install.sh' to proceed with actual installation"