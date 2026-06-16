# Plugins
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# Configurar fzf key bindings
source <(fzf --zsh)

# Oh My Posh
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh)"
fi

# Plugins
plugins=(git colored-man-pages)

# Path de tu Zettelkasten
export ZK_NOTEBOOK_DIR='/Users/fabsanh/Mesh/'

# Antigravity IDE
export PATH="/Users/fabsanh/.antigravity-ide/antigravity-ide/bin:$PATH"

# Ocultar hints de Hombebrew
export HOMEBREW_NO_ENV_HINTS=1

# Configuro zoxide
eval "$(zoxide init zsh)"

# Aliases personales
alias emdl='cd ~/Proyectos/emdl && python3 emdl.py'
alias s='source ~/.zshrc && clear'
alias zsh-conf='nvim ~/.zshrc'
alias Mesh='cd ~/Mesh/; nvim'
alias Replica='cd ~/Obsidian/Replica; nvim'
alias l='ls -lG'
alias la='ls -la'
alias cl='clear'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nv='nvim'
alias 7z='7zz'
alias nvim-conf='cd ~/.config/nvim'
alias clean='~/Proyectos/chrome_cleaner/chrome_cleaner.sh'
alias bi='brew install'

# Función yt-mp3
yt-mp3() {
    yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --embed-metadata "$1"
}

# Bindings para plugins de ZSH
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^Y' autosuggest-accept
