#!/bin/bash

# Ubuntu-specific installation script
# This script is sourced by install.sh when --os ubuntu is specified

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/utils.sh"
. "$SCRIPT_DIR/prerequisites-ubuntu.sh"
. "$SCRIPT_DIR/../ubuntu/gsettings.sh"
. "$SCRIPT_DIR/symlinks.sh"

install_ubuntu() {
    local install_apps="$1"
    local overwrite_dotfiles="$2"
    
    if [[ "$install_apps" == "y" ]]; then
        printf "\n"
        info "===================="
        info "Prerequisites"
        info "===================="
        
        install_build_essentials
        setup_git
        
        printf "\n"
        info "===================="
        info "Packages"
        info "===================="
        
        install_packages
        install_snaps
        
        printf "\n"
        info "===================="
        info "Development Tools"
        info "===================="
        
        read -p "Install nvm (Node Version Manager)? [y/n] " install_nvm_choice
        [[ "$install_nvm_choice" == "y" ]] && install_nvm
        
        read -p "Install pyenv? [y/n] " install_pyenv_choice
        [[ "$install_pyenv_choice" == "y" ]] && install_pyenv
        
        read -p "Install Docker? [y/n] " install_docker_choice
        [[ "$install_docker_choice" == "y" ]] && install_docker
    fi
    
    printf "\n"
    info "===================="
    info "GNOME Settings"
    info "===================="
    
    apply_gnome_defaults
    
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
        "$SCRIPT_DIR/symlinks.sh" --delete --include-files --os ubuntu
    fi
    "$SCRIPT_DIR/symlinks.sh" --create --os ubuntu
    
    success "Ubuntu dotfiles set up successfully."
}

# Run if called directly
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_build_essentials
    setup_git
    install_packages
    install_snaps
    install_nvm
    install_pyenv
    install_docker
    apply_gnome_defaults
    touch ~/.hushlogin
fi