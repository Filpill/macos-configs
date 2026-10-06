# Add SSH-Keys
ssh-add ~/.ssh/keys/next-energy-ado                    > /dev/null 2>&1
ssh-add ~/.ssh/keys/filpill-github                     > /dev/null 2>&1
ssh-add ~/.ssh/keys/vivanti-bit                        > /dev/null 2>&1
ssh-add ~/.ssh/keys/dbt_next_energy_filip_livancic.pem > /dev/null 2>&1
ssh-add ~/.ssh/keys/vivanti_partner_A9322992770571.p8  > /dev/null 2>&1


# Enable prompt colors and git branch info
autoload -U colors && colors
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats '%F{yellow}[%b]%f'
precmd() { vcs_info }
setopt prompt_subst
PS1='%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}${vcs_info_msg_0_} '


# Highlight Folders in Different Color
alias ls='ls --color'
export LSCOLORS="ExGxCxDxBxegedabagacad"

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# Basic auto/tab complete:
setopt autocd autopushd
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=5

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Ctrl-o binding - After Running Closing lf - Switch to Current Directory
lfcd () {
    cd "$(command lf -print-last-dir "$@")"
}
bindkey -s '^o' 'lfcd\n'

# Fuzzy directory search and navigation
sd() {
    local selected_dir
    if command -v fd >/dev/null 2>&1; then
        selected_dir=$(fd -t d -d 9 . \
            "$HOME/Documents" "$HOME/Desktop" "$HOME/Downloads" \
            "$HOME/Developer" "$HOME/Projects" "$HOME/Work" \
            "$HOME/.config" "$HOME/.local" \
            -E '.mozilla' -E '.rustup' -E '.cache' -E '.texlive' -E '.conda' \
            -E '.vscode' -E '.steam' -E 'Steam' -E '.dotnet' -E '.cargo' \
            -E '*cache*' -E '*Cache*' -E '*log*' -E '*logs*' -E '.log' -E '.git' \
            -E '.gemini' -E '.claude' \
            2>/dev/null | fzf --prompt="Select Directory: " --reverse --border --height 12)
    else
        selected_dir=$(find "$HOME" -maxdepth 7 -type d \
            -not \( -path "*.mozilla*" -o -path "*.rustup*" -o -path "*.cache*" \
                    -o -path "*.texlive*" -o -path "*.conda*" -o -path "*.vscode*" \
                    -o -path "*.steam*" -o -path "*Steam*" -o -path "*.dotnet*" \
                    -o -path "*.cargo*" -o -path "*cache*" -o -path "*Cache*" \
                    -o -path "*log*" -o -path "*logs*" -o -path "*.log*" \
                    -o -path "*.git*" -o -path "*.gemini*" -o -path "*.claude*" \) \
            2>/dev/null | fzf --prompt="Select Directory: " --reverse --border --height 12)
    fi
    [ -n "$selected_dir" ] && [ -d "$selected_dir" ] && cd "$selected_dir"
}

# Remember last directory and open new terminals there
# (only when the shell starts in $HOME, so editors/tools opening a specific dir aren't overridden)
LAST_DIR_FILE="$HOME/.cache/zsh/last_dir"
if [[ -z "$CLAUDECODE" ]]; then
    autoload -Uz add-zsh-hook
    _save_last_dir() { print -r -- "$PWD" >| "$LAST_DIR_FILE" }
    add-zsh-hook chpwd _save_last_dir
    if [[ "$PWD" == "$HOME" && -r "$LAST_DIR_FILE" ]]; then
        _last_dir="$(<"$LAST_DIR_FILE")"
        [[ -d "$_last_dir" ]] && cd "$_last_dir"
        unset _last_dir
    fi
fi

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Adding for Azure Bash Completion
autoload bashcompinit && bashcompinit
source $(brew --prefix)/etc/bash_completion.d/az

# Load aliases and shortcuts if existent.
[ -f "$HOME/.config/shortcuts/shortcutrc" ] && source "$HOME/.config/shortcuts/shortcutrc"
[ -f "$HOME/.config/shortcuts/aliasrc" ] && source "$HOME/.config/shortcuts/aliasrc"

# Load zsh-syntax-highlighting; should be last.
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# Cortex CLI completion (disable via /settings in cortex)
[[ -s ~/.zsh/completions/cortex.zsh ]] && source ~/.zsh/completions/cortex.zsh
