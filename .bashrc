# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Base shell aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Customized shell prompt
PROMPT_COMMAND='PS1_CMD1=$(git branch --show-current 2>/dev/null)'; PS1='[\[\e[92m\]\u\[\e[92m\]@\[\e[92m\]\h\[\e[0m\] \[\e[93m\]\W\[\e[0m\]] \[\e[96m\]${PS1_CMD1}\[\e[0m\] \\$ '

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Load bash aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

greset() {
    # Themes, icons, cursor
    local keys=( gtk-theme icon-theme cursor-theme )
    for key in "${keys[@]}"; do
        gsettings reset org.gnome.desktop.interface "$key"
    done

    # Reset fonts to default
    local font_keys=( font-name document-font-name monospace-font-name )
    for key in "${font_keys[@]}"; do
        gsettings reset org.gnome.desktop.interface "$key"
    done

    # Window buttons
    gsettings set org.gnome.desktop.wm.preferences button-layout ":close"
}

# Enable NVM and Node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
