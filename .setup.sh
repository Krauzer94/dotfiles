#!/usr/bin/env bash

# Install Git
install_git() {
    HOST=$HOSTNAME

    case "$HOST" in
        archlinux*)
            sudo pacman -Syu --needed --noconfirm git
            ;;
        nixos*)
            echo -e "\n Nothing to do here \n"
            ;;
        steamdeck*)
            echo -e "\n Nothing to do here \n"
            ;;
        *)
            sudo \
                pacman-key --init \
                pacman-key --populate \
                pacman -Sy --noconfim archlinux-keyring \
                pacman -Syu --noconfim
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
        archlinux*)
            just installs-arch
            ;;
        nixos*)
            just installs-nixos
            ;;
        steamdeck*)
            just installs-steamos
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
