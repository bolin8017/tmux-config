# Tmux Configuration

A professional tmux configuration with plugin management, cross-platform support, and modern features.

## Features

- **Cross-platform**: Works on Linux (Debian/Ubuntu, RHEL/CentOS/Fedora, Arch, openSUSE, Alpine) and macOS
- **Plugin Management**: Uses TPM (Tmux Plugin Manager)
- **Session Persistence**: Auto-save and restore sessions
- **Modern Theme**: Tokyo Night color scheme
- **Vim-style Navigation**: Familiar keybindings for vim users
- **Mouse Support**: Full mouse interaction support

## Quick Install

```bash
git clone https://github.com/bolin8017/tmux-config.git
cd tmux-config
./install.sh
```

### Install Options

```bash
./install.sh --skip-deps     # Skip system dependency installation
./install.sh --skip-backup   # Skip backing up existing config
./install.sh --force         # Non-interactive installation
./install.sh --help          # Show help
```

## Basic Usage

### Starting tmux

```bash
tmux                          # Start new session with auto-generated name
tmux new -s mysession         # Start new session named "mysession"
tmux new -s work -n editor    # Start session "work" with first window named "editor"
```

### Attaching to Sessions

```bash
tmux ls                       # List all sessions
tmux attach                   # Attach to last session
tmux attach -t mysession      # Attach to specific session "mysession"
tmux a -t mysession           # Short form of attach
```

### Detaching and Killing Sessions

```bash
# Inside tmux:
prefix + d                    # Detach from current session

# From terminal:
tmux detach                   # Detach from current session
tmux kill-session -t mysession # Kill specific session
tmux kill-server              # Kill all sessions
```

### Session Management

```bash
# Inside tmux:
prefix + s                    # Show session list (interactive)
prefix + $                    # Rename current session
prefix + (                    # Switch to previous session
prefix + )                    # Switch to next session
```

## Included Plugins

| Plugin | Description |
|--------|-------------|
| [tpm](https://github.com/tmux-plugins/tpm) | Tmux Plugin Manager |
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | Sensible default settings |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Save/restore tmux sessions |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Auto-save sessions every 15 minutes |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank) | Copy to system clipboard |
| [tmux-open](https://github.com/tmux-plugins/tmux-open) | Quick open URLs/files |
| [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat) | Regex search in copy mode |
| [tmux-pain-control](https://github.com/tmux-plugins/tmux-pain-control) | Pane control enhancements |
| [tmux-prefix-highlight](https://github.com/tmux-plugins/tmux-prefix-highlight) | Show prefix key status |

## Key Bindings

### Prefix Key: `Ctrl + a`

### Window/Pane Management

| Key | Action |
|-----|--------|
| `prefix + \|` | Split horizontally (left/right) |
| `prefix + -` | Split vertically (top/bottom) |
| `prefix + c` | New window |
| `prefix + x` | Kill pane |
| `prefix + X` | Kill window |
| `prefix + D` | Create dev layout |

### Navigation

| Key | Action |
|-----|--------|
| `prefix + h/j/k/l` | Navigate panes (vim-style) |
| `Alt + Arrow` | Navigate panes (no prefix) |
| `Shift + Left/Right` | Switch windows (no prefix) |
| `prefix + Tab` | Last window |

### Pane Resizing

| Key | Action |
|-----|--------|
| `prefix + H/J/K/L` | Resize by 5 units |
| `prefix + Alt + h/j/k/l` | Resize by 1 unit |

### Copy Mode (Vi-style)

| Key | Action |
|-----|--------|
| `prefix + v` or `Alt + v` | Enter copy mode |
| `v` | Start selection |
| `y` | Copy selection |
| `r` | Rectangle toggle |
| `/` | Search |

### tmux-copycat Searches

| Key | Action |
|-----|--------|
| `prefix + /` | Regex search |
| `prefix + Ctrl-f` | Search file paths |
| `prefix + Ctrl-u` | Search URLs |
| `prefix + Ctrl-d` | Search numbers |

### tmux-open (in copy mode)

| Key | Action |
|-----|--------|
| `o` | Open selected URL/file |
| `Ctrl + o` | Open in editor |
| `Shift + s` | Google search |

### tmux-resurrect

| Key | Action |
|-----|--------|
| `prefix + Ctrl-s` | Save session |
| `prefix + Ctrl-r` | Restore session |

### Other

| Key | Action |
|-----|--------|
| `prefix + r` | Reload config |
| `prefix + S` | Toggle pane sync |
| `prefix + >/<` | Swap pane position |
| `prefix + b` | Break pane to window |
| `prefix + m` | Join pane from window |

## Customization

### Adding Custom Configs

Create `~/.tmux.conf.local` for personal overrides (not tracked by git):

```bash
# ~/.tmux.conf.local
# Your custom settings here
```

Then add to end of `~/.tmux.conf`:

```bash
# Load local config if exists
if-shell "test -f ~/.tmux.conf.local" "source ~/.tmux.conf.local"
```

### Changing Theme Colors

Edit the color values in `tmux.conf`:

```bash
# Tokyo Night colors
# Primary: #7aa2f7 (blue)
# Background: #1a1b26 (dark)
# Foreground: #a9b1d6 (light gray)
# Secondary: #3b4261 (gray)
# Accent: #e0af68 (yellow)
```

## Plugin Management

### Install New Plugins

1. Add plugin to `tmux.conf`:
   ```bash
   set -g @plugin 'github-user/plugin-name'
   ```

2. Install: `prefix + I`

### Update Plugins

- Update all: `prefix + U`

### Remove Plugins

1. Remove line from `tmux.conf`
2. Uninstall: `prefix + Alt + u`

## Troubleshooting

### Plugins Not Loading

```bash
# Reinstall TPM
rm -rf ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Reinstall plugins
~/.tmux/plugins/tpm/bin/install_plugins
```

### Colors Not Working

Add to your shell config (`.bashrc`, `.zshrc`):

```bash
export TERM=xterm-256color
```

### Clipboard Not Working (Linux)

Install xclip:

```bash
# Debian/Ubuntu
sudo apt install xclip

# Fedora/RHEL
sudo dnf install xclip

# Arch
sudo pacman -S xclip
```

## Uninstall

```bash
rm -rf ~/.tmux ~/.tmux.conf
```

To restore backup:

```bash
# Find backup directory
ls -la ~ | grep tmux-backup

# Restore
cp ~/.tmux-backup-XXXXXXXX/.tmux.conf ~/
cp -r ~/.tmux-backup-XXXXXXXX/.tmux ~/
```

## License

MIT
