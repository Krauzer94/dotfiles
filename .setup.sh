#!/usr/bin/env bash

# Install base packages
install_base() {
    HOST=$HOSTNAME
    case "$HOST" in
        steamdeck*|mswindows*)
            echo -e "\n Nothing to do here \n"
            ;;
        kubuntu*)
            sudo apt update && sudo apt install -y \
                git mangohud steam-installer
            ;;
        *)
            sudo apt update && sudo apt install -y \
                git openssh-client wget podman
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
        steamdeck*|kubuntu*)
            just installs-common
            ;;
        mswindows*)
            cp ~/.local/bin/just.exe /c/Windows
            scoop import ~/.scoop.json
            ;;
        *)
            just setup-github
            ;;
    esac
}

# Execute all functions
install_base
setup_dotfiles
install_just
remaining_apps
