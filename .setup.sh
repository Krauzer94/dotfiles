#!/usr/bin/env bash

# Install Git
install_git() {
    HOST=$(hostname)

    case "$HOST" in
        fedora*)
            sudo dnf install git -y
            ;;
        archlinux*)
            sudo pacman --needed -S git --noconfirm
            ;;
        steamdeck*)
            echo "SteamOS detected, git is already pre-installed"
            ;;
        *)
            echo "Unknown Linux distro"
            ;;
    esac
}

# Set up dotfiles
setup_dotfiles() {
    echo '*' > ~/.gitignore
    mv ~/.bashrc ~/.bashrc.old
    git clone https://github.com/Krauzer94/dotfiles.git
    mv ~/dotfiles/.git ~/
    rm -rdf ~/dotfiles
    git restore .
}

# Install Just
install_just () {
    mkdir -p ~/.local/bin
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin
    source ~/.bashrc
}

# Install remaining apps
remaining_apps() {
    HOST=$(hostname)

    case "$HOST" in
        fedora)
            just installs-fedora
            ;;
        archlinux)
            just installs-arch
            ;;
        steamdeck*)
            just installs-steamos
            ;;
        *)
            echo "Unknown Linux distro"
            ;;
    esac
}

# Execute all functions
install_git
setup_dotfiles
install_just
remaining_apps
