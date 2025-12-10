set quiet

_default:
    just --list

# Deploy an ephemeral container
[no-cd]
env-deploy:
    #!/bin/bash

    # Build the container
    podman build -t \
        "$(basename "$PWD"):latest" \
        .container

    # Run created container
    podman run -it --rm \
        -v "$(pwd)":/work:Z \
        -w /work "$(basename "$PWD"):latest"

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

# Installs the Docker application
installs-docker:
    #!/bin/bash
    echo -e "\n\t Installing the Docker application \n"

    # Main packages to install
    DEPENDENCIES=(
        apt-transport-https
        ca-certificates
        gnupg
    )

    DOCKER_PACKAGES=(
        docker-ce
        docker-ce-cli
        containerd.io
        docker-buildx-plugin
        docker-compose-plugin
    )

    # Install based on distro
    DISTRO=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')
    case "$DISTRO" in
        ubuntu)
            # Ensure compatibility
            CODENAME=$(lsb_release -cs)

            # Ensure all dependencies
            sudo apt update && sudo apt install -y "${DEPENDENCIES[@]}"

            # Enable the Docker repo
            curl -fsSL https://download.docker.com/linux/$DISTRO/gpg \
                | sudo tee /etc/apt/trusted.gpg.d/docker.asc
            echo "deb [arch=amd64] https://download.docker.com/linux/$DISTRO $CODENAME stable" \
                | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            # Install Docker packages
            sudo apt update && sudo apt install -y "${DOCKER_PACKAGES[@]}"
            ;;
        fedora)
            DOCKER_REPO=https://download.docker.com/linux/$DISTRO/docker-ce.repo

            # Ensure compatibility
            if command -v dnf &> /dev/null; then
                sudo dnf install -y dnf-plugins-core
                sudo dnf config-manager --add-repo $DOCKER_REPO
                sudo dnf install -y "${DOCKER_PACKAGES[@]}"
            else
                sudo curl -o /etc/yum.repos.d/docker-ce.repo $DOCKER_REPO
                sudo rpm-ostree install "${DOCKER_PACKAGES[@]}"
            fi
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
    DISTRO_PACKAGES=(
        mangohud
        flatpak
        podman
        steam
    )

    # Install based on distro
    DISTRO=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')
    case "$DISTRO" in
        ubuntu)
            # Install base packages
            sudo dpkg --add-architecture i386
            sudo apt update && sudo apt install -y "${DISTRO_PACKAGES[@]}"
            sudo ubuntu-drivers install

            # Firewall handling
            sudo apt install -y ufw
            sudo ufw enable
            ;;
        fedora)
            # Ensure compatibility
            if command -v dnf &> /dev/null; then
                sudo dnf install -y "${DISTRO_PACKAGES[@]}"
            else
                sudo rpm-ostree install \
                    xorg-x11-drv-nvidia \
                    akmod-nvidia \
                    mangohud \
                    steam

                # NVIDIA driver handling
                sudo rpm-ostree kargs --append=rd.driver.blacklist=nouveau,nova_core --append=modprobe.blacklist=nouveau,nova_core
            fi

            # Firewall handling
            sudo systemctl enable --now firewalld
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
