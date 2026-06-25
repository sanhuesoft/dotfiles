# Plugins
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8,underline"
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Configuración de fzf
source <(fzf --zsh)
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

# Oh My Posh
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh)"
fi

# Zettelkasten
export ZK_NOTEBOOK_DIR='/Users/fabsanh/Mesh/'

# Antigravity IDE
export PATH="/Users/fabsanh/.antigravity-ide/antigravity-ide/bin:$PATH"

# Ocultar hints de Hombebrew
export HOMEBREW_NO_ENV_HINTS=1

# Configuro zoxide
eval "$(zoxide init zsh --cmd cd)"

## Acceso rápido
alias emdl='cd ~/Proyectos/emdl && python3 emdl.py'
alias zsh-conf='nvim ~/.zshrc'
alias so='source ~/.zshrc; clear'
alias nvim-conf='cd ~/.config/nvim'
alias clean='~/Proyectos/chrome_cleaner/chrome_cleaner.sh'
alias vps='export TERM=xterm-256color; ssh -i ~/.ssh/id_ed25519_vps root@86.48.16.142'

# NPM
alias nrd='npm run dev'
alias nrb='npm run build'

## Markdown Vaults & nvim
alias M='cd ~/Mesh/; nvim'
alias R='cd ~/Obsidian/Replica; nvim'

# Sustitutos modernos para interactuar con CLI
alias ls='eza -lh --icons'
alias la='eza -lha --icons'
alias tree='eza -T --icons'
alias cat='bat'
alias diff='diff --color=auto'
alias vim='nvim'

# Aliases for git
alias gs='git status'
alias ga='git add .'
alias gp='git push'
alias gc='git commit -m'
alias gcam='git commit --amend'
alias glog='git log --decorate'

# YT-DLP para descargar en mp3
alias yt-mp3='yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --embed-metadata'

# Otros aliases
alias c='clear'
alias nv='nvim'
alias 7z='7zz'
alias bi='brew install'

# Utilidades desactivadas
# bindkey '^[[A' history-substring-search-up
# bindkey '^[[B' history-substring-search-down
# bindkey '^Y' autosuggest-accept
# source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source $HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh
