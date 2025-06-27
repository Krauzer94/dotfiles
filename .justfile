set quiet

_default:
    just --list

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
        dev.lizardbyte.app.Sunshine \
        com.dec05eba.gpu_screen_recorder

# Installs Fedora specific apps
installs-fedora:
    #!/bin/bash
    sudo dnf install -y \
        distrobox \
        mangohud \
        steam
    just installs-common

# Set up application theming
setup-themes:
    #!/bin/bash
    mkdir $HOME/.themes
    mkdir $HOME/.icons
    cp -r /usr/share/themes/* $HOME/.themes/
    cp -r /usr/share/icons/* $HOME/.icons/

# Set up git and GitHub account
setup-github:
    #!/bin/bash
    echo ''
    ssh-keygen -t ed25519 -C 13894059+Krauzer94@users.noreply.github.com
    echo ''
    cat ~/.ssh/id_ed25519.pub
    echo ''
    git remote set-url origin git@github.com:Krauzer94/dotfiles.git

# Upload savegame folder files
[no-cd]
upload-savegame:
    #!/bin/bash
    git add .
    git commit -m "Save game upload"
    git push
