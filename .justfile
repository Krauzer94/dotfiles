set quiet

_default:
    just --list

# Enable user service Quadlets
enable-quadlets:
    #!/bin/bash

    echo -e "\n Enabling user service Quadlets \n"
    systemctl --user daemon-reload
    systemctl --user start nextcloud
    loginctl enable-linger $USER
    echo -e "\n Finished enabling user service Quadlets \n"

# Installs common applications
installs-common:
    #!/bin/bash

    just setup-themes
    echo -e "\n Installing common applications \n"
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
    echo -e "\n Finished installing common applications \n"

# Installs Fedora specific apps
installs-fedora:
    #!/bin/bash

    echo -e "\n Installing Fedora specific apps \n"
    sudo dnf install -y \
        btrfs-assistant \
        distrobox \
        mangohud \
        podlet \
        steam
    just installs-common
    echo -e "\n Finished installing Fedora specific apps \n"

# Installs Sunshine application
installs-sunshine:
    #!/bin/bash

    echo -e "\n Installing Sunshine application \n"
    sudo dnf copr enable lizardbyte/stable
    sudo dnf install -y Sunshine
    for port in 47984 47989 47990 48010; do
        sudo firewall-cmd --permanent --add-port=${port}/tcp
    done
    sudo firewall-cmd --permanent --add-port=47998-48000/udp
    sudo firewall-cmd --reload
    echo -e "\n Finished installing Sunshine application \n"

# Set up development environment
setup-devenv:
    #!/bin/bash

    echo -e "\n Setting up development environment \n"
    echo ''
    curl -sfL https://direnv.net/install.sh | bash
    echo ''
    ssh-keygen -t ed25519 -C 13894059+Krauzer94@users.noreply.github.com
    echo ''
    cat ~/.ssh/id_ed25519.pub
    echo ''
    git remote set-url origin git@github.com:Krauzer94/dotfiles.git
    echo -e "\n Finished setting up development environment \n"

# Set up Tailscale application
setup-tailscale:
    #!/bin/bash

    echo -e "\n Settin up Tailscale application \n"
    git clone git@github.com:tailscale-dev/deck-tailscale.git
    cd ./deck-tailscale
    sudo bash ./tailscale.sh
    source /etc/profile.d/tailscale.sh
    echo -e "\n Finished settig up Tailscale application \n"

# Set up application theming
setup-themes:
    #!/bin/bash

    echo -e "\n Setting up application theming \n"
    mkdir $HOME/.themes
    mkdir $HOME/.icons
    cp -r /usr/share/themes/* $HOME/.themes/
    cp -r /usr/share/icons/* $HOME/.icons/
    echo -e "\n Finished setting up application theming \n"

# Upload savegame folder files
[no-cd]
upload-savegame:
    #!/bin/bash

    echo -e "\n Uploading savegame folder files \n"
    git add .
    git commit -m "Save game upload"
    git push
    echo -e "\n Finished uploading savegame folder files \n"
