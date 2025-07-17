#!/bin/bash

# Install base packages
install_base() {
    echo -e "\n\t Installing base packages \n"

    # Install based on hostname
    HOST=$HOSTNAME
    case "$HOST" in
        steamdeck*)
            flatpak uninstall --all -y
            ;;
        fedora*)
            sudo dnf install -y git
            ;;
        *)
            sudo apt update && sudo apt install -y \
                git podman distrobox
            ;;
    esac
}

# Set up dotfiles
setup_dotfiles() {
    echo -e "\n\t Setting up the dotfiles \n"

    # Clone and restore files
    git clone https://github.com/Krauzer94/dotfiles.git
    mv ~/dotfiles/.git ~/dotfiles/.gitignore ~/
    rm -rdf ~/dotfiles && git restore .
}

# Install Just CLI
install_just () {
    echo -e "\n\t Installing just CLI tool \n"

    # Ensure binary in $PATH
    mkdir -p ~/.local/bin
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin
    export PATH=$PATH:~/.local/bin
}

# Install remaining apps
remaining_apps() {
    # Install based on hostname
    HOST=$HOSTNAME
    case "$HOST" in
        steamdeck*)
            just installs-common
            ;;
        fedora*)
            just installs-fedora
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
