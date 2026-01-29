set quiet

_default:
    just --list

# Installs common applications
installs-common:
    #!/bin/bash
    echo -e "\n\t Installing common applications \n"

    # Ensure app theming
    just setup-themes

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

# Installs distro specific apps
installs-specific:
    #!/bin/bash
    echo -e "\n\t Installing distro specific apps \n"

    # Main packages to install
    DISTRO_PACKAGES=(
        mangohud
        flatpak
        podman
        steam
        ufw
    )

    # Install based on distro
    DISTRO=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')
    case "$DISTRO" in
        ubuntu)
            # Install base packages
            sudo dpkg --add-architecture i386
            sudo apt update && sudo apt install -y "${DISTRO_PACKAGES[@]}"

            # GPU driver handling
            sudo ubuntu-drivers install

            # Firewall handling
            sudo ufw enable
            ;;
        *)
            echo -e "\t Unsupported system, operation failed... \n"
            exit 1
            ;;
    esac

    # Install remaining apps
    just installs-common

# Set up development environment
setup-devenv:
    #!/bin/bash
    echo -e "\n\t Setting up development environment \n"

    # Ensure Github SSH connection
    ssh-keygen -t ed25519 -C 13894059+Krauzer94@users.noreply.github.com
    echo '' && cat ~/.ssh/id_ed25519.pub && echo ''
    git remote set-url origin git@github.com:Krauzer94/dotfiles.git

# Set up application theming
setup-themes:
    #!/bin/bash

    # Create necessary folders
    mkdir -p $HOME/{.themes,.icons}

    # Copy system files over
    cp -r /usr/share/themes/* $HOME/.themes/
    cp -r /usr/share/icons/* $HOME/.icons/

# Upload savegame folder files
[no-cd]
upload-savegame:
    #!/bin/bash

    git add .
    git commit -m "Save game upload"
    git push
