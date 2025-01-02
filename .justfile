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
        org.mozilla.firefox \
        org.gnome.Loupe \
        org.gnome.Papers

    just installs-specific

# Installs distro specific apps
installs-specific:
    #!/usr/bin/env bash

    HOST=$HOSTNAME
    case "$HOST" in
        steamdeck*)
            flatpak install -y flathub \
                org.kde.kcalc
            ;;
        kubuntu*)
            flatpak install -y flathub \
                com.valvesoftware.Steam
            ;;
        *)
            echo -e "\n Nothing to do here \n"
            ;;
    esac

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
    if [[ "$HOST" == steamdeck* ]]; then
        echo -e "\n Nothing to do here \n"
    else
        ln -s ~/.var/app/com.valvesoftware.Steam/.local/share/applications ~/.runtimes
        ln -s ~/.var/app/com.valvesoftware.Steam/.steam ~/.steam
        ln -s ~/.config/MangoHud/MangoHud.conf ~/.var/app/com.valvesoftware.Steam/config/MangoHud
    fi

# Upload savegame folder files
[no-cd]
upload-savegame:
    #!/usr/bin/env bash

    git add .
    git commit -m "Save game upload"
    git push
