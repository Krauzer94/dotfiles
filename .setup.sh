#!/usr/bin/env bash

# Install Git
install_git() {
    HOST=$HOSTNAME
    case "$HOST" in
        steamdeck*)
            echo -e "\n Nothing to do here \n"
            ;;
        archlinux*)
            sudo pacman -Syu --needed --noconfirm git
            ;;
        fedora*)
            sudo dnf install -y git
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
    export PATH=$PATH:~/.local/bin
}

# Install remaining apps
remaining_apps() {
    HOST=$HOSTNAME
    case "$HOST" in
        steamdeck*|archlinux*|fedora*)
            just installs-common
            ;;
        *)
            just setup-github
            ;;
    esac
}

# Execute all functions
install_git
setup_dotfiles
install_just
remaining_apps
