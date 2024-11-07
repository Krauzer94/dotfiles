_default:
    just --list

# Installs common applications
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
        dev.lizardbyte.app.Sunshine

    just installs-specific

# Installs distro specific apps
installs-specific:
    #!/usr/bin/env bash

    HOST=$HOSTNAME
    if [[ "$HOST" == fedora* || "$HOST" == ubuntu* || "$HOST" == debian* || "$HOST" == archlinux* ]]; then
        flatpak install -y flathub \
            com.mattjakeman.ExtensionManager \
            com.valvesoftware.Steam
    else
        flatpak install -y flathub \
            org.kde.kcalc \
            org.mozilla.firefox
    fi

# Install Arch Linux specific apps
installs-arch:
    #!/usr/bin/env bash

    sudo pacman -S --needed --noconfirm \
        noto-fonts-cjk
    sudo systemctl enable --now \
        bluetooth.service \
        NetworkManager.service
    just installs-common

# Instals Debian specific apps
installs-debian:
    #!/usr/bin/env bash

    sudo apt install -y \
        flatpak \
        gnome-software-plugin-flatpak \
        gnome-tweaks \
        nvidia-driver \
        firmware-misc-nonfree \
        libnvidia-encode1
    flatpak remote-add --if-not-exists \
        flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    just installs-common

# Installs Fedora specific apps
installs-fedora:
    #!/usr/bin/env bash

    sudo dnf remove -y \
        firefox \
        'libreoffice*' \
        gnome-boxes
    sudo dnf autoremove -y && sudo dnf clean all
    sudo dnf install -y \
        gnome-tweaks \
        akmod-nvidia \
        xorg-x11-drv-nvidia-cuda
    just installs-common

# Installs Ubuntu specific apps
installs-ubuntu:
    #!/usr/bin/env bash

    sudo apt install -y \
        flatpak \
        gnome-software-plugin-flatpak \
        gnome-tweaks
    flatpak remote-add --if-not-exists \
        flathub https://dl.flathub.org/repo/flathub.flatpakrepo
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

# Set up convenient symlinks
setup-symlinks:
    #!/usr/bin/env bash

    ln -s ~/.local/share/applications ~/.applications
    ln -s ~/.var/app ~/.flatpaks
    ln -s ~/.config/MangoHud/MangoHud.conf ~/.mangohud
    ln -s ~/.var/app/com.stremio.Stremio/.stremio-server/stremio-cache ~/.stremio-cache
    ln -s ~/.config/MangoHud/MangoHud.conf ~/.var/app/net.lutris.Lutris/config/MangoHud

    HOST=$HOSTNAME
    if [[ "$HOST" == fedora* || "$HOST" == ubuntu* || "$HOST" == debian* || "$HOST" == archlinux* ]]; then
        ln -s ~/.var/app/com.valvesoftware.Steam/.local/share/applications ~/.runtimes
        ln -s ~/.var/app/com.valvesoftware.Steam/.steam ~/.steam
        ln -s ~/.config/MangoHud/MangoHud.conf ~/.var/app/com.valvesoftware.Steam/config/MangoHud
    else
        echo -e "\n Nothing to do here \n"
    fi

# Upload savegame folder files
[no-cd]
upload-savegame:
    #!/usr/bin/env bash

    git add .
    git commit -m "Save game upload"
    git push
