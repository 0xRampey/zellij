#!/bin/bash
# Create Bunshin distribution package

set -e

VERSION="0.1.0"
BUILD_DIR="/tmp/bunshin-release"
RELEASE_DIR="$BUILD_DIR/bunshin-$VERSION"

echo "📦 Creating Bunshin v$VERSION release package..."

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$RELEASE_DIR"/{plugins,config,layouts,bin}

# Build the plugin
echo "🔨 Building plugin..."
cd /home/user/zellij
cargo build --release --target wasm32-wasip1 -p bunshin

# Copy plugin
echo "📋 Copying plugin..."
cp target/wasm32-wasip1/release/bunshin.wasm "$RELEASE_DIR/plugins/"

# Copy installer
echo "📋 Copying installer..."
cp /home/user/install-bunshin.sh "$RELEASE_DIR/"
chmod +x "$RELEASE_DIR/install-bunshin.sh"

# Create default config
cat > "$RELEASE_DIR/config/config.kdl" << 'EOF'
// Bunshin (分身) - Default Configuration

keybinds {
    shared_except "locked" {
        bind "Alt s" {
            LaunchOrFocusPlugin "file:BUNSHIN_PLUGIN_PATH" {
                floating true
                move_to_focused_tab true
            }
        }
    }
}
EOF

# Create layouts
cat > "$RELEASE_DIR/layouts/claude-orchestrator.kdl" << 'EOF'
layout {
    pane size=1 borderless=true {
        plugin location="tab-bar"
    }
    pane split_direction="Vertical" {
        pane {
            command "claude"
            cwd "~"
        }
    }
    pane size=2 borderless=true {
        plugin location="status-bar"
    }
}
EOF

cat > "$RELEASE_DIR/layouts/default.kdl" << 'EOF'
layout {
    pane size=1 borderless=true {
        plugin location="tab-bar"
    }
    pane
    pane size=2 borderless=true {
        plugin location="status-bar"
    }
}
EOF

# Create README
cat > "$RELEASE_DIR/README.md" << 'EOF'
# Bunshin (分身) v0.1.0

**Shadow Clone Technique for Claude Code**

## Quick Install

```bash
./install-bunshin.sh
```

This will:
- Install Zellij (if not present)
- Install Bunshin plugin
- Configure everything automatically
- Add `bunshin` command to your PATH

## Usage

```bash
# Launch Bunshin
bunshin

# Press Alt+s to open orchestrator
# Press C to spawn Claude in a pane
```

## Commands

- `bunshin` - Launch normally
- `bunshin claude` - Auto-start Claude
- `bunshin --help` - Show help
- `bunshin --config` - Edit configuration

## Keybindings

Inside Bunshin (press Alt+s first):

- `C` - Spawn Claude in new pane
- `A` - Spawn Claude in new tab
- `N` - Create new session with Claude
- `?` - Show help
- `q` - Close orchestrator

## What's Included

- `plugins/bunshin.wasm` - The Bunshin plugin
- `install-bunshin.sh` - Automatic installer
- `config/` - Default configuration
- `layouts/` - Pre-made layouts

## Learn More

Full documentation: https://github.com/your-repo/bunshin

---

*Bunshin - Create shadow clones of Claude across your workspace* 🥷
EOF

# Create quick start script
cat > "$RELEASE_DIR/quick-start.sh" << 'EOF'
#!/bin/bash
echo "🥷 Bunshin Quick Start"
echo ""
echo "This will install Bunshin on your system."
echo ""
read -p "Continue? [Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    ./install-bunshin.sh
fi
EOF
chmod +x "$RELEASE_DIR/quick-start.sh"

# Create tarball
echo "📦 Creating tarball..."
cd "$BUILD_DIR"
tar -czf "bunshin-${VERSION}.tar.gz" "bunshin-${VERSION}/"

echo ""
echo "✅ Release package created!"
echo "   Location: $BUILD_DIR/bunshin-${VERSION}.tar.gz"
echo "   Size: $(du -h "$BUILD_DIR/bunshin-${VERSION}.tar.gz" | cut -f1)"
echo ""
echo "📋 Package contents:"
ls -lh "$RELEASE_DIR"
echo ""
echo "🚀 To test the installer:"
echo "   cd $RELEASE_DIR"
echo "   ./install-bunshin.sh"
echo ""
echo "📤 To distribute:"
echo "   Upload: $BUILD_DIR/bunshin-${VERSION}.tar.gz"
echo ""
echo "Users can install with:"
echo "   curl -L <url>/bunshin-${VERSION}.tar.gz | tar -xz"
echo "   cd bunshin-${VERSION}"
echo "   ./install-bunshin.sh"
echo ""
