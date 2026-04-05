#!/bin/bash

set -e

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/scripts/utils.sh"

# Default OS value
OS="mac"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --os)
            OS="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --os <os>     Operating system to install for (mac|ubuntu). Default: mac"
            echo "  --help, -h    Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                  # Install for macOS (default)"
            echo "  $0 --os mac         # Install for macOS (explicit)"
            echo "  $0 --os ubuntu      # Install for Ubuntu"
            exit 0
            ;;
        *)
            error "Unknown argument: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Validate OS parameter
if [[ ! "$OS" =~ ^(mac|ubuntu)$ ]]; then
    error "Invalid OS '$OS'. Use 'mac' or 'ubuntu'."
    exit 1
fi

info "Dotfiles installation initialized for $OS..."
info "Detected operating system: $(uname -s)"

# Source OS-specific installation script
case "$OS" in
    mac)
        . "$SCRIPT_DIR/scripts/install-mac.sh"
        ;;
    ubuntu)
        . "$SCRIPT_DIR/scripts/install-ubuntu.sh"
        ;;
esac

# Interactive prompts
read -p "Install apps? [y/n] " install_apps
read -p "Overwrite existing dotfiles? [y/n] " overwrite_dotfiles

# Execute OS-specific installation
case "$OS" in
    mac)
        install_mac "$install_apps" "$overwrite_dotfiles"
        ;;
    ubuntu)
        install_ubuntu "$install_apps" "$overwrite_dotfiles"
        ;;
esac