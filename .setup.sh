#!/usr/bin/env bash

# Install Git
install_git() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            fedora)
                sudo dnf install git -y
                ;;
            arch)
                sudo pacman --needed -S git --noconfirm
                ;;
            *)
                echo "Nothing to do here"
                ;;
        esac
    else
        echo "Nothing to do here"
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
mkdir -p ~/.local/bin
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin
source .bashrc

# Install remaining apps
remaining_apps() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            fedora)
                just installs-fedora
                ;;
            arch)
                just installs-arch
                ;;
            *)
                echo "Nothing to do here"
                ;;
        esac
    else
        echo "Nothing to do here"
    fi
}

# Execute all functions
install_git
setup_dotfiles
remaining_apps
