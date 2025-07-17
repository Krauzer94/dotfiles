set quiet

_default:
    just --list

# Enable user service Quadlets
enable-quadlets:
    #!/bin/bash
    echo -e "\n\t Enabling user service Quadlets \n"

    # Enable Firewall port
    sudo firewall-cmd --permanent --add-port=8080/tcp
    sudo firewall-cmd --reload

    # Start NextCloud Quadlet
    systemctl --user daemon-reload
    systemctl --user start nextcloud

    # Enable at system startup
    loginctl enable-linger $USER

# Installs common applications
installs-common:
    #!/bin/bash
    echo -e "\n\t Installing common applications \n"

    # Ensure app theming
    just setup-themes

    # Install all Flatpaks
    flatpak install -y flathub \
        org.mozilla.firefox \
        org.gimp.GIMP \
        org.qbittorrent.qBittorrent \
        org.flameshot.Flameshot \
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
        org.kde.gwenview \
        org.kde.okular \
        com.dec05eba.gpu_screen_recorder

# Installs Fedora specific apps
installs-fedora:
    #!/bin/bash
    echo -e "\n\t Installing Fedora specific apps \n"

    # Install NVIDIA driver
    sudo sh -c 'echo "%_with_kmod_nvidia_open 1" > /etc/rpm/macros.nvidia-kmod'
    sudo akmods --kernels $(uname -r) --rebuild

    # Native package installs
    sudo dnf install -y \
        btrfs-assistant \
        distrobox \
        mangohud steam

    # Install remaining apps
    just installs-common

# Installs Sunshine application
installs-sunshine:
    #!/bin/bash
    echo -e "\n\t Installing Sunshine application \n"

    # Install based on hostname
    HOST=$HOSTNAME
    case "$HOST" in
        fedora*)
            # Install Sunshine from COPR
            sudo dnf copr enable lizardbyte/stable
            sudo dnf install -y Sunshine
            ;;
        kubuntu*)
            # Download the DEB installer
            echo -e "\t Installer: https://github.com/LizardByte/Sunshine/releases \n"
            ;;
    esac

    # Enable necessary Firewall ports
    for port in 47984 47989 47990 48010; do
        sudo firewall-cmd --permanent --add-port=${port}/tcp
    done
    sudo firewall-cmd --permanent --add-port=47998-48000/udp
    sudo firewall-cmd --reload

    # Enable WoL on system startup
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
