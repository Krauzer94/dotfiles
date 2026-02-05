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
        ubuntu)
            sudo apt install -y git wget
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

# Installs common applications
installs_common() {
    log "Installing common applications"

    # Ensure app theming
    setup_themes

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

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            sudo dpkg --add-architecture i386
            sudo apt update
            sudo apt install -y "${DISTRO_PACKAGES[@]}"
            sudo ubuntu-drivers install
            sudo ufw enable
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

    # Installing NVM and Node
    if [[ "$DISTRO" == "ubuntu" ]]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    fi

    # Ensure Github SSH connection
    ssh-keygen -t ed25519 -C 13894059+Krauzer94@users.noreply.github.com
    log "Generated SSH key"
    cat ~/.ssh/id_ed25519.pub
    git remote set-url origin git@github.com:Krauzer94/dotfiles.git
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
        ubuntu)
            installs_specific
            ;;
        *)
            setup_devenv
            ;;
    esac
}

# Execute all routines
main() {
    installs_base
    setup_dotfiles
    remaining_apps
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
