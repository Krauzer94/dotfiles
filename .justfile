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

    echo -e '\n Installing all Arch Linux apps\n'
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
        org.mozilla.firefox \
        org.kde.kcalc \
        com.dec05eba.gpu_screen_recorder
    echo -e '\n Finished installing all Arch Linux apps\n'

# Install common applications
installs-common:
    #!/usr/bin/env bash

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
    )
    for app in "${apps[@]}"; do
        flatpak install flathub "$app" -y
    done

# Install NixOS specific apps
installs-nixos:
    #!/usr/bin/env bash

    echo -e '\n Installing all NixOS apps\n'
    mkdir -p ~/.config/nix
    echo 'experimental-features = nix-command flakes' > ~/.config/nix/nix.conf
    sudo nixos-rebuild switch --flake ~/.flake
    nix run home-manager/master -- switch --flake ~/.flake
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub \
        org.freedesktop.Platform.VulkanLayer.MangoHud \
        org.videolan.VLC \
        org.mozilla.firefox \
        org.kde.kcalc \
        com.dec05eba.gpu_screen_recorder
    just installs-common
    echo -e '\n Finished installing all NixOS apps\n'

# Install SteamOS specific apps
installs-steamos:
    #!/usr/bin/env bash

    echo -e '\n Installing all SteamOS apps\n'
    flatpak install flathub org.freedesktop.Platform.VulkanLayer.MangoHud
    just installs-common
    flatpak install -y flathub \
        flathub org.videolan.VLC \
        flathub com.obsproject.Studio
    echo -e '\n Finished installing all SteamOS apps\n'

# Set up Arch Linux for WSL usage
setup-archwsl:
    #!/usr/bin/env bash

    echo -e '\n Installing ArchWSL specific apps\n'
    packages=( which openssh wget )
    for package in "${packages[@]}"; do
        sudo pacman -S --needed "$package" --noconfirm
    done
    just setup-nixpm
    echo -e '\n Finished installing all ArchWSL apps\n'

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

    echo -e '\n Generating a new SSH key\n'
    ssh-keygen -t ed25519 -C 13894059+Krauzer94@users.noreply.github.com
    echo -e '\n Copy the newly created key\n'
    cat ~/.ssh/id_ed25519.pub
    echo -e '\n Paste it into a new SSH key: https://github.com/settings/keys\n'

# Set up the Nix Package Manager
setup-nixpm:
    #!/usr/bin/env bash

    echo -e '\n Setting up the Nix Package Manager\n'
    sh <(curl -L https://nixos.org/nix/install) --no-daemon
    . $HOME/.nix-profile/etc/profile.d/nix.sh
    mkdir -p ~/.config/nix
    echo 'experimental-features = nix-command flakes' > ~/.config/nix/nix.conf
    nix run home-manager/master -- switch --flake ~/.flake
    echo -e "\n Finished setting up the Nix Package Manager\n"

# Upload savegame folder files
upload-savegame:
    #!/usr/bin/env bash

    cd ~/Games/save-game
    git add .
    git commit -m "Save game upload"
    git push
