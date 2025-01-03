#!/usr/bin/env bash

# Install Git
install_git() {
    HOST=$HOSTNAME
    if [[ "$HOST" == steamdeck* ]]; then
        echo -e "\n Nothing to do here \n"
    else
        sudo apt install -y git
    fi
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
        steamdeck*|kubuntu*|mint*)
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
