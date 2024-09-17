# Flatpak specific
  alias fupdate='flatpak update -y'
  alias fclean='flatpak uninstall --unused'
  alias flapp='flatpak list --app'
  alias flrun='flatpak list --runtime'
# NixOS specific
  alias flakeup='nix flake update ~/.flake'
  alias nupdate='flakeup && sudo nixos-rebuild switch --flake ~/.flake'
  alias nclean='sudo nix-collect-garbage --delete-older-than 5d'
  alias wclean='find ~/ -type f -name "*.Identifier" -delete'
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
  alias neofetch='bash ~/.neofetch.sh'
  alias vs='flatpak run com.visualstudio.code'
  alias save='just upload-savegame'
# Video editing
  alias video='just edit-videos'
  alias clip='just edit-clips'
