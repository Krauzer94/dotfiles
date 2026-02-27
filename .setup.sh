#!/bin/bash
set -euo pipefail
log() { printf "\n==> %s\n" "$1"; }

# Global variables
DISTRO="$(. /etc/os-release && echo "$ID")"
HOST="${HOSTNAME:-$(hostname)}"

# Install base packages
installs_base() {
    log "Installing base packages"

    # Install based on distro
    case "$DISTRO" in
        steamos)
            flatpak uninstall --all -y
            ;;
        ubuntu|debian)
            sudo apt-get install -y git wget
            ;;
        *)
            log "Unsupported system, operation failed"
            exit 1
            ;;
    esac
}

# Set up dotfiles
setup_dotfiles() {
    log "Setting up the dotfiles"

    # Clone and restore files
    git clone https://github.com/Krauzer94/dotfiles.git
    mv ~/dotfiles/.git ~/dotfiles/.gitignore ~/
    rm -rdf ~/dotfiles && git restore .
}

# Set up application theming
setup_themes() {
    # Create necessary folders
    mkdir -p $HOME/{.themes,.icons}

    # Copy system files over
    cp -r /usr/share/themes/* $HOME/.themes/
    cp -r /usr/share/icons/* $HOME/.icons/
}

# Install remaining apps
remaining_apps() {
    # Install based on hostname
    case "$HOST" in
        steamdeck)
            installs_common
            ;;
        ubuntu|debian)
            installs_specific
            ;;
        *)
            setup_devenv
            exit 1
            ;;
    esac
}

# Installs common applications
installs_common() {
    log "Installing common applications"

    # Flatpak apps to install
    FLATPAK_APPS=(
        com.dec05eba.gpu_screen_recorder
        com.discordapp.Discord
        com.github.tchx84.Flatseal
        com.google.Chrome
        com.rtosta.zapzap
        com.spotify.Client
        com.stremio.Stremio
        com.visualstudio.code
        io.github.flattool.Warehouse
        io.missioncenter.MissionCenter
        net.davidotek.pupgui2
        org.bleachbit.BleachBit
        org.flameshot.Flameshot
        org.gimp.GIMP
        org.kde.gwenview
        org.kde.kcalc
        org.mozilla.firefox
        org.onlyoffice.desktopeditors
        org.qbittorrent.qBittorrent
        org.videolan.VLC
    )

    # Install all Flatpaks
    flatpak install -y --noninteractive flathub "${FLATPAK_APPS[@]}" > /dev/null
}

# Installs distro specific apps
installs_specific() {
    log "Installing distro specific apps"

    # Main packages to install
    DISTRO_PACKAGES=(
        mangohud
        flatpak
        steam
        ufw
    )

    # NVIDIA driver packages
    NVIDIA_PACKAGES=(
        nvidia-open-kernel-dkms
        firmware-misc-nonfree
        linux-headers-amd64
        nvidia-driver
    )

    # Shared bootstraping
    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get install -y "${DISTRO_PACKAGES[@]}"
    sudo ufw enable

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            sudo ubuntu-drivers install
            ;;
        debian)
            sudo apt-get install -y "${NVIDIA_PACKAGES[@]}"
            ;;
        *)
            log "Unsupported system, operation failed"
            exit 1
            ;;
    esac

    # Install remaining apps
    installs_common
}

# Set up development environment
setup_devenv() {
    log "Setting up development environment"

    # User specific environment
    mkdir -p "$HOME/.local/bin"

    # Installing the latest NVM
    if [[ "$DISTRO" != "steamos" ]]; then
        NVM_LATEST=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest \
        | grep '"tag_name"' \
        | cut -d '"' -f 4)
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_LATEST/install.sh | bash
    fi

    # Ensure Github SSH connection
    ssh-keygen -t ed25519 -C 13894059+Krauzer94@users.noreply.github.com
    log "Generated SSH key"
    cat ~/.ssh/id_ed25519.pub
    git remote set-url origin git@github.com:Krauzer94/dotfiles.git
}

# Execute all routines
main() {
    installs_base
    setup_dotfiles
    remaining_apps
    setup_themes
}

# Enable function calling
if [[ "$#" -eq 0 ]]; then
    main
else
    for fn in "$@"; do
        if declare -F "$fn" >/dev/null; then
            log "Running $fn"
            "$fn"
        else
            log "Error: function '$fn' not found" >&2
            exit 1
        fi
    done
fi
