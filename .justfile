_default:
    just --list

# Install common applications
installs-common:
    #!/usr/bin/env bash

    just setup-filesys
    flatpak install -y flathub \
        org.freedesktop.Platform.VulkanLayer.MangoHud \
        com.google.Chrome \
        org.gimp.GIMP \
        org.qbittorrent.qBittorrent \
        org.flameshot.Flameshot \
        com.stremio.Stremio \
        org.bleachbit.BleachBit \
        com.spotify.Client \
        org.libretro.RetroArch \
        org.onlyoffice.desktopeditors \
        com.discordapp.Discord \
        com.rtosta.zapzap \
        com.github.tchx84.Flatseal \
        net.davidotek.pupgui2 \
        net.lutris.Lutris \
        com.vscodium.codium \
        org.videolan.VLC \
        org.gnome.gThumb \
        dev.lizardbyte.app.Sunshine \
        org.kde.kcalc \
        com.mattjakeman.ExtensionManager \
        com.valvesoftware.Steam

# Installs Fedora specific apps
installs-fedora:
    #!/usr/bin/env bash

    sudo dnf remove -y \
        'libreoffice*' \
        gnome-boxes \
        mediawriter
    sudo dnf autoremove -y && sudo dnf clean all
    sudo dnf install -y \
        gnome-tweaks \
        akmod-nvidia \
        xorg-x11-drv-nvidia-cuda
    just installs-common

# Installs Ubuntu specific apps
installs-ubuntu:
    #!/usr/bin/env bash

    sudo snap remove --purge firefox snapstore
    sudo apt update && sudo apt install -y \
        flatpak \
        gnome-software-plugin-flatpak \
        gnome-tweaks
    flatpak remote-add --if-not-exists \
        flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo ubuntu-drivers install
    just installs-common

# Set up flatpak permissions
setup-filesys:
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
