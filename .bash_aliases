# Arch specific
  alias aupdate='sudo pacman -Syu --noconfirm'
  alias aclean='sudo pacman -Rns $(pacman -Qdtq)'

# Flatpak specific
  alias fupdate='flatpak update -y'
  alias fclean='flatpak uninstall --unused'
  alias flapp='flatpak list --app'
  alias flrun='flatpak list --runtime'

# Git routines
  alias status='git status'
  alias commit='git add . && git commit'
  alias push='git push'
  alias log='git log -1'
  alias fetch='git fetch'
  alias pull='git pull'

# Other aliases
  alias ll='ls -l --color=auto'
  alias aliases='cat ~/.bash_aliases'
  alias vs='flatpak run com.vscodium.codium'
  alias save='just upload-savegame'
  alias wclean='find ~/ -type f -name "*.Identifier" -delete'
  alias replay='echo "killall -SIGUSR1 gpu-screen-recorder"'
