#!/bin/bash

# Install base packages
install_base() {
    echo -e "\n\t Installing base packages \n"

    # Install based on distro
    DISTRO=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')
    case "$DISTRO" in
        steamos)
            flatpak uninstall --all -y
            ;;
        fedora)
            if command -v dnf &> /dev/null; then
                sudo dnf install -y git
            else
                flatpak uninstall --all -y
            fi
            ;;
        ubuntu)
            sudo apt update && sudo apt install -y \
                git podman distrobox
            ;;
        arch)
            sudo pacman -S --noconfirm git
            ;;
        *)
            echo -e "\t Unsupported distro, operation failed... \n"
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
        steamdeck*)
            just installs-common
            ;;
        fedora*|ubuntu*|archlinux*)
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
