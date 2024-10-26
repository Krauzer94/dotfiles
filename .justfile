_default:
    just --list

# Install common applications
installs-common:
    #!/usr/bin/env bash

    curl -L https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch -o ~/.neofetch.sh
    just setup-filesys
    flatpak install -y flathub \
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
        org.mozilla.firefox \
        com.dec05eba.gpu_screen_recorder \
        org.videolan.VLC \
        org.kde.kcalc

# Install Fedora specific apps
installs-fedora:
    #!/usr/bin/env bash

    echo -e ''
    flatpak install -y flathub org.freedesktop.Platform.VulkanLayer.MangoHud
    sudo dnf install -y \
        ffmpeg-free \
        akmod-nvidia \
        xorg-x11-drv-nvidia-cuda
    just installs-common
    flatpak install -y flathub \
        com.valvesoftware.Steam
    echo -e ''

# Install SteamOS specific apps
installs-steamos:
    #!/usr/bin/env bash

    echo -e ''
    flatpak install -y flathub org.freedesktop.Platform.VulkanLayer.MangoHud
    just installs-common
    flatpak install -y flathub \
        com.obsproject.Studio
    echo -e ''

# Install Ubuntu specific apps
installs-ubuntu:
    #!/usr/bin/env bash

    echo -e ''
    flatpak install -y flathub org.freedesktop.Platform.VulkanLayer.MangoHud
    sudo apt install -y \
        ffmpeg
    sudo ubuntu-drivers install
    just installs-common
    flatpak install -y flathub \
        com.valvesoftware.Steam
    echo -e ''

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
