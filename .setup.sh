#!/bin/bash
set -euo pipefail
log() {
    printf "\n==> %s\n" "$1"
}

# Install base packages
install_base() {
    echo -e "\n\t Installing base packages \n"

    # Install based on distro
    DISTRO=$(source /etc/os-release && echo "$ID")
    case "$DISTRO" in
        steamos)
            flatpak uninstall --all -y
            ;;
        ubuntu)
            sudo apt install -y git wget
            ;;
        *)
            echo -e "\t Unsupported system, operation failed... \n"
            exit 1
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
        steamdeck)
            just installs-common
            ;;
        ubuntu)
            just installs-specific
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
