#!/bin/bash
# Quick test script that bypasses default_layout config

TEST_DIR="$HOME/.bunshin-test"

if [ ! -d "$TEST_DIR" ]; then
    echo "❌ Run ./test-bunshin.sh first!"
    exit 1
fi

echo "🚀 Launching Bunshin with explicit layout path..."
export ZELLIJ_CONFIG_DIR="$TEST_DIR/config"
exec "$TEST_DIR/bin/zellij" --layout "$TEST_DIR/config/layouts/claude-orchestrator.kdl"
