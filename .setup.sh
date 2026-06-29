#!/bin/bash
set -euo pipefail
log() { printf "\n==> %s\n" "$1"; }

# Global variables
DISTRO="$(. /etc/os-release && echo "$ID")"
HOST="${HOSTNAME:-$(hostname)}"

# Install base packages
installs_base() {
    log "Installing base packages"

    # Base packages to install
    local PKGS=( wget git )

    # Install based on distro
    case "$DISTRO" in
        steamos)
            flatpak uninstall --all -y
            ;;
        ubuntu)
            sudo apt install -y "${PKGS[@]}"
            ;;
        arch)
            sudo pacman -Syu --needed --noconfirm "${PKGS[@]}"
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
    mv $HOME/dotfiles/.git $HOME/dotfiles/.gitignore $HOME/
    rm -rdf $HOME/dotfiles && git restore .
}

# Install remaining apps
remaining_apps() {
    # Install based on hostname
    case "$HOST" in
        steamdeck)
            installs_common
            ;;
        ubuntu|archlinux)
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
        be.alexandervanhee.gradia
        com.dec05eba.gpu_screen_recorder
        com.discordapp.Discord
        com.github.tchx84.Flatseal
        com.google.Chrome
        com.rtosta.zapzap
        com.spotify.Client
        com.stremio.Stremio
        com.visualstudio.code
        com.vysp3r.ProtonPlus
        io.github.flattool.Warehouse
        io.missioncenter.MissionCenter
        org.bleachbit.BleachBit
        org.gimp.GIMP
        org.gnome.Calculator
        org.gnome.Loupe
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
    local PAKGS=( mangohud steam ufw )
    local SERVS=( NetworkManager bluetooth )

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            sudo dpkg --add-architecture i386 && sudo apt update
            sudo apt install -y "${PAKGS[@]}"
            ;;
        arch)
            sudo pacman -Syu --needed --noconfirm "${PAKGS[@]}"
            sudo systemctl enable --now "${SERVS[@]}"
            ;;
        *)
            log "Unsupported system, operation failed"
            exit 1
            ;;
    esac

    # Enable firewall
    sudo ufw enable

    # Remaining apps
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
    cat $HOME/.ssh/id_ed25519.pub
    git remote set-url origin git@github.com:Krauzer94/dotfiles.git
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
