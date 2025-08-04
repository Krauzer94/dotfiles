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
        org.gnome.gThumb \
        org.gnome.Papers \
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
            if command -v dnf &> /dev/null; then
                sudo dnf install -y dnf-plugins-core
                sudo dnf config-manager --add-repo \
                    https://download.docker.com/linux/fedora/docker-ce.repo
                sudo dnf install -y $DOCKER_PACKAGES
            else
                sudo curl -o /etc/yum.repos.d/docker-ce.repo \
                    https://download.docker.com/linux/fedora/docker-ce.repo
                sudo rpm-ostree install --apply-live -y $DOCKER_PACKAGES
            fi
            ;;
        ubuntu)
            sudo apt update && sudo apt install -y \
                apt-transport-https \
                ca-certificates curl \
                software-properties-common

            curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
                | sudo tee /etc/apt/trusted.gpg.d/docker.asc
            echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
                | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            sudo apt update && sudo apt install -y $DOCKER_PACKAGES
            ;;
        arch)
            sudo pacman -Syu --noconfirm \
                docker docker-buildx docker-compose
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
    DISTRO_PACKAGES="distrobox mangohud steam"

    # Install based on distro
    DISTRO=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')
    case "$DISTRO" in
        fedora)
            if command -v dnf &> /dev/null; then
                sudo dnf install -y $DISTRO_PACKAGES
            else
                sudo rpm-ostree install --apply-live -y $DISTRO_PACKAGES \
                    akmod-nvidia xorg-x11-drv-nvidia
            fi
            ;;
        ubuntu)
            sudo dpkg --add-architecture i386
            sudo apt update && sudo apt install -y $DISTRO_PACKAGES \
                flatpak gnome-software-plugin-flatpak
            flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            ;;
        arch)
            sudo pacman -Syu --needed --noconfirm $DISTRO_PACKAGES \
                noto-fonts-cjk networkmanager podman ufw
            sudo systemctl enable --now \
                NetworkManager bluetooth ufw
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

    # Install based on distro
    DISTRO=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')
    case "$DISTRO" in
        fedora)
            for port in 47984 47989 47990 48010; do
                sudo firewall-cmd --permanent --add-port=${port}/tcp
            done
            sudo firewall-cmd --permanent --add-port=47998-48000/udp
            sudo firewall-cmd --reload

            if command -v dnf &> /dev/null; then
                sudo dnf copr enable -y lizardbyte/stable
                sudo dnf install -y Sunshine
            else
                OS_VERSION=$(lsb_release -rs)
                URL_PREFIX="https://copr.fedorainfracloud.org/coprs/lizardbyte/stable/repo/"
                URL_RESULT="${URL_PREFIX}fedora-${OS_VERSION}/lizardbyte-stable-fedora-${OS_VERSION}.repo"
                sudo curl -o /etc/yum.repos.d/lizardbyte-stable.repo "$URL_RESULT"
                sudo rpm-ostree install --apply-live -y Sunshine
            fi
            ;;
        ubuntu)
            # Find the latest installer
            DISTRO_VERSION="${DISTRO}-$(lsb_release -rs)"
            GITHUB_URL="https://api.github.com/repos/LizardByte/Sunshine/releases/latest"
            DEB_URL=$(curl -s "$GITHUB_URL" | grep browser_download_url | grep "$DISTRO_VERSION" | grep "amd64\.deb" | cut -d '"' -f 4)

            # Download, install and clean
            FILENAME=$(basename "$DEB_URL")
            wget -q --show-progress "$DEB_URL" -O "/tmp/$FILENAME"
            sudo apt install -y "/tmp/$FILENAME"
            rm "/tmp/$FILENAME"
            ;;
        arch)
            echo "
            [lizardbyte]
            SigLevel = Optional
            Server = https://github.com/LizardByte/pacman-repo/releases/latest/download" \
            | sudo tee -a /etc/pacman.conf > /dev/null
            sudo pacman -Syu --noconfirm sunshine
            ;;
        *)
            echo -e "\t Unsupported distro, operation failed... \n"
            exit 1
            ;;
    esac

    # For UFW systems only
    if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "arch" ]]; then
        for port in 47984 47989 47990 48010; do
            sudo ufw allow ${port}/tcp
        done
        sudo ufw allow 47998:48000/udp
        sudo ufw reload
    fi

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
        ubuntu|arch)
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
    mkdir -p $HOME/.local/share/{themes,icons}

    # Copy system files over
    cp -r /usr/share/themes/* $HOME/.local/share/themes/
    cp -r /usr/share/icons/* $HOME/.local/share/icons/

# Upload savegame folder files
[no-cd]
upload-savegame:
    #!/bin/bash

    git add .
    git commit -m "Save game upload"
    git push
