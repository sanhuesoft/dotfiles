# Importo subconfigs
source ~/.zsh_aliases

# Plugins
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8,underline"
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Configuración de fzf
source <(fzf --zsh)
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

# Oh My Posh
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config 'amro')"
fi

# Zettelkasten
export ZK_NOTEBOOK_DIR='/Users/fabsanh/Mesh/'

# Antigravity IDE
export PATH="/Users/fabsanh/.antigravity-ide/antigravity-ide/bin:$PATH"

# Ocultar hints de Hombebrew
export HOMEBREW_NO_ENV_HINTS=1

# Configuro zoxide
eval "$(zoxide init zsh)"
