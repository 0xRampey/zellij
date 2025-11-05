# Tmux Session Manager

A Zellij plugin that provides a tmux-like session management experience with familiar keybindings and a clean, intuitive interface.

## Features

- **Session Overview**: View all active sessions with detailed information (windows, panes, clients)
- **Tmux-like Keybindings**: Familiar keyboard shortcuts for tmux users
- **Quick Navigation**: Fast session switching with vim-style navigation
- **Session Management**: Create, rename, and kill sessions
- **Clean UI**: Simple, focused interface showing only what matters
- **Current Session Indicator**: Easily identify which session you're currently in

## Installation

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

## Usage

### Opening the Manager

Once configured, press `Alt+s` (or your configured keybinding) to open the Tmux Session Manager.

### Main View

The main view displays all active sessions in a table format:

```
                  Tmux Session Manager
────────────────────────────────────────────────────────────
Session           Windows  Panes  Clients
────────────────────────────────────────────────────────────
* main            3        5      1
  development     2        3      0
  research        1        2      1
────────────────────────────────────────────────────────────
                3 sessions | ?: Help | q: Quit
```

The `*` indicator shows the current session.

## Keybindings

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

### Other

| Key | Action |
|-----|--------|
| `?` | Toggle help screen |
| `q`, `Esc` | Close the manager |

## Screens

### 1. Session List (Main)

The default view showing all active sessions with their details.

### 2. Create Session

Press `c` to create a new session. A dialog will appear:

```
          ┌────────────────────────────────────────┐
          │          Create New Session            │
          ├────────────────────────────────────────┤
          │                                        │
          │  Session name:                         │
          │  my-new-session_                       │
          │                                        │
          └────────────────────────────────────────┘
                Enter: Create | Esc: Cancel
```

Type the session name and press `Enter` to create and switch to the new session.

### 3. Rename Session

Press `$` while on the current session to rename it:

```
          ┌────────────────────────────────────────┐
          │            Rename Session              │
          ├────────────────────────────────────────┤
          │                                        │
          │  New name:                             │
          │  updated-name_                         │
          │                                        │
          └────────────────────────────────────────┘
                Enter: Rename | Esc: Cancel
```

### 4. Kill Session

Press `x` on a non-current session to kill it (with confirmation):

```
          ┌────────────────────────────────────────┐
          │        Confirm Kill Session            │
          ├────────────────────────────────────────┤
          │                                        │
          │     Kill session 'development'?        │
          │                                        │
          └────────────────────────────────────────┘
              y: Yes | n: No | Esc: Cancel
```

### 5. Help Screen

Press `?` to view the help screen with all available keybindings.

## Session Naming Rules

When creating or renaming sessions, the following rules apply:

- **Cannot be empty**: Session names must contain at least one character
- **Cannot contain `/`**: Forward slashes are not allowed in session names
- **Maximum length**: Session names must be shorter than 108 characters (socket path limitation)

## Tmux Comparison

This plugin is inspired by tmux's session management and uses similar keybindings:

| Tmux Command | Tmux Manager | Description |
|--------------|--------------|-------------|
| `tmux ls` | Plugin main view | List sessions |
| `tmux switch-client -t` | `Enter` | Switch to session |
| `tmux new-session -s` | `c` | Create new session |
| `tmux rename-session` | `$` | Rename current session |
| `tmux kill-session -t` | `x` | Kill session |
| `tmux detach` | `d` | Detach from session |
| `Ctrl-b` `(` | `(` | Previous session |
| `Ctrl-b` `)` | `)` | Next session |

## Development

### Building

To build the plugin:

```bash
cd default-plugins/tmux-manager
cargo build --release
```

### Testing

Run the comprehensive test suite:

```bash
cargo test
```

The test suite covers:
- Navigation and keyboard input handling
- Mode transitions and state management
- Session name validation
- Error handling
- Edge cases (empty lists, index clamping)

### Test Coverage

The plugin includes 20+ tests covering:
- ✓ Default state initialization
- ✓ Navigation (down, up, home, end, vim keys)
- ✓ Mode transitions (List, Create, Rename, ConfirmKill)
- ✓ Help screen toggle
- ✓ Input handling for create and rename modes
- ✓ Error message clearing
- ✓ Current session detection
- ✓ Permission-based actions (rename current only, kill non-current only)
- ✓ Confirmation dialogs
- ✓ Session list updates and index clamping
- ✓ Empty session list handling
- ✓ Session name validation (empty, slash, length)

## Architecture

The plugin is structured as follows:

```
State
├── sessions: Vec<SessionInfo>      // All active sessions
├── selected_index: usize            // Currently selected session
├── mode: Mode                       // Current UI mode
├── colors: Palette                  // Color scheme
├── show_help: bool                  // Help screen visibility
├── new_session_name: Option<String> // Buffer for new session name
├── rename_input: Option<String>     // Buffer for rename input
└── error_message: Option<String>    // Current error message

Mode enum:
├── List         // Main session list view
├── Create       // Create new session dialog
├── Rename       // Rename session dialog
└── ConfirmKill  // Kill confirmation dialog
```

### Event Handling

The plugin subscribes to:
- `EventType::Key` - Keyboard input
- `EventType::SessionUpdate` - Session list changes
- `EventType::ModeUpdate` - Color scheme updates

### Permissions

The plugin requests:
- `ReadApplicationState` - Read session information
- `ChangeApplicationState` - Create, rename, kill, and switch sessions

## Tips

- **Quick switching**: Use `(` and `)` to quickly cycle through sessions without opening the full list
- **Detach shortcut**: Press `d` to quickly detach from the current session
- **Vim navigation**: Use `j`/`k` for faster navigation if you're a vim user
- **Help always available**: Press `?` anytime to see all available keybindings

## Troubleshooting

### Plugin doesn't open

Check your Zellij configuration to ensure the keybinding is set correctly:

```kdl
bind "Alt s" {
    LaunchOrFocusPlugin "tmux-manager" {
        floating true
    }
}
```

### Cannot rename/kill sessions

- **Rename**: You can only rename the current session (marked with `*`)
- **Kill**: You cannot kill the current session. Switch to another session first, then kill the previous one.

### Session name rejected

Ensure your session name:
- Is not empty
- Does not contain `/` characters
- Is shorter than 108 characters

## License

This plugin is part of the Zellij project and follows the same license.

## Contributing

Contributions are welcome! Please submit issues and pull requests to the main Zellij repository.

## Credits

Inspired by tmux's session management interface and designed to provide a familiar experience for tmux users transitioning to Zellij.
