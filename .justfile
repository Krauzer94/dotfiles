set quiet

_default:
    just --list

# Installs common applications
installs-common:
    #!/bin/bash
    echo -e "\n\t Installing common applications \n"

    # Ensure app theming
    just setup-themes

    # Install all Flatpaks
    flatpak install -y --noninteractive flathub \
        be.alexandervanhee.gradia \
        com.dec05eba.gpu_screen_recorder \
        com.discordapp.Discord \
        com.github.tchx84.Flatseal \
        com.google.Chrome \
        com.rtosta.zapzap \
        com.spotify.Client \
        com.stremio.Stremio \
        com.visualstudio.code \
        io.github.flattool.Warehouse \
        io.missioncenter.MissionCenter \
        net.davidotek.pupgui2 \
        org.bleachbit.BleachBit \
        org.flameshot.Flameshot \
        org.gimp.GIMP \
        org.kde.kcalc \
        org.mozilla.firefox \
        org.onlyoffice.desktopeditors \
        org.qbittorrent.qBittorrent \
        org.videolan.VLC > /dev/null

# Installs the Docker application
installs-docker:
    #!/bin/bash
    echo -e "\n\t Installing the Docker application \n"

    # Main packages to install
    DOCKER_PACKAGES="\
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin"

    # Install based on distro
    DISTRO=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')
    case "$DISTRO" in
        debian|ubuntu)
            # Ensure all dependencies
            sudo apt update && sudo apt install -y \
                apt-transport-https \
                ca-certificates \
                gnupg

            # Enable the Docker repo
            curl -fsSL https://download.docker.com/linux/$DISTRO/gpg \
                | sudo tee /etc/apt/trusted.gpg.d/docker.asc
            echo "deb [arch=amd64] https://download.docker.com/linux/$DISTRO $(lsb_release -cs) stable" \
                | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            # Install Docker packages
            sudo apt update && sudo apt install -y $DOCKER_PACKAGES
            ;;
        *)
            echo -e "\t Unsupported system, operation failed... \n"
            exit 1
            ;;
    esac

    # Post install configuration
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER

# Installs distro specific apps
installs-specific:
    #!/bin/bash
    echo -e "\n\t Installing distro specific apps \n"

    # Main packages to install
    DISTRO_PACKAGES="ufw flatpak mangohud steam"

    # Install based on distro
    DISTRO=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')
    case "$DISTRO" in
        debian|ubuntu)
            # Install base packages
            sudo dpkg --add-architecture i386
            sudo apt update && sudo apt install -y $DISTRO_PACKAGES

            # GNOME specific section
            if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]]; then
                sudo apt install -y gnome-software-plugin-flatpak
                flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            else
                sudo apt install -y ark
            fi

            # Non-free GPU Drivers
            if [[ "$DISTRO" == "debian" ]]; then
                sudo apt install -y \
                    linux-headers-$(dpkg --print-architecture) \
                    nvidia-open-kernel-dkms \
                    firmware-misc-nonfree \
                    nvidia-driver
            fi
            ;;
        *)
            echo -e "\t Unsupported system, operation failed... \n"
            exit 1
            ;;
    esac

    # Enable firewall
    sudo ufw enable

    # Install remaining apps
    just installs-common

# Installs Sunshine application
installs-sunshine:
    #!/bin/bash
    echo -e "\n\t Installing Sunshine application \n"

    # Firewall port configuration
    for port in 47984 47989 47990 48010; do
        sudo ufw allow ${port}/tcp
    done
    sudo ufw allow 47998:48000/udp
    sudo ufw reload

    # Install based on distro
    DISTRO=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')
    case "$DISTRO" in
        debian|ubuntu)
            # Ensure compatibility
            if [[ "$DISTRO" == "debian" ]]; then
                DISTRO_VERSION="${DISTRO}-$(lsb_release -cs)"
            else
                DISTRO_VERSION="${DISTRO}-$(lsb_release -rs)"
            fi

            # Find the latest installer
            GITHUB_URL="https://api.github.com/repos/LizardByte/Sunshine/releases/latest"
            DEB_URL=$(curl -s "$GITHUB_URL" | grep browser_download_url | grep "$DISTRO_VERSION" | grep "amd64\.deb" | cut -d '"' -f 4)

            # Download, install and clean
            FILENAME=$(basename "$DEB_URL")
            wget -q --show-progress "$DEB_URL" -O "/tmp/$FILENAME"
            sudo apt install -y "/tmp/$FILENAME"
            rm "/tmp/$FILENAME"
            ;;
        *)
            echo -e "\t Unsupported system, operation failed... \n"
            exit 1
            ;;
    esac

    # Enable WoL on startup
    WIFI_CONN=$(nmcli -t -f NAME,TYPE con show | grep wireless | cut -d: -f1 | head -n 1)
    nmcli con modify "$WIFI_CONN" 802-11-wireless.wake-on-wlan magic

# Set up development environment
setup-devenv:
    #!/bin/bash
    echo -e "\n\t Setting up development environment \n"

    # Install essential CLI tools
    curl -sfL https://direnv.net/install.sh | bash
    curl https://mise.run | sh

    # Ensure Github SSH connection
    ssh-keygen -t ed25519 -C 13894059+Krauzer94@users.noreply.github.com
    echo '' && cat ~/.ssh/id_ed25519.pub && echo ''
    git remote set-url origin git@github.com:Krauzer94/dotfiles.git

# Set up Tailscale on the Deck
setup-taildeck:
    #!/bin/bash
    echo -e "\n\t Setting up Tailscale on the Deck \n"

    # Install based on distro
    DISTRO=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')
    case "$DISTRO" in
        steamos)
            # Download necessary files
            git clone git@github.com:tailscale-dev/deck-tailscale.git
            cd ./deck-tailscale

            # Install and source binary
            sudo bash ./tailscale.sh
            source /etc/profile.d/tailscale.sh
            ;;
        *)
            echo -e "\t Unsupported system, operation failed... \n"
            exit 1
            ;;
    esac

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
