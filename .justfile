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
        org.mozilla.firefox \
        org.gimp.GIMP \
        org.qbittorrent.qBittorrent \
        be.alexandervanhee.gradia \
        com.stremio.Stremio \
        org.bleachbit.BleachBit \
        com.spotify.Client \
        com.google.Chrome \
        org.onlyoffice.desktopeditors \
        com.discordapp.Discord \
        com.rtosta.zapzap \
        com.github.tchx84.Flatseal \
        net.davidotek.pupgui2 \
        com.ranfdev.DistroShelf \
        com.visualstudio.code \
        org.videolan.VLC \
        org.kde.kcalc \
        io.github.flattool.Warehouse \
        io.missioncenter.MissionCenter \
        com.dec05eba.gpu_screen_recorder > /dev/null

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
        fedora)
            sudo dnf install -y dnf-plugins-core
            sudo dnf config-manager --add-repo \
                https://download.docker.com/linux/$DISTRO/docker-ce.repo
            sudo dnf install -y $DOCKER_PACKAGES
            ;;
        debian)
            sudo apt update && sudo apt install -y \
                software-properties-common \
                apt-transport-https \
                ca-certificates \
                gnupg

            curl -fsSL https://download.docker.com/linux/$DISTRO/gpg \
                | sudo tee /etc/apt/trusted.gpg.d/docker.asc
            echo "deb [arch=amd64] https://download.docker.com/linux/$DISTRO $(lsb_release -cs) stable" \
                | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            sudo apt update && sudo apt install -y $DOCKER_PACKAGES
            ;;
        *)
            echo -e "\t Unsupported distro, operation failed... \n"
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
    DISTRO_PACKAGES="podman distrobox mangohud steam"

    # Install based on distro
    DISTRO=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')
    case "$DISTRO" in
        fedora)
            sudo dnf install -y $DISTRO_PACKAGES
            ;;
        debian)
            sudo dpkg --add-architecture i386
            sudo apt update && sudo apt install -y $DISTRO_PACKAGES ufw

            # Enable firewal
            sudo ufw enable

            # GNOME specific section
            if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]]; then
                sudo apt install -y flatpak gnome-software-plugin-flatpak
                flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            fi

            # Non-free GPU Drivers
            sudo apt install -y \
                linux-headers-$(dpkg --print-architecture) \
                firmware-misc-nonfree \
                nvidia-kernel-dkms \
                nvidia-driver
            ;;
        *)
            echo -e "\t Unsupported distro, operation failed... \n"
            exit 1
            ;;
    esac

    # Install remaining apps
    just installs-common

# Installs Sunshine application
installs-sunshine:
    #!/bin/bash
    echo -e "\n\t Installing Sunshine application \n"

    # Firewall port configuration
    if command -v ufw &> /dev/null; then
        for port in 47984 47989 47990 48010; do
            sudo ufw allow ${port}/tcp
        done
        sudo ufw allow 47998:48000/udp
        sudo ufw reload
    else
        for port in 47984 47989 47990 48010; do
            sudo firewall-cmd --permanent --add-port=${port}/tcp
        done
        sudo firewall-cmd --permanent --add-port=47998-48000/udp
        sudo firewall-cmd --reload
    fi

    # Install based on distro
    DISTRO=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')
    case "$DISTRO" in
        fedora)
            # Install the RPM from COPR
            sudo dnf copr enable -y lizardbyte/stable
            sudo dnf install -y Sunshine
            ;;
        debian)
            # Find the latest installer
            DISTRO_VERSION="${DISTRO}-$(lsb_release -cs)"
            GITHUB_URL="https://api.github.com/repos/LizardByte/Sunshine/releases/latest"
            DEB_URL=$(curl -s "$GITHUB_URL" | grep browser_download_url | grep "$DISTRO_VERSION" | grep "amd64\.deb" | cut -d '"' -f 4)

            # Download, install and clean
            FILENAME=$(basename "$DEB_URL")
            wget -q --show-progress "$DEB_URL" -O "/tmp/$FILENAME"
            sudo apt install -y "/tmp/$FILENAME"
            rm "/tmp/$FILENAME"
            ;;
        *)
            echo -e "\t Unsupported distro, operation failed... \n"
            exit 1
            ;;
    esac

    # Enable WoL on startup
    ETH_CONN=$(nmcli -t -f NAME,TYPE con show | grep ethernet | cut -d: -f1 | head -n 1)
    nmcli con modify "$ETH_CONN" ethernet.wake-on-lan magic

# Set up development environment
setup-devenv:
    #!/bin/bash
    echo -e "\n\t Setting up development environment \n"

    # Install the direnv CLI tool
    curl -sfL https://direnv.net/install.sh | bash

    # Ensure Github SSH connection
    ssh-keygen -t ed25519 -C 13894059+Krauzer94@users.noreply.github.com
    echo '' && cat ~/.ssh/id_ed25519.pub && echo ''
    git remote set-url origin git@github.com:Krauzer94/dotfiles.git

# Set up user service Quadlets
setup-quadlets:
    #!/bin/bash
    echo -e "\n\t Setting up user service Quadlets \n"

    # Enable the firewall port
    DISTRO=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')
    case "$DISTRO" in
        fedora)
            sudo firewall-cmd --permanent --add-port=8080/tcp
            sudo firewall-cmd --reload
            ;;
        debian)
            sudo ufw allow 8080/tcp
            sudo ufw reload
            ;;
        *)
            echo -e "\t Unsupported distro, operation failed... \n"
            exit 1
            ;;
    esac

    # Start NextCloud Quadlet
    systemctl --user daemon-reload
    systemctl --user start nextcloud

    # Enable at system startup
    loginctl enable-linger $USER

# Set up Tailscale on the Deck
setup-taildeck:
    #!/bin/bash
    echo -e "\n\t Setting up Tailscale on the Deck \n"

    # Download necessary files
    git clone git@github.com:tailscale-dev/deck-tailscale.git
    cd ./deck-tailscale

    # Install and source binary
    sudo bash ./tailscale.sh
    source /etc/profile.d/tailscale.sh

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
