#!/usr/bin/env bash

# ==============================================================================
# Tmux Configuration Installer
# Cross-platform installation script for Linux and macOS
# ==============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

detect_os() {
    case "$(uname -s)" in
        Linux*)     OS="linux";;
        Darwin*)    OS="macos";;
        CYGWIN*|MINGW*|MSYS*) OS="windows";;
        *)          OS="unknown";;
    esac
    echo "$OS"
}

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    else
        echo "unknown"
    fi
}

detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    elif command -v brew &> /dev/null; then
        echo "brew"
    elif command -v apk &> /dev/null; then
        echo "apk"
    else
        echo "unknown"
    fi
}

# ------------------------------------------------------------------------------
# Installation Functions
# ------------------------------------------------------------------------------

install_dependencies() {
    local os=$1
    local pkg_manager=$2

    print_info "Installing dependencies..."

    case $pkg_manager in
        apt)
            sudo apt-get update
            sudo apt-get install -y tmux git xclip
            ;;
        dnf)
            sudo dnf install -y tmux git xclip
            ;;
        yum)
            sudo yum install -y tmux git xclip
            ;;
        pacman)
            sudo pacman -Sy --noconfirm tmux git xclip
            ;;
        zypper)
            sudo zypper install -y tmux git xclip
            ;;
        brew)
            brew install tmux git reattach-to-user-namespace
            ;;
        apk)
            sudo apk add tmux git xclip
            ;;
        *)
            print_warning "Unknown package manager. Please install tmux and git manually."
            return 1
            ;;
    esac

    print_success "Dependencies installed successfully!"
}

install_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [[ -d "$tpm_dir" ]]; then
        print_info "TPM already installed, updating..."
        cd "$tpm_dir" && git pull
    else
        print_info "Installing Tmux Plugin Manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    fi

    print_success "TPM installed successfully!"
}

backup_existing_config() {
    local backup_dir="$HOME/.tmux-backup-$(date +%Y%m%d_%H%M%S)"

    if [[ -f "$HOME/.tmux.conf" ]]; then
        print_info "Backing up existing tmux config to $backup_dir"
        mkdir -p "$backup_dir"
        cp "$HOME/.tmux.conf" "$backup_dir/"
        [[ -d "$HOME/.tmux" ]] && cp -r "$HOME/.tmux" "$backup_dir/"
        print_success "Backup created at $backup_dir"
    fi
}

install_config() {
    local os=$1

    print_info "Installing tmux configuration..."

    # Create tmux directory
    mkdir -p "$HOME/.tmux"

    # Copy main config
    cp "$SCRIPT_DIR/tmux.conf" "$HOME/.tmux.conf"

    # Copy additional configs
    if [[ -d "$SCRIPT_DIR/tmux" ]]; then
        cp -r "$SCRIPT_DIR/tmux/"* "$HOME/.tmux/"
    fi

    # Apply OS-specific settings
    if [[ "$os" == "macos" ]]; then
        print_info "Applying macOS-specific settings..."
        cat "$SCRIPT_DIR/tmux.macos.conf" >> "$HOME/.tmux.conf"
    fi

    print_success "Configuration installed successfully!"
}

install_plugins() {
    print_info "Installing tmux plugins..."

    # Check if tmux is running
    if tmux list-sessions &> /dev/null; then
        print_info "Tmux is running, installing plugins in background..."
        "$HOME/.tmux/plugins/tpm/bin/install_plugins"
    else
        print_info "Starting tmux server to install plugins..."
        tmux start-server
        tmux new-session -d -s plugin_install
        "$HOME/.tmux/plugins/tpm/bin/install_plugins"
        tmux kill-session -t plugin_install 2>/dev/null || true
    fi

    print_success "Plugins installed successfully!"
}

# ------------------------------------------------------------------------------
# Main Installation Process
# ------------------------------------------------------------------------------

main() {
    echo ""
    echo "======================================"
    echo "   Tmux Configuration Installer"
    echo "======================================"
    echo ""

    # Detect environment
    OS=$(detect_os)
    DISTRO=$(detect_distro)
    PKG_MANAGER=$(detect_package_manager)

    print_info "Detected OS: $OS"
    [[ "$OS" == "linux" ]] && print_info "Detected Distro: $DISTRO"
    print_info "Detected Package Manager: $PKG_MANAGER"
    echo ""

    # Check if running on supported OS
    if [[ "$OS" == "unknown" || "$OS" == "windows" ]]; then
        print_error "Unsupported operating system: $OS"
        print_info "This script supports Linux and macOS only."
        print_info "For Windows, please use WSL (Windows Subsystem for Linux)."
        exit 1
    fi

    # Parse arguments
    SKIP_DEPS=false
    SKIP_BACKUP=false
    FORCE=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-deps)
                SKIP_DEPS=true
                shift
                ;;
            --skip-backup)
                SKIP_BACKUP=true
                shift
                ;;
            --force|-f)
                FORCE=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --skip-deps     Skip installing system dependencies"
                echo "  --skip-backup   Skip backing up existing configuration"
                echo "  --force, -f     Force installation without prompts"
                echo "  --help, -h      Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    # Confirmation prompt
    if [[ "$FORCE" != true ]]; then
        echo "This will install:"
        echo "  - Tmux (if not installed)"
        echo "  - Tmux Plugin Manager (TPM)"
        echo "  - Custom tmux configuration"
        echo "  - Essential tmux plugins"
        echo ""
        read -p "Continue? [y/N] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled."
            exit 0
        fi
    fi

    # Step 1: Install dependencies
    if [[ "$SKIP_DEPS" != true ]]; then
        install_dependencies "$OS" "$PKG_MANAGER"
    else
        print_info "Skipping dependency installation..."
    fi

    # Step 2: Backup existing config
    if [[ "$SKIP_BACKUP" != true ]]; then
        backup_existing_config
    else
        print_info "Skipping backup..."
    fi

    # Step 3: Install TPM
    install_tpm

    # Step 4: Install configuration
    install_config "$OS"

    # Step 5: Install plugins
    install_plugins

    # Done!
    echo ""
    echo "======================================"
    print_success "Installation complete!"
    echo "======================================"
    echo ""
    echo "To start using tmux:"
    echo "  1. Start a new terminal session"
    echo "  2. Run: tmux"
    echo ""
    echo "Quick reference:"
    echo "  Prefix key: Ctrl+a"
    echo "  Reload config: prefix + r"
    echo "  Split horizontal: prefix + |"
    echo "  Split vertical: prefix + -"
    echo ""
    echo "For more keybindings, see the README.md"
    echo ""
}

main "$@"
