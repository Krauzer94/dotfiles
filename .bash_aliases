# NixOS specific
  alias flakeup='nix flake update ~/.flake && git add -f ~/.flake/flake.lock'
  alias nupdate='flakeup && sudo nixos-rebuild switch --flake ~/.flake'
  alias nrevert='git restore --staged . && git restore .'

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
  alias allow='direnv allow'
  alias ll='ls -l --color=auto'
  alias aliases='cat ~/.bash_aliases'
  alias vs='flatpak run com.visualstudio.code'
  alias save='just upload-savegame'
  alias wclean='find ~/ -type f -name "*.Identifier" -delete'
