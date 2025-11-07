#!/bin/bash
set -e

# Bunshin (分身) - One-Command Installer
# Installs Zellij + Bunshin plugin with zero manual configuration

VERSION="0.1.0"
BUNSHIN_DIR="$HOME/.bunshin"
ZELLIJ_VERSION="0.44.0"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║     🥷 BUNSHIN (分身) INSTALLER v$VERSION 🥷                  ║"
echo "║                                                                ║"
echo "║         Shadow Clone Technique for Claude Code                ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Detect OS and Architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Linux*)     OS_TYPE="linux";;
    Darwin*)    OS_TYPE="macos";;
    *)          echo "❌ Unsupported OS: $OS"; exit 1;;
esac

case "$ARCH" in
    x86_64)     ARCH_TYPE="x86_64";;
    aarch64|arm64) ARCH_TYPE="aarch64";;
    *)          echo "❌ Unsupported architecture: $ARCH"; exit 1;;
esac

echo "📋 System Info:"
echo "   OS:           $OS_TYPE"
echo "   Architecture: $ARCH_TYPE"
echo "   Install Dir:  $BUNSHIN_DIR"
echo ""

# Create Bunshin directory
echo "📁 Creating Bunshin directory..."
mkdir -p "$BUNSHIN_DIR"/{bin,plugins,config/layouts}

# Check if Zellij is already installed
ZELLIJ_PATH=""
if command -v zellij &> /dev/null; then
    EXISTING_ZELLIJ=$(which zellij)
    EXISTING_VERSION=$(zellij --version | grep -oP '\d+\.\d+\.\d+' || echo "unknown")
    echo "✅ Found existing Zellij: $EXISTING_ZELLIJ (v$EXISTING_VERSION)"
    read -p "   Use existing Zellij? [Y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        ZELLIJ_PATH="$EXISTING_ZELLIJ"
    fi
fi

# Download/Install Zellij if needed
if [ -z "$ZELLIJ_PATH" ]; then
    echo "📥 Installing Zellij v$ZELLIJ_VERSION..."

    ZELLIJ_URL="https://github.com/zellij-org/zellij/releases/download/v${ZELLIJ_VERSION}/zellij-${ARCH_TYPE}-unknown-${OS_TYPE}-musl.tar.gz"

    echo "   Downloading from: $ZELLIJ_URL"

    if command -v curl &> /dev/null; then
        curl -L "$ZELLIJ_URL" -o "$BUNSHIN_DIR/zellij.tar.gz"
    elif command -v wget &> /dev/null; then
        wget "$ZELLIJ_URL" -O "$BUNSHIN_DIR/zellij.tar.gz"
    else
        echo "❌ Error: curl or wget required for download"
        exit 1
    fi

    echo "   Extracting..."
    tar -xzf "$BUNSHIN_DIR/zellij.tar.gz" -C "$BUNSHIN_DIR/bin/"
    rm "$BUNSHIN_DIR/zellij.tar.gz"
    chmod +x "$BUNSHIN_DIR/bin/zellij"

    ZELLIJ_PATH="$BUNSHIN_DIR/bin/zellij"
    echo "   ✅ Zellij installed to: $ZELLIJ_PATH"
fi

# Copy Bunshin plugin
echo "📦 Installing Bunshin plugin..."
if [ -f "/home/user/zellij/target/wasm32-wasip1/release/bunshin.wasm" ]; then
    cp "/home/user/zellij/target/wasm32-wasip1/release/bunshin.wasm" "$BUNSHIN_DIR/plugins/"
    echo "   ✅ Plugin installed from build"
else
    echo "   ⚠️  Warning: Plugin not found, will need to build it"
fi

# Create Bunshin layout file
echo "⚙️  Creating Bunshin layout..."
cat > "$BUNSHIN_DIR/config/bunshin.kdl" << 'EOF'
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

# Create Zellij config for Bunshin
echo "⚙️  Configuring Bunshin..."
cat > "$BUNSHIN_DIR/config/config.kdl" << 'EOF'
// Bunshin (分身) - Auto-generated Configuration

keybinds {
    shared_except "locked" {
        // Open Bunshin orchestrator with Alt+s (for session management)
        bind "Alt s" {
            LaunchOrFocusPlugin "file:BUNSHIN_PLUGIN_PATH" {
                floating true
                move_to_focused_tab true
            }
        }
    }
}
EOF

# Replace plugin path in config (macOS/Linux compatible)
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|BUNSHIN_PLUGIN_PATH|$BUNSHIN_DIR/plugins/bunshin.wasm|g" "$BUNSHIN_DIR/config/config.kdl"
else
    sed -i "s|BUNSHIN_PLUGIN_PATH|$BUNSHIN_DIR/plugins/bunshin.wasm|g" "$BUNSHIN_DIR/config/config.kdl"
