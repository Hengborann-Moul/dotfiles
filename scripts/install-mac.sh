#!/bin/bash

# macOS-specific installation script
# This script is sourced by install.sh when --os mac is specified

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/utils.sh"
. "$SCRIPT_DIR/prerequisites-mac.sh"
. "$SCRIPT_DIR/brew-install-custom.sh"
. "$SCRIPT_DIR/osx-defaults.sh"
. "$SCRIPT_DIR/symlinks.sh"

install_mac() {
    local install_apps="$1"
    local overwrite_dotfiles="$2"
    
    if [[ "$install_apps" == "y" ]]; then
        printf "\n"
        info "===================="
        info "Prerequisites"
        info "===================="
        
        install_xcode
        install_homebrew
        
        printf "\n"
        info "===================="
        info "Apps"
        info "===================="
        
        install_custom_formulae
        install_custom_casks
        run_brew_bundle
    fi
    
    printf "\n"
    info "===================="
    info "OSX System Defaults"
    info "===================="
    
    register_keyboard_shortcuts
    apply_osx_system_defaults
    
    printf "\n"
    info "===================="
    info "Terminal"
    info "===================="
    
    info "Adding .hushlogin file to suppress 'last login' message in terminal..."
    touch ~/.hushlogin
    
    printf "\n"
    info "===================="
    info "Symbolic Links"
    info "===================="
    
    chmod +x "$SCRIPT_DIR/symlinks.sh"
    if [[ "$overwrite_dotfiles" == "y" ]]; then
        warning "Deleting existing dotfiles..."
        "$SCRIPT_DIR/symlinks.sh" --delete --include-files --os mac
    fi
    "$SCRIPT_DIR/symlinks.sh" --create --os mac
    
    success "macOS dotfiles set up successfully."
}

# Run if called directly
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_xcode
    install_homebrew
    install_custom_formulae
    install_custom_casks
    run_brew_bundle
    register_keyboard_shortcuts
    apply_osx_system_defaults
    touch ~/.hushlogin
fi