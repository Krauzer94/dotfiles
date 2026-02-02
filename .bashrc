#
# ~/.bashrc
#

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

# Terminal Pastebin
function paste() {
    echo ""
    local file=${1:-/dev/stdin}
    curl --data-binary @${file} https://paste.rs
    echo ""
    echo ""
}

# Enable NVM and Node
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
