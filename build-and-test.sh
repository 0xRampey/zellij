#!/bin/bash
set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║     🥷 BUNSHIN - Quick Build & Test 🥷                        ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Step 1: Build BOTH Zellij and Plugin together
echo "📦 Step 1/3: Building Zellij + Bunshin plugin..."
echo "   (This will take 2-5 minutes on first run)"
echo ""

# Build Zellij binary (native target)
echo "   Building Zellij binary..."
cargo build --release 2>&1 | grep -E "Compiling zellij|Finished|error" || true

# Build Bunshin plugin (wasm target)
echo "   Building Bunshin plugin..."
cargo build --release --target wasm32-wasip1 -p bunshin 2>&1 | grep -E "Compiling bunshin|Finished|error" || true
echo ""

# Step 2: Copy to test directory
echo "📁 Step 2/3: Setting up test installation..."
TEST_DIR="$HOME/.bunshin-test"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"/{bin,plugins,config}

# Copy Zellij binary
cp target/release/zellij "$TEST_DIR/bin/"
echo "   ✅ Copied Zellij binary"

# Copy Bunshin plugin
cp target/wasm32-wasip1/release/bunshin.wasm "$TEST_DIR/plugins/"
echo "   ✅ Copied Bunshin plugin"

# Create layout file
cat > "$TEST_DIR/config/bunshin.kdl" << 'EOF'
layout {
    pane size=1 borderless=true {
        plugin location="tab-bar"
    }
    pane split_direction="Vertical" {
        pane {
            command "claude"
        }
    }
    pane size=2 borderless=true {
        plugin location="status-bar"
    }
}
EOF
echo "   ✅ Created layout file"

# Create config file
cat > "$TEST_DIR/config/config.kdl" << EOF
keybinds clear-defaults=true {
    normal {
        // Tmux-style prefix keybinding
        bind "Ctrl b" { SwitchToMode "tmux"; }
    }
    tmux {
        bind "s" {
            LaunchOrFocusPlugin "file:$TEST_DIR/plugins/bunshin.wasm" {
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
echo "   ✅ Created config file"
echo ""

# Step 3: Create launch script
echo "📝 Step 3/3: Creating launch script..."
cat > "$TEST_DIR/bin/bunshin-test" << 'SCRIPT'
#!/bin/bash
export ZELLIJ_CONFIG_DIR="TEST_DIR_PLACEHOLDER/config"
ZELLIJ_BIN="TEST_DIR_PLACEHOLDER/bin/zellij"
LAYOUT="TEST_DIR_PLACEHOLDER/config/bunshin.kdl"

# Check if there are existing sessions
EXISTING_SESSIONS=$("$ZELLIJ_BIN" list-sessions 2>/dev/null | wc -l)

if [ "$EXISTING_SESSIONS" -gt 0 ]; then
    # Sessions exist - attach to first session
    SESSION_NAME=$("$ZELLIJ_BIN" list-sessions 2>/dev/null | head -1 | awk '{print $1}')
    exec "$ZELLIJ_BIN" attach "$SESSION_NAME" --create
else
    # No sessions - create new session with Claude layout
    exec "$ZELLIJ_BIN" --layout "$LAYOUT" "$@"
fi
SCRIPT

# Replace TEST_DIR_PLACEHOLDER with actual path (macOS/Linux compatible)
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|TEST_DIR_PLACEHOLDER|$TEST_DIR|g" "$TEST_DIR/bin/bunshin-test"
else
    sed -i "s|TEST_DIR_PLACEHOLDER|$TEST_DIR|g" "$TEST_DIR/bin/bunshin-test"
fi

chmod +x "$TEST_DIR/bin/bunshin-test"
echo "   ✅ Launch script ready"
echo ""

# Verify build
echo "🔍 Verifying build..."
ZELLIJ_VERSION=$("$TEST_DIR/bin/zellij" --version 2>&1 | head -1)
PLUGIN_SIZE=$(ls -lh "$TEST_DIR/plugins/bunshin.wasm" | awk '{print $5}')

echo "   Zellij: $ZELLIJ_VERSION"
echo "   Plugin: $PLUGIN_SIZE"
echo ""

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                  ✅ BUILD COMPLETE! ✅                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "🚀 Launch Bunshin:"
echo ""
echo "   $TEST_DIR/bin/bunshin-test"
echo ""
echo "📖 Usage:"
echo "   • Claude starts automatically in your current directory"
echo "   • Press Ctrl+b to open session manager"
echo "   • Press Ctrl+o then 'd' to detach"
echo ""
