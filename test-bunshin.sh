#!/bin/bash
set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║     🥷 BUNSHIN TEST SCRIPT 🥷                                 ║"
echo "║                                                                ║"
echo "║     Building and installing Bunshin for local testing...      ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Step 1: Build Bunshin plugin (force rebuild)
echo "📦 Step 1/4: Building Bunshin plugin..."
cd default-plugins/bunshin
cargo clean
cargo build --release --target wasm32-wasip1
echo "   ✅ Plugin built: ../../target/wasm32-wasip1/release/bunshin.wasm"
echo ""

# Step 2: Build Zellij binary
cd "$SCRIPT_DIR"
echo "📦 Step 2/4: Building Zellij binary..."
cargo build --release
echo "   ✅ Zellij built: target/release/zellij"
echo ""

# Step 3: Create a test installation directory
echo "📁 Step 3/4: Setting up test environment..."
TEST_DIR="$HOME/.bunshin-test"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"/{bin,plugins,config}

# Copy Zellij binary
cp target/release/zellij "$TEST_DIR/bin/"

# Copy Bunshin plugin
cp target/wasm32-wasip1/release/bunshin.wasm "$TEST_DIR/plugins/"

# Create layout file (Zellij doesn't support embedded layouts in config.kdl)
cat > "$TEST_DIR/config/bunshin.kdl" << 'EOF'
layout {
    pane size=1 borderless=true {
        plugin location="tab-bar"
    }
    pane split_direction="Vertical" {
        pane {
            command "claude"
            // cwd defaults to current working directory
        }
    }
    pane size=2 borderless=true {
        plugin location="status-bar"
    }
}
EOF

# Create config file that references the layout
cat > "$TEST_DIR/config/config.kdl" << 'EOF'
keybinds clear-defaults=true {
    normal {
        // Tmux-style prefix keybindings
        bind "Ctrl b" { SwitchToMode "tmux"; }
    }
    tmux {
        bind "s" {
            LaunchOrFocusPlugin "file:PLUGIN_PATH" {
                floating true
                move_to_focused_tab true
            }
            SwitchToMode "normal";
        }
        bind "c" {
            NewTab;
            SwitchToMode "normal";
        }
        bind "d" {
            Detach;
        }
        bind "Ctrl c" "Esc" {
            SwitchToMode "normal";
        }
    }
    locked {
        bind "Ctrl g" { SwitchToMode "normal"; }
    }
}
EOF

# Replace plugin path (macOS/Linux compatible)
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|PLUGIN_PATH|$TEST_DIR/plugins/bunshin.wasm|g" "$TEST_DIR/config/config.kdl"
else
    sed -i "s|PLUGIN_PATH|$TEST_DIR/plugins/bunshin.wasm|g" "$TEST_DIR/config/config.kdl"
fi

echo "   ✅ Test environment: $TEST_DIR"
echo ""

# Step 4: Create launch script
echo "📝 Step 4/4: Creating launch script..."
cat > "$TEST_DIR/bin/bunshin-test" << 'SCRIPT'
#!/bin/bash
export ZELLIJ_CONFIG_DIR="TEST_DIR_PLACEHOLDER/config"
ZELLIJ_BIN="TEST_DIR_PLACEHOLDER/bin/zellij"
LAYOUT="TEST_DIR_PLACEHOLDER/config/bunshin.kdl"

# Check if there are existing sessions
EXISTING_SESSIONS=$("$ZELLIJ_BIN" list-sessions 2>/dev/null | wc -l)

if [ "$EXISTING_SESSIONS" -gt 0 ]; then
    # Sessions exist - attach to first session and open session manager
    SESSION_NAME=$("$ZELLIJ_BIN" list-sessions 2>/dev/null | head -1 | awk '{print $1}')
    exec "$ZELLIJ_BIN" attach "$SESSION_NAME" --create
else
    # No sessions - create new session with Claude layout
    exec "$ZELLIJ_BIN" --layout "$LAYOUT" "$@"
fi
SCRIPT

# Replace TEST_DIR_PLACEHOLDER with actual path
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|TEST_DIR_PLACEHOLDER|$TEST_DIR|g" "$TEST_DIR/bin/bunshin-test"
else
    sed -i "s|TEST_DIR_PLACEHOLDER|$TEST_DIR|g" "$TEST_DIR/bin/bunshin-test"
fi

chmod +x "$TEST_DIR/bin/bunshin-test"
echo "   ✅ Launch script: $TEST_DIR/bin/bunshin-test"
echo ""

# Done!
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║                  ✅ BUILD COMPLETE! ✅                         ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "🚀 Test Bunshin now:"
echo ""
echo "   $TEST_DIR/bin/bunshin-test"
echo ""
echo "📖 What will happen:"
echo "   1. Zellij launches with Bunshin configuration"
echo "   2. Claude Code starts in your current directory"
echo "   3. Press Alt+s to open session manager"
echo ""
echo "💡 Tips:"
echo "   • Detach: Ctrl+o then d"
echo "   • Help: Alt+s then ?"
echo "   • Exit: Type 'exit' in Claude terminal"
echo ""
echo "🧹 Cleanup when done:"
echo "   rm -rf $TEST_DIR"
echo ""
