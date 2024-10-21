_default:
    just --list

# Edit clips and keep the files
[no-cd]
edit-clips:
    #!/usr/bin/env bash

    # Rename clips
    counter=1
    for f in *.mp4; do
        mv "$f" "${counter}.mp4"
        ((counter++))
    done

    # Apply video effects
    apply_effects() {
        # Input and output
        f="$1"
        clip="clip-${f%.*}.${f##*.}"

        # Find video duration
        duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$f")
        duration=$(printf "%.2f" "$duration")

        # Find the last second
        start=$(awk -v dur="$duration" 'BEGIN { print dur - 1 }')

        # Apply fade effects
        ffmpeg -i "$f" \
        -vf "fade=t=in:st=0:d=1,fade=t=out:st=$start:d=1" \
        -af "afade=t=in:st=0:d=1,afade=t=out:st=$start:d=1" \
        "$clip" -y && rm "$f"
    }

    # Edit all videos
    for f in *.mp4; do
        apply_effects "$f"
    done

# Edit clips and merge all files
[no-cd]
edit-videos:
    #!/usr/bin/env bash

    # Create intermediates
    counter=1
    for f in *.mp4; do
        ffmpeg -i "$f" -c copy "intermediate-${counter}.ts" && rm "$f"
        ((counter++))
    done

    # Filename array
    files=($(find . -type f -name "*.ts"))
    concat_list=$(printf "concat:%s|" "${files[@]}")
    concat_list=${concat_list%|}

    # Merge all videos
    ffmpeg -i "$concat_list" -c copy video.mp4

    # Delete intermediates
    for f in *.ts; do
        rm "$f"
    done

# Install Arch Linux specific apps
installs-arch:
    #!/usr/bin/env bash

    echo -e ''
    flatpak install -y flathub org.freedesktop.Platform.VulkanLayer.MangoHud
    sudo pacman -Syu --needed --noconfirm \
        spectacle xdg-desktop-portal-gtk \
        ffmpeg \
        mangohud \
        steam \
        noto-fonts-cjk
    sudo systemctl enable --now \
        bluetooth.service \
        NetworkManager.service
    just installs-common
    flatpak install -y flathub \
        org.kde.gwenview \
        org.kde.okular
        # com.mattjakeman.ExtensionManager \
        # org.videolan.VLC
    #sudo ln -s /dev/null /etc/udev/rules.d/61-gdm.rules
    echo -e ''

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
        org.kde.kcalc \
        com.dec05eba.gpu_screen_recorder

# Install Debian specific apps
installs-debian:
    #!/usr/bin/env bash

    echo -e ''
    flatpak install -y flathub org.freedesktop.Platform.VulkanLayer.MangoHud
    sudo dpkg --add-architecture i386
    sudo apt update
    sudo apt install -y \
        gnome-tweaks \
        ffmpeg \
        mangohud \
        steam-installer \
        mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386 \
        nvidia-driver firmware-misc-nonfree libnvidia-encode1
        # ark okular kde-spectacle kdeplasma-addons-data plasma-widgets-addons \
    just installs-common
    flatpak install -y flathub \
        com.mattjakeman.ExtensionManager \
        org.videolan.VLC
        # org.kde.gwenview \
    sudo ln -s /dev/null /etc/udev/rules.d/61-gdm.rules
    echo -e ''

# Install SteamOS specific apps
installs-steamos:
    #!/usr/bin/env bash

    echo -e ''
    flatpak install -y flathub org.freedesktop.Platform.VulkanLayer.MangoHud
    just installs-common
    flatpak install -y flathub \
        org.videolan.VLC \
        com.obsproject.Studio
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
