#!/bin/bash

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/utils.sh"

install_build_essentials() {
    info "Installing build essentials..."
    sudo apt update
    sudo apt install -y build-essential curl wget git cmake pkg-config
}

setup_git() {
    info "Setting up Git..."
    
    if ! git config --global user.name >/dev/null 2>&1; then
        read -p "Enter your Git user name: " git_name
        git config --global user.name "$git_name"
    fi
    
    if ! git config --global user.email >/dev/null 2>&1; then
        read -p "Enter your Git email: " git_email
        git config --global user.email "$git_email"
    fi
    
    # Set default branch name
    git config --global init.defaultBranch main
    
    # Useful Git aliases
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.lg "log --oneline --graph --decorate"
    git config --global alias.last "log -1 HEAD"
    git config --global alias.unstage "reset HEAD --"
    
    success "Git configuration complete"
}

install_packages() {
    info "Installing apt packages..."
    
    local packages_file="$SCRIPT_DIR/../ubuntu/packages.txt"
    
    if [ ! -f "$packages_file" ]; then
        error "Packages file not found: $packages_file"
        return 1
    fi
    
    # Read packages from file (skip comment lines)
    local packages=()
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" == \#* ]] && continue
        packages+=("$line")
    done <"$packages_file"
    
    # Install packages
    sudo apt update
    sudo apt install -y "${packages[@]}"
    
    success "Packages installed successfully"
}

install_snaps() {
    info "Installing snap packages..."
    
    local snaps_file="$SCRIPT_DIR/../ubuntu/snaps.txt"
    
    if [ ! -f "$snaps_file" ]; then
        error "Snaps file not found: $snaps_file"
        return 1
    fi
    
    # Read snaps from file (skip comment lines)
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" == \#* ]] && continue
        
        info "Installing snap: $line"
        sudo snap install "$line"
    done <"$snaps_file"
    
    success "Snap packages installed successfully"
}

install_nvm() {
    info "Installing nvm (Node Version Manager)..."
    
    if [ -d "$HOME/.nvm" ]; then
        warning "nvm already installed"
        return 0
    fi
    
    # Install nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    
    success "nvm installed successfully"
}

install_pyenv() {
    info "Installing pyenv..."
    
    if [ -d "$HOME/.pyenv" ]; then
        warning "pyenv already installed"
        return 0
    fi
    
    # Install pyenv dependencies
    sudo apt install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncurses5-dev libncursesw5-dev xz-utils tk-dev
    
    # Install pyenv
    curl https://pyenv.run | bash
    
    success "pyenv installed successfully"
}

install_docker() {
    info "Installing Docker..."
    
    if command -v docker &>/dev/null; then
        warning "Docker already installed"
        return 0
    fi
    
    # Add Docker's official GPG key
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Add Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Add user to docker group
    sudo usermod -aG docker "$USER"
    
    success "Docker installed successfully"
    warning "You may need to log out and log back in for Docker group changes to take effect"
}

if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_build_essentials
    setup_git
    install_packages
    install_snaps
    
    read -p "Install nvm? [y/n] " install_nvm_choice
    [[ "$install_nvm_choice" == "y" ]] && install_nvm
    
    read -p "Install pyenv? [y/n] " install_pyenv_choice
    [[ "$install_pyenv_choice" == "y" ]] && install_pyenv
    
    read -p "Install Docker? [y/n] " install_docker_choice
    [[ "$install_docker_choice" == "y" ]] && install_docker
fi