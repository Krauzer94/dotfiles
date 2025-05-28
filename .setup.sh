#!/usr/bin/env bash

# Install base packages
install_base() {
    HOST=$HOSTNAME
    case "$HOST" in
        bazzite*|steamdeck*|fedora*)
            flatpak uninstall --all -y
            ;;
        *)
            sudo dnf install -y \
                git distrobox docker wget
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
        bazzite*|steamdeck*)
            just installs-common
            ;;
        fedora*)
            just installs-fedora
            ;;
        *)
            sudo usermod -aG docker $USER
            just setup-github
            ;;
    esac
}

# Execute all functions
install_base
setup_dotfiles
install_just
remaining_apps
