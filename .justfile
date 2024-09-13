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

        # Find the last second
        start=$(awk -v dur="$duration" 'BEGIN { print dur - 1 }')

        # Apply fade effects
        ffmpeg -i "$f" \
        -vf "fade=t=in:st=0:d=1,fade=t=out:st=$start:d=1" \
        -af "afade=t=in:st=0:d=1,afade=t=out:st=$start:d=1" "$clip" -y && rm "$f"
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

    echo -e '\n Installing all Arch Linux apps \n'
    flatpak install flathub org.freedesktop.Platform.VulkanLayer.MangoHud
    packages=(
        git flatpak timeshift steam ffmpeg mangohud
        firefox spectacle packagekit-qt6 noto-fonts-cjk
    )
    for package in "${packages[@]}"; do
        sudo pacman -S --needed "$package" --noconfirm
    done
    sudo systemctl enable --now cronie.service bluetooth.service NetworkManager.service
    just installs-common
    flatpak install -y flathub \
        org.kde.okular \
        org.kde.gwenview \
        com.dec05eba.gpu_screen_recorder
    echo -e '\n Finished installing all Arch Linux apps \n'

# Install common applications
installs-common:
    #!/usr/bin/env bash

    curl -L https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch -o ~/.neofetch.sh
    just setup-filesys
    apps=(
        com.google.Chrome
        org.gimp.GIMP
        org.qbittorrent.qBittorrent
        org.flameshot.Flameshot
        org.gnome.EasyTAG
        com.stremio.Stremio
        org.bleachbit.BleachBit
        com.spotify.Client
        org.libretro.RetroArch
        org.onlyoffice.desktopeditors
        com.discordapp.Discord
        io.github.mimbrero.WhatsAppDesktop
        com.github.tchx84.Flatseal
        net.davidotek.pupgui2
        net.lutris.Lutris
        com.visualstudio.code
        org.kde.kcalc
    )
    for app in "${apps[@]}"; do
        flatpak install flathub "$app" -y
    done

# Install Fedora specific apps
installs-fedora:
    #!/usr/bin/env bash

    echo -e '\n Installing all Fedora apps \n'
    flatpak install flathub org.freedesktop.Platform.VulkanLayer.MangoHud
    packages=(
        git flatpak btrfs-assistant steam ffmpeg mangohud
        firefox akmod-nvidia xorg-x11-drv-nvidia-cuda
    )
    for package in "${packages[@]}"; do
        sudo dnf install "$package" -y
    done
    just installs-common
    flatpak install -y flathub \
        org.kde.gwenview \
        org.videolan.VLC \
        com.dec05eba.gpu_screen_recorder
    echo -e '\n Finished installing all Fedora apps \n'

# Install SteamOS specific apps
installs-steamos:
    #!/usr/bin/env bash

    echo -e '\n Installing all SteamOS apps \n'
    flatpak install flathub org.freedesktop.Platform.VulkanLayer.MangoHud
    just installs-common
    flatpak install -y flathub \
        org.mozilla.firefox \
        org.videolan.VLC \
        com.obsproject.Studio
    echo -e '\n Finished installing all SteamOS apps \n'

# Install all WSL specific apps
installs-wsl:
    #!/usr/bin/env bash

    echo -e '\n Installing all WSL apps \n'
    echo -e "[boot]\nsystemd=true\nnetworkingMode=mirrored" >> /etc/wsl.conf
    sudo apt install -y \
        git \
        systemd \
        systemctl \
        openssh-client \
        wget \
        distrobox \
        podman
    echo -e '\n Finished installing all WSL apps \n'

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

    echo -e '\n Generating a new SSH key \n'
    ssh-keygen -t ed25519 -C 13894059+Krauzer94@users.noreply.github.com
    echo -e '\n Copy the newly created key \n'
    cat ~/.ssh/id_ed25519.pub
    echo -e '\n Paste it into a new SSH key: https://github.com/settings/keys \n'

# Upload savegame folder files
[no-cd]
upload-savegame:
    #!/usr/bin/env bash

    git add .
    git commit -m "Save game upload"
    git push