fi

# Create bunshin wrapper script
echo "🔧 Creating bunshin command..."
cat > "$BUNSHIN_DIR/bin/bunshin" << 'EOF'
#!/bin/bash
# Bunshin (分身) - Claude Code Orchestrator CLI

BUNSHIN_DIR="HOME_DIR/.bunshin"
ZELLIJ_BIN="ZELLIJ_PATH"
BUNSHIN_CONFIG="$BUNSHIN_DIR/config/config.kdl"
BUNSHIN_LAYOUT="$BUNSHIN_DIR/config/bunshin.kdl"

# Set Zellij config directory
export ZELLIJ_CONFIG_DIR="$BUNSHIN_DIR/config"

# Parse arguments
case "${1:-}" in
    --version|-v)
        echo "Bunshin (分身) v0.1.0"
        echo "Zellij: $("$ZELLIJ_BIN" --version)"
        ;;
    --help|-h)
        cat << 'HELP'
Bunshin (分身) - Claude Code Orchestrator

Usage:
  bunshin                    Launch Bunshin (default layout)
  bunshin claude             Launch with Claude auto-start
  bunshin <layout>           Launch with custom layout
  bunshin --config           Open config directory
  bunshin --version          Show version
  bunshin --help             Show this help

Keybindings (inside Bunshin):
  Alt+s     Open orchestrator
  C         Spawn Claude in new pane
  A         Spawn Claude in new tab
  N         Create new session with Claude
  ?         Show help
  q         Close orchestrator

Examples:
  bunshin                    # Launch (Claude auto-starts)
  bunshin --config           # Edit configuration

HELP
        ;;
    --config)
        echo "Opening config directory: $BUNSHIN_DIR/config"
        if command -v code &> /dev/null; then
            code "$BUNSHIN_DIR/config"
        elif [ -n "$EDITOR" ]; then
            $EDITOR "$BUNSHIN_DIR/config/config.kdl"
        else
            echo "Config location: $BUNSHIN_DIR/config/config.kdl"
        fi
        ;;
    *)
        # Default launch - Claude auto-starts from layout file
        exec "$ZELLIJ_BIN" --config "$BUNSHIN_CONFIG" --layout "$BUNSHIN_LAYOUT" "$@"
        ;;
esac
EOF

# Replace placeholders in wrapper (macOS/Linux compatible)
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|HOME_DIR|$HOME|g" "$BUNSHIN_DIR/bin/bunshin"
    sed -i '' "s|ZELLIJ_PATH|$ZELLIJ_PATH|g" "$BUNSHIN_DIR/bin/bunshin"
else
    sed -i "s|HOME_DIR|$HOME|g" "$BUNSHIN_DIR/bin/bunshin"
    sed -i "s|ZELLIJ_PATH|$ZELLIJ_PATH|g" "$BUNSHIN_DIR/bin/bunshin"
fi
chmod +x "$BUNSHIN_DIR/bin/bunshin"

# Add to PATH if not already there
echo "🔗 Setting up PATH..."
SHELL_RC=""
if [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
fi

PATH_LINE='export PATH="$HOME/.bunshin/bin:$PATH"'
if [ -n "$SHELL_RC" ]; then
    if ! grep -q ".bunshin/bin" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# Bunshin (分身) - Claude Code Orchestrator" >> "$SHELL_RC"
        echo "$PATH_LINE" >> "$SHELL_RC"
        echo "   ✅ Added to $SHELL_RC"
        echo "      Run: source $SHELL_RC"
    else
        echo "   ✅ Already in PATH"
    fi
fi

# Summary
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║                  ✅ INSTALLATION COMPLETE! ✅                  ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "📍 Installed to: $BUNSHIN_DIR"
echo ""
echo "🚀 Quick Start:"
echo ""
echo "   1. Reload your shell:"
echo "      source $SHELL_RC"
echo ""
echo "   2. Launch Bunshin (Claude starts automatically!):"
echo "      bunshin"
echo ""
echo "   That's it! Claude opens in your current directory. 🥷✨"
echo ""
echo "📖 Commands:"
echo "   bunshin              # Launch with Claude (default)"
echo "   bunshin --help       # Show help"
echo "   bunshin --config     # Edit config"
echo ""
echo "⌨️  Advanced Features (Alt+s for orchestrator):"
echo "   Alt+s    Open session manager"
echo "   C        Spawn more Claude instances"
echo "   c        Create new session"
echo "   ?        Show all keybindings"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "Ready to create shadow clones! 🥷✨"
echo ""
