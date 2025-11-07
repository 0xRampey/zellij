#!/bin/bash
# Diagnostic script to check Bunshin installation

TEST_DIR="$HOME/.bunshin-test"

echo "🔍 Bunshin Diagnostic Report"
echo "============================"
echo ""

# 1. Check config.kdl content
echo "1️⃣  Config file content:"
echo "---"
if [ -f "$TEST_DIR/config/config.kdl" ]; then
    cat "$TEST_DIR/config/config.kdl"
else
    echo "❌ Config file not found!"
fi
echo ""

# 2. Check if plugin path was replaced
echo "2️⃣  Plugin path check:"
if grep -q "PLUGIN_PATH" "$TEST_DIR/config/config.kdl" 2>/dev/null; then
    echo "❌ PLUGIN_PATH placeholder NOT replaced!"
    echo "   Found in config:"
    grep "PLUGIN_PATH" "$TEST_DIR/config/config.kdl"
else
    echo "✅ Plugin path appears to be replaced"
    grep "file:" "$TEST_DIR/config/config.kdl" || echo "   (no file: references found)"
fi
echo ""

# 3. Check if plugin exists
echo "3️⃣  Plugin file check:"
PLUGIN_FILE="$TEST_DIR/plugins/bunshin.wasm"
if [ -f "$PLUGIN_FILE" ]; then
    echo "✅ Plugin exists: $PLUGIN_FILE"
    ls -lh "$PLUGIN_FILE"
else
    echo "❌ Plugin NOT found: $PLUGIN_FILE"
fi
echo ""

# 4. Check if layout block exists in config
echo "4️⃣  Layout block check:"
if grep -q "^layout {" "$TEST_DIR/config/config.kdl" 2>/dev/null; then
    echo "✅ Layout block found in config"
    echo "   Layout content:"
    sed -n '/^layout {/,/^}/p' "$TEST_DIR/config/config.kdl"
else
    echo "❌ Layout block NOT found in config!"
fi
echo ""

# 5. Test launching with verbose output
echo "5️⃣  Test Zellij setup check:"
export ZELLIJ_CONFIG_DIR="$TEST_DIR/config"
"$TEST_DIR/bin/zellij" setup --check 2>&1 | head -20
echo ""

echo "============================"
echo "🔍 Diagnostic Complete"
echo ""
echo "Quick fixes to try:"
echo "  1. If PLUGIN_PATH not replaced: re-run ./test-bunshin.sh"
echo "  2. If layout block missing: re-run ./test-bunshin.sh"
echo "  3. If plugin missing: run 'cargo build --release --target wasm32-wasip1' in default-plugins/bunshin/"
