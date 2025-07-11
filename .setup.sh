#!/bin/bash

# Install base packages
install_base() {
    HOST=$HOSTNAME
    case "$HOST" in
        steamdeck*)
            flatpak uninstall --all -y
            ;;
        fedora*)
            sudo dnf install -y git
            ;;
        archlinux*)
            sudo pacman -Syu git
            ;;
        *)
            sudo apt update && sudo apt install -y \
                git distrobox podman wget
            ;;
    esac
}

# Set up dotfiles
setup_dotfiles() {
    git clone https://github.com/Krauzer94/dotfiles.git
    mv ~/dotfiles/.git ~/dotfiles/.gitignore ~/
    rm -rdf ~/dotfiles && git restore .
}

# Install Just CLI
install_just () {
    mkdir -p ~/.local/bin
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin
    export PATH=$PATH:~/.local/bin
}

# Install remaining apps
remaining_apps() {
    HOST=$HOSTNAME
    case "$HOST" in
        steamdeck*)
            just installs-common
            ;;
        fedora*)
            just installs-fedora
            ;;
        archlinux*)
            just installs-archlinux
            ;;
        *)
            just setup-devenv
            ;;
    esac
}

# Execute all functions
install_base
setup_dotfiles
install_just
remaining_apps
