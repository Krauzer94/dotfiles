set quiet

_default:
    just --list

# Enable user service Quadlets
enable-quadlets:
    #!/bin/bash

    systemctl --user daemon-reload
    systemctl --user start nextcloud
    loginctl enable-linger $USER

# Installs common applications
installs-common:
    #!/bin/bash

    just setup-themes
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

    sudo dnf install -y \
        btrfs-assistant \
        distrobox \
        mangohud \
        podlet \
        steam
    just installs-common

# Installs Sunshine application
installs-sunshine:
    #!/bin/bash

    sudo dnf copr enable lizardbyte/stable
    sudo dnf install -y Sunshine

# Set up development environment
setup-devenv:
    #!/bin/bash

    echo ''
    curl -sfL https://direnv.net/install.sh | bash
    echo ''
    ssh-keygen -t ed25519 -C 13894059+Krauzer94@users.noreply.github.com
    echo ''
    cat ~/.ssh/id_ed25519.pub
    echo ''
    git remote set-url origin git@github.com:Krauzer94/dotfiles.git

# Set up Tailscale application
setup-tailscale:
    #!/bin/bash

    git clone git@github.com:tailscale-dev/deck-tailscale.git
    cd ./deck-tailscale
    sudo bash ./tailscale.sh
    source /etc/profile.d/tailscale.sh

# Set up application theming
setup-themes:
    #!/bin/bash

    mkdir $HOME/.themes
    mkdir $HOME/.icons
    cp -r /usr/share/themes/* $HOME/.themes/
    cp -r /usr/share/icons/* $HOME/.icons/

# Upload savegame folder files
[no-cd]
upload-savegame:
    #!/bin/bash

    git add .
    git commit -m "Save game upload"
    git push
