# Inicialización de env-vars para Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Importación de aliases
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# Configuración de fzf
source <(fzf --bash)
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

# Inicialización de env-vars de Oh My Posh
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init bash --config 'tokyonight_storm')"
fi

# Definición del directorio de Zettelkasten
export ZK_NOTEBOOK_DIR='/Users/fabsanh/Mesh/'

# Exportación del PATH de Antigravity IDE
export PATH="/Users/fabsanh/.antigravity-ide/antigravity-ide/bin:$PATH"

# Otros ajustes de Homebrew
export HOMEBREW_NO_ENV_HINTS=1
export PATH="/opt/homebrew/bin:$PATH"
export PATH=$PATH:$HOME/go/bin

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
