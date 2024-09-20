#!/usr/bin/env bash

# Install Git
install_git() {
    HOST=$HOSTNAME

    case "$HOST" in
        fedora*)
            sudo dnf install git -y
            ;;
        mint*)
            sudo apt install git -y
            ;;
        steamdeck*)
            echo -e "\n Nothing to do here \n"
            ;;
        *)
            sudo dnf update -y
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
        fedora*)
            just installs-fedora
            ;;
        mint*)
            just installs-mint
            ;;
        steamdeck*)
            just installs-steamos
            ;;
        *)
            sudo ln -s ~/.wsl.conf /etc/wsl.conf
            just setup-githup
            ;;
    esac
}

# Execute all functions
install_git
setup_dotfiles
install_just
remaining_apps
