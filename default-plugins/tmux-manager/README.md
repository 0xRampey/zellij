# Claude Code Orchestrator

A Zellij plugin that transforms Zellij into a tmux-style AI development orchestrator for Claude Code. Manage multiple Claude instances, sessions, and AI-powered development workflows with familiar keybindings and an intuitive interface.

## 🚀 Features

### Claude Code Integration
- **One-Key Claude Launch**: Instantly spawn Claude Code in new panes, tabs, or sessions
- **Auto-Start Layout**: Zellij can automatically start Claude Code when launching
- **Multi-Instance Management**: Run multiple Claude instances across different sessions
- **Smart Orchestration**: Organize AI-powered development workflows efficiently

### Session Management
- **Session Overview**: View all active sessions with detailed information (windows, panes, clients)
- **Tmux-like Keybindings**: Familiar keyboard shortcuts for tmux users
- **Quick Navigation**: Fast session switching with vim-style navigation
- **Session Operations**: Create, rename, kill, and switch sessions
- **Current Session Indicator**: Easily identify which session you're currently in

## 📦 Installation

This plugin is included with Zellij as a default plugin. To use it, add it to your Zellij configuration:

```kdl
// In your Zellij config file (~/.config/zellij/config.kdl)
keybinds {
    shared_except "locked" {
        bind "Alt s" {
            LaunchOrFocusPlugin "tmux-manager" {
                floating true
            }
        }
    }
}
```

### Auto-Start Claude Code on Launch

To automatically start Claude Code when launching Zellij, use the Claude orchestrator layout:

```bash
zellij --layout claude-orchestrator
```

Or set it as default in your config:

```kdl
default_layout "claude-orchestrator"
```

## 🎯 Usage

### Opening the Orchestrator

Press `Alt+s` (or your configured keybinding) to open the Claude Code Orchestrator.

### Main View

The main view displays all active sessions in a clean table format:

```
                  Claude Code Orchestrator
────────────────────────────────────────────────────────────
Session           Windows  Panes  Clients
────────────────────────────────────────────────────────────
* claude-main     2        3      1
  development     4        6      1
  research        1        2      0
────────────────────────────────────────────────────────────
                3 sessions | ?: Help | q: Quit
```

The `*` indicator shows the current session.

## ⌨️ Keybindings

### Navigation

| Key | Action |
|-----|--------|
| `j`, `↓` | Move down in the session list |
| `k`, `↑` | Move up in the session list |
| `g`, `Home` | Jump to first session |
| `G`, `End` | Jump to last session |

### Session Actions

| Key | Action |
|-----|--------|
| `Enter` | Switch to the selected session |
| `c` | Create a new session |
| `$` | Rename the current session |
| `x` | Kill the selected session (with confirmation) |
| `d` | Detach from the current session |
| `(` | Switch to the previous session |
| `)` | Switch to the next session |

### Claude Code Orchestration 🤖

| Key | Action |
|-----|--------|
| `C` | **Launch Claude in new pane** (in current session) |
| `A` | **Launch Claude in new tab** (creates new tab with Claude) |
| `N` | **Create new session with Claude** (auto-named, pre-configured) |

### Other

| Key | Action |
|-----|--------|
| `?` | Toggle help screen |
| `q`, `Esc` | Close the orchestrator |

## 💡 Workflows

### Quick Claude Instance in Current Session

1. Press `Alt+s` to open orchestrator
2. Press `C` to launch Claude in a new pane
3. Start coding with AI assistance

### Dedicated Claude Tab

1. Press `Alt+s`
2. Press `A` to create a new tab with Claude
3. Switch between tabs with standard Zellij keybindings

### New AI Development Session

1. Press `Alt+s`
2. Press `N` to create a timestamped session with Claude pre-loaded
3. Perfect for isolating different projects or experiments

### Organizing Multiple Projects

1. Create sessions for each project: `c` → type name → `Enter`
2. Launch Claude instances in each: `C`
3. Switch between projects: `(` / `)` or select with arrows + `Enter`

