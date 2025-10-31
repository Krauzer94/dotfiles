#!/bin/bash

# Install base packages
install_base() {
    printf "\n\t Installing base packages \n"

    # Install based on distro
    DISTRO=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')
    case "$DISTRO" in
        steamos)
            flatpak uninstall --all -y
            ;;
        debian|linuxmint|ubuntu)
            sudo apt install -y git
            ;;
        *)
            printf "\t Unsupported system, operation failed... \n"
            exit 1
            ;;
    esac
}

# Set up dotfiles
setup_dotfiles() {
    printf "\n\t Setting up the dotfiles \n"

    # Clone and restore files
    git clone https://github.com/Krauzer94/dotfiles.git
    mv ~/dotfiles/.git ~/dotfiles/.gitignore ~/
    rm -rdf ~/dotfiles && git restore .
}

# Install Just CLI
install_just () {
    printf "\n\t Installing just CLI tool \n"

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
        debian|linuxmint|ubuntu)
            just installs-specific
            ;;
        *)
            sudo apt install -y wget
            just setup-devenv
            ;;
    esac
}

# Execute all functions
install_base
setup_dotfiles
install_just
remaining_apps
