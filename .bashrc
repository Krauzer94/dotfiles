#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
#PS1='[\u@\h \W]\$ ' # Default
PROMPT_COMMAND='PS1_CMD1=$(git branch --show-current 2>/dev/null)'; PS1='[\[\e[92m\]\u\[\e[92m\]@\[\e[92m\]\h\[\e[0m\] \[\e[93m\]\W\[\e[0m\]] \[\e[96m\]${PS1_CMD1}\[\e[0m\] \\$ '

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Bash aliases
if [ -f ~/.bash_aliases ]; then
. ~/.bash_aliases
fi

# Enable direnv
eval "$(direnv hook bash)"

# paste.rs
function paste() {
    echo ""
    local file=${1:-/dev/stdin}
    curl --data-binary @${file} https://paste.rs
    echo ""
    echo ""
}