## 🎬 Example Use Cases

### Scenario 1: Multiple AI-Assisted Projects

```
Session: frontend (Claude helping with React)
Session: backend (Claude helping with API design)
Session: devops (Claude helping with Docker configs)
```

Quick switch between contexts while maintaining separate Claude conversations for each project.

### Scenario 2: Pair Programming with AI

```
Tab 1: Your code editor
Tab 2: Claude Code (C to launch)
Tab 3: Terminal for testing
```

Keep Claude in a dedicated tab for easy reference while coding.

### Scenario 3: Research & Development

```
Pane 1: Documentation/research
Pane 2: Claude Code (C to launch in split)
Pane 3: Experimental code
```

Side-by-side layout for rapid prototyping with AI assistance.

## 🔧 Advanced Configuration

### Custom Claude Command Path

If Claude is installed in a different location, modify the plugin source to update the path:

```rust
// In src/lib.rs, update the path
path: "/your/custom/path/to/claude".into(),
```

### Custom Session Names

When creating Claude sessions with `N`, they're auto-named with timestamps. To customize:

```rust
// In create_claude_session() function
let session_name = format!("your-prefix-{}", chrono::Utc::now().timestamp());
```

## 📋 Session Naming Rules

When creating or renaming sessions:

- **Cannot be empty**: Must contain at least one character
- **Cannot contain `/`**: Forward slashes are not allowed
- **Maximum length**: Must be shorter than 108 characters (socket path limitation)

## 🆚 Comparison with Tmux

This orchestrator is designed for tmux users transitioning to Zellij:

| Tmux Command | Orchestrator | Description |
|--------------|--------------|-------------|
| `tmux ls` | Main view | List sessions |
| `tmux switch-client -t` | `Enter` | Switch to session |
| `tmux new-session -s` | `c` | Create new session |
| `tmux rename-session` | `$` | Rename current session |
| `tmux kill-session -t` | `x` | Kill session |
| `tmux detach` | `d` | Detach from session |
| `Ctrl-b` `(` | `(` | Previous session |
| `Ctrl-b` `)` | `)` | Next session |
| *N/A* | `C` | **Launch Claude in pane** |
| *N/A* | `A` | **Launch Claude in tab** |
| *N/A* | `N` | **New Claude session** |

## 🏗️ Architecture

The plugin is built on the Zellij plugin SDK and includes:

- **Session Management**: Full CRUD operations on Zellij sessions
- **Command Execution**: Spawns Claude Code processes in panes/tabs
- **State Management**: Tracks sessions, UI modes, and user input
- **Permission System**: Requests necessary permissions for operations
- **Event Handling**: Responds to keyboard and session update events

## 🧪 Testing

The plugin includes comprehensive unit tests:

```bash
cd default-plugins/tmux-manager
cargo test
```

Test coverage includes:
- Navigation and keyboard handling
- Mode transitions
- Session name validation
- Error handling
- Edge cases

## 🐛 Troubleshooting

### Plugin doesn't open

Check your Zellij configuration for the correct keybinding:

```kdl
bind "Alt s" {
    LaunchOrFocusPlugin "tmux-manager" {
        floating true
    }
}
```

### Claude doesn't launch

1. Verify Claude is installed: `which claude`
2. Check the path in the plugin matches your installation
3. Ensure you have `RunCommands` permission

### Cannot rename/kill sessions

- **Rename**: You can only rename the current session (marked with `*`)
- **Kill**: You cannot kill the current session. Switch to another first.

## 📚 Resources

- [Zellij Documentation](https://zellij.dev)
- [Claude Code Documentation](https://docs.anthropic.com/claude/docs)
- [Plugin Development Guide](https://zellij.dev/documentation/plugins)

## 🤝 Contributing

Contributions are welcome! This plugin is part of the Zellij project.

## 📄 License

This plugin is part of the Zellij project and follows the same MIT license.

## 🎉 Credits

Built on the Zellij plugin SDK, inspired by tmux's session management, and enhanced for AI-powered development workflows with Claude Code.
