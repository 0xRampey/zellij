#!/bin/bash

echo "🔍 Debugging Bunshin Installation"
echo "=================================="
echo ""

TEST_DIR="$HOME/.bunshin-test"
ZELLIJ_BIN="$TEST_DIR/bin/zellij"

echo "1. Checking if files exist..."
echo "   Zellij binary: $([ -f "$ZELLIJ_BIN" ] && echo "✅ exists" || echo "❌ missing")"
echo "   Launch script: $([ -f "$TEST_DIR/bin/bunshin-test" ] && echo "✅ exists" || echo "❌ missing")"
echo "   Config file: $([ -f "$TEST_DIR/config/config.kdl" ] && echo "✅ exists" || echo "❌ missing")"
echo "   Layout file: $([ -f "$TEST_DIR/config/bunshin.kdl" ] && echo "✅ exists" || echo "❌ missing")"
echo ""

echo "2. Testing Zellij binary..."
if "$ZELLIJ_BIN" --version 2>&1; then
    echo "   ✅ Zellij binary works"
else
    echo "   ❌ Zellij binary failed"
    exit 1
fi
echo ""

echo "3. Testing list-sessions command..."
SESSIONS=$("$ZELLIJ_BIN" list-sessions 2>&1)
echo "   Output: $SESSIONS"
echo "   Count: $(echo "$SESSIONS" | wc -l | xargs)"
echo ""

echo "4. Testing layout file..."
if [ -f "$TEST_DIR/config/bunshin.kdl" ]; then
    echo "   Layout file contents:"
    cat "$TEST_DIR/config/bunshin.kdl"
else
    echo "   ❌ Layout file missing!"
fi
echo ""

echo "5. Launch script contents:"
cat "$TEST_DIR/bin/bunshin-test"
echo ""

echo "6. Trying to launch Zellij with verbose output..."
echo "   Running: ZELLIJ_CONFIG_DIR=$TEST_DIR/config $ZELLIJ_BIN --layout $TEST_DIR/config/bunshin.kdl"
echo "   Press Ctrl+C if it hangs..."
echo ""

export ZELLIJ_CONFIG_DIR="$TEST_DIR/config"
"$ZELLIJ_BIN" --layout "$TEST_DIR/config/bunshin.kdl"
