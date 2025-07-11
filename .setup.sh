#!/bin/bash

# Install base packages
install_base() {
    echo -e "\n Installing base packages \n"
    HOST=$HOSTNAME
    case "$HOST" in
        bazzite*|steamdeck*)
            flatpak uninstall --all -y
            ;;
        fedora*)
            sudo dnf install -y git
            ;;
        *)
            sudo apt update && sudo apt install -y \
                git distrobox podman wget
            ;;
    esac
    echo -e "\n Finished installing base packages \n"
}

# Set up dotfiles
setup_dotfiles() {
    echo -e "\n Setting up the dotfiles \n"
    git clone https://github.com/Krauzer94/dotfiles.git
    mv ~/dotfiles/.git ~/dotfiles/.gitignore ~/
    rm -rdf ~/dotfiles && git restore .
    echo -e "\n Finished setting up the dotfiles \n"
}

# Install Just CLI
install_just () {
    echo -e "\n Installing just CLI tool \n"
    mkdir -p ~/.local/bin
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin
    export PATH=$PATH:~/.local/bin
    echo -e "\n Finished installing just CLI tool \n"
}

# Install remaining apps
remaining_apps() {
    echo -e "\n Installing remaining apps \n"
    HOST=$HOSTNAME
    case "$HOST" in
        bazzite*|steamdeck*)
            just installs-common
            ;;
        fedora*)
            just installs-fedora
            ;;
        *)
            just setup-devenv
            ;;
    esac
    echo -e "\n Finished installing remaining apps \n"
}

# Execute all functions
install_base
setup_dotfiles
install_just
remaining_apps
