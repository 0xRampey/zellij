#!/bin/bash
set -e

echo "🔨 Building Bunshin Plugin"
echo "=========================="
echo ""

# Build the plugin
cargo build --release --target wasm32-wasip1

PLUGIN_PATH="../../target/wasm32-wasip1/release/bunshin.wasm"

if [ -f "$PLUGIN_PATH" ]; then
    SIZE=$(ls -lh "$PLUGIN_PATH" | awk '{print $5}')
    echo "✅ Plugin built successfully!"
    echo "   Location: $PLUGIN_PATH"
    echo "   Size: $SIZE"
    echo ""
    echo "📖 How to use:"
    echo ""
    echo "1. Copy to Zellij plugins directory:"
    echo "   cp $PLUGIN_PATH ~/.config/zellij/plugins/"
    echo ""
    echo "2. Add to your Zellij config (~/.config/zellij/config.kdl):"
    echo ""
    echo "   keybinds {"
    echo "       shared_except \"locked\" {"
    echo "           bind \"Ctrl b\" {"
    echo "               LaunchOrFocusPlugin \"file:~/.config/zellij/plugins/bunshin.wasm\" {"
    echo "                   floating true"
    echo "                   move_to_focused_tab true"
    echo "               }"
    echo "           }"
    echo "       }"
    echo "   }"
    echo ""
    echo "3. Create a layout file (~/.config/zellij/layouts/claude.kdl):"
    echo ""
    echo "   layout {"
    echo "       pane size=1 borderless=true {"
    echo "           plugin location=\"tab-bar\""
    echo "       }"
    echo "       pane {"
    echo "           command \"claude\""
    echo "       }"
    echo "       pane size=2 borderless=true {"
    echo "           plugin location=\"status-bar\""
    echo "       }"
    echo "   }"
    echo ""
    echo "4. Launch with:"
    echo "   zellij --layout claude"
    echo ""
else
    echo "❌ Build failed - plugin not found"
    exit 1
fi
