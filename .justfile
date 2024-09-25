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
        steam \
        ffmpeg \
        mangohud \
        firefox \
        spectacle \
        grub-btrfs \
        inotify-tools \
        packagekit-qt6 \
        noto-fonts-cjk
    sudo systemctl enable --now \
        cronie.service \
        grub-btrfsd.service \
        bluetooth.service \
        NetworkManager.service
    just installs-common
    flatpak install -y flathub \
        org.kde.okular \
        org.kde.gwenview \
        com.dec05eba.gpu_screen_recorder
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
        org.kde.kcalc

# Install Fedora specific apps
installs-fedora:
    #!/usr/bin/env bash

    echo -e ''
    flatpak install -y flathub org.freedesktop.Platform.VulkanLayer.MangoHud
    sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y --allowerasing \
        steam \
        ffmpeg \
        mangohud \
        firefox \
        btrfs-assistant \
        akmod-nvidia \
        xorg-x11-drv-nvidia-cuda
    just installs-common
    flatpak install -y flathub \
        org.kde.gwenview \
        org.videolan.VLC \
        com.dec05eba.gpu_screen_recorder
    just setup-btrfs
    echo -e ''

# Install SteamOS specific apps
installs-steamos:
    #!/usr/bin/env bash

    echo -e ''
    flatpak install -y flathub org.freedesktop.Platform.VulkanLayer.MangoHud
    just installs-common
    flatpak install -y flathub \
        org.mozilla.firefox \
        org.kde.kcalc \
        com.obsproject.Studio
    echo -e ''

# Set up grub-btrfs application
setup-btrfs:
    #!/usr/bin/env bash

    echo -e ''
    git clone https://github.com/Antynea/grub-btrfs
    cd grub-btrfs
    sed -i \
    -e '/#GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS/a \
    GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS="systemd.volatile=state"' \
    -e '/#GRUB_BTRFS_GRUB_DIRNAME/a \
    GRUB_BTRFS_GRUB_DIRNAME="/boot/grub2"' \
    -e '/#GRUB_BTRFS_MKCONFIG=/a \
    GRUB_BTRFS_MKCONFIG=/usr/sbin/grub2-mkconfig' \
    -e '/#GRUB_BTRFS_SCRIPT_CHECK=/a \
    GRUB_BTRFS_SCRIPT_CHECK=grub2-script-check' \
    config
    sudo make install
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    sudo systemctl enable --now grub-btrfsd.service
    cd ..
    rm -rdf grub-btrfs
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
