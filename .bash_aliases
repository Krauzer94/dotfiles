# Flatpak specific
alias fupdate='flatpak update -y'
alias fclean='flatpak uninstall --unused'
alias flapp='flatpak list --app'
alias flrun='flatpak list --runtime'

# Arch specific
alias aupdate='sudo pacman -Syu --noconfirm'
alias aclean='sudo pacman -Rns $(pacman -Qtdq) --noconfirm'
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
alias shutdown='shutdown now'
alias neofetch='bash ~/.neofetch.sh'
alias vs='flatpak run com.visualstudio.code'
alias save='just upload-savegame'

# Video editing
alias video='just edit-videos'
alias clip='just edit-clips'
