#!/bin/bash
# Debug script to verify Bunshin test installation

echo "🔍 Bunshin Debug - Checking Installation"
echo "========================================"
echo ""

TEST_DIR="$HOME/.bunshin-test"

# Check if test directory exists
if [ ! -d "$TEST_DIR" ]; then
    echo "❌ Test directory not found: $TEST_DIR"
    echo "   Run ./test-bunshin.sh first!"
    exit 1
fi

echo "✅ Test directory exists: $TEST_DIR"
echo ""

# Check directory structure
echo "📁 Directory Structure:"
tree -L 3 "$TEST_DIR" 2>/dev/null || find "$TEST_DIR" -type f -o -type d | head -20
echo ""

# Check if layout file exists
LAYOUT_FILE="$TEST_DIR/config/layouts/claude-orchestrator.kdl"
if [ -f "$LAYOUT_FILE" ]; then
    echo "✅ Layout file exists: $LAYOUT_FILE"
    echo "   Contents:"
    cat "$LAYOUT_FILE"
else
    echo "❌ Layout file NOT found: $LAYOUT_FILE"
    echo "   Looking for layout files..."
    find "$TEST_DIR" -name "*.kdl" -type f
fi
echo ""

# Check config file
CONFIG_FILE="$TEST_DIR/config/config.kdl"
if [ -f "$CONFIG_FILE" ]; then
    echo "✅ Config file exists: $CONFIG_FILE"
    echo "   Contents:"
    cat "$CONFIG_FILE"
else
    echo "❌ Config file NOT found: $CONFIG_FILE"
fi
echo ""

# Check launch script
LAUNCH_SCRIPT="$TEST_DIR/bin/bunshin-test"
if [ -f "$LAUNCH_SCRIPT" ]; then
    echo "✅ Launch script exists: $LAUNCH_SCRIPT"
    echo "   Contents:"
    cat "$LAUNCH_SCRIPT"
else
    echo "❌ Launch script NOT found: $LAUNCH_SCRIPT"
fi
echo ""

# Check Zellij binary
ZELLIJ_BIN="$TEST_DIR/bin/zellij"
if [ -f "$ZELLIJ_BIN" ]; then
    echo "✅ Zellij binary exists: $ZELLIJ_BIN"
    VERSION=$("$ZELLIJ_BIN" --version 2>&1 || echo "unknown")
    echo "   Version: $VERSION"
else
    echo "❌ Zellij binary NOT found: $ZELLIJ_BIN"
fi
echo ""

# Check plugin
PLUGIN_FILE="$TEST_DIR/plugins/bunshin.wasm"
if [ -f "$PLUGIN_FILE" ]; then
    echo "✅ Plugin exists: $PLUGIN_FILE"
    SIZE=$(ls -lh "$PLUGIN_FILE" | awk '{print $5}')
    echo "   Size: $SIZE"
else
    echo "❌ Plugin NOT found: $PLUGIN_FILE"
fi
echo ""

# Test environment variables
echo "🔍 Testing environment setup..."
export ZELLIJ_CONFIG_DIR="$TEST_DIR/config"
echo "   ZELLIJ_CONFIG_DIR=$ZELLIJ_CONFIG_DIR"
echo "   Expected layout path: $ZELLIJ_CONFIG_DIR/layouts/claude-orchestrator.kdl"

if [ -f "$ZELLIJ_CONFIG_DIR/layouts/claude-orchestrator.kdl" ]; then
    echo "   ✅ Layout file accessible via ZELLIJ_CONFIG_DIR"
else
    echo "   ❌ Layout file NOT accessible"
fi
echo ""

# Try to verify Zellij can find the layout
echo "🧪 Testing Zellij layout resolution..."
export ZELLIJ_CONFIG_DIR="$TEST_DIR/config"
"$ZELLIJ_BIN" setup --check 2>&1 || true
echo ""

echo "========================================"
echo "🏁 Debug Complete"
echo ""
echo "If layout file exists but Zellij can't find it, try:"
echo "   1. Use full path: $ZELLIJ_BIN --config $CONFIG_FILE --layout $LAYOUT_FILE"
echo "   2. Or remove 'default_layout' line from config and launch manually"
