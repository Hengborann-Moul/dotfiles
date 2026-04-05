#!/bin/bash

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/../scripts/utils.sh"

apply_gnome_defaults() {
    info "Applying GNOME system defaults..."

    # Interface settings
    gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    gsettings set org.gnome.desktop.interface clock-format '24h'
    gsettings set org.gnome.desktop.interface clock-show-weekday true
    gsettings set org.gnome.desktop.interface show-battery-percentage true
    
    # Nautilus (File Manager)
    gsettings set org.gnome.nautilus.preferences show-hidden-files true
    gsettings set org.gnome.nautilus.preferences default-view 'list-view'
    gsettings set org.gnome.nautilus.list-view use-tree-view true
    gsettings set org.gnome.nautilus.preferences show-delete-permanently true
    gsettings set org.gnome.nautilus.preferences show-create-link true
    
    # Screenshot settings
    gsettings set org.gnome.shell.screenshot last-save-directory "file://$HOME/Pictures/Screenshots"
    
    # Terminal settings (if using GNOME Terminal)
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1ffc9c0-cdcd-45ca-9c4e-65c6b3b02e25/ use-system-font false
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1ffc9c0-cdcd-45ca-9c4e-65c6b3b02e25/ use-theme-font false
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1ffc9c0-cdcd-45ca-9c4e-65c6b3b02e25/ font 'JetBrainsMono Nerd Font 12'
    
    # Power management
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'suspend'
    
    # Workspaces
    gsettings set org.gnome.desktop.wm.preferences num-workspaces 4
    gsettings set org.gnome.shell.overrides dynamic-workspaces false
    
    # Keyboard shortcuts for window management (GNOME Extensions-style)
    # These work with default GNOME window tiling
    gsettings set org.gnome.desktop.wm.keybindings maximize "['<Super>Up']"
    gsettings set org.gnome.desktop.wm.keybindings unmaximize "['<Super>Down']"
    gsettings set org.gnome.desktop.wm.keybindings begin-move "['<Alt>space']"
    gsettings set org.gnome.desktop.wm.keybindings begin-resize "['<Alt>space']"
    
    # Privacy settings
    gsettings set org.gnome.desktop.privacy remember-recent-files false
    gsettings set org.gnome.desktop.privacy remove-old-temp-files true
    gsettings set org.gnome.desktop.privacy remove-old-trash-files true
    
    # Mouse and touchpad
    gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false
    gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
    gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
    
    # Disable annoying features
    gsettings set org.gnome.desktop.interface enable-animations false
    
    # Dock/Favorites (Ubuntu-specific)
    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.shell favorite-apps "['org.gnome.Terminal.desktop', 'code.desktop', 'org.gnome.Nautilus.desktop', 'brave-browser.desktop']"
    fi
    
    success "GNOME defaults applied successfully"
}

if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    apply_gnome_defaults
fi