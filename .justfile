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
        org.gnome.EasyTAG \
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
        com.visualstudio.code \
        org.videolan.VLC

# Install Fedora specific apps
installs-fedora:
    #!/usr/bin/env bash

    echo -e ''
    flatpak install -y flathub org.freedesktop.Platform.VulkanLayer.MangoHud
    sudo dnf install -y \
        steam \
        ffmpeg \
        mangohud \
        firefox \
        akmod-nvidia \
        xorg-x11-drv-nvidia-cuda
    just installs-common
    flatpak install -y flathub \
        org.kde.gwenview \
        org.kde.kcalc \
        com.dec05eba.gpu_screen_recorder
    echo -e ''

# Install Mint specific apps
installs-mint:
    #!/usr/bin/env bash

    echo -e ''
    flatpak install -y flathub org.freedesktop.Platform.VulkanLayer.MangoHud
    sudo apt update
    sudo apt install -y \
        steam-installer \
        ffmpeg \
        mangohud
    just installs-common
    flatpak install -y flathub com.obsproject.Studio
    echo -e ''

# Install SteamOS specific apps
installs-steamos:
    #!/usr/bin/env bash

    echo -e ''
    flatpak install -y flathub org.freedesktop.Platform.VulkanLayer.MangoHud
    just installs-common
    flatpak install -y flathub \
        org.kde.kcalc \
        org.mozilla.firefox \
        com.obsproject.Studio
    echo -e ''

# Install all WSL specific apps
installs-wsl:
    #!/usr/bin/env bash

    echo -e ''
    sudo apt update
    sudo apt install -y \
        openssh-client \
        wget
    just setup-github
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
