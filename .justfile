_default:
    just --list

# Installs common applications
installs-common:
    #!/usr/bin/env bash

    just setup-themes
    flatpak install -y flathub \
        org.freedesktop.Platform.VulkanLayer.MangoHud \
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
        net.lutris.Lutris \
        com.vscodium.codium \
        org.videolan.VLC \
        org.kde.kcalc \
        io.missioncenter.MissionCenter \
        io.github.flattool.Warehouse \
        com.dec05eba.gpu_screen_recorder

# Installs Ubuntu applications
installs-ubuntu:
    #!/usr/bin/env bash

    sudo dpkg --add-architecture i386
    sudo apt update && sudo apt install -y \
        gnome-software-plugin-flatpak \
        steam-installer
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    just installs-common

# Set up application theming
setup-themes:
    #!/usr/bin/env bash

    mkdir $HOME/.themes
    mkdir $HOME/.icons
    cp -r /usr/share/themes/* $HOME/.themes/
    cp -r /usr/share/icons/* $HOME/.icons/

# Set up git and GitHub account
setup-github:
    #!/usr/bin/env bash

    echo -e ''
    ssh-keygen -t ed25519 -C 13894059+Krauzer94@users.noreply.github.com
    echo -e ''
    cat ~/.ssh/id_ed25519.pub
    echo -e ''

# Upload savegame folder files
[no-cd]
upload-savegame:
    #!/usr/bin/env bash

    git add .
    git commit -m "Save game upload"
    git push
