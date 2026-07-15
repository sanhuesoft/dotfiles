# ==============================================================================
# VERIFICACIÓN DE DEPENDENCIAS
# ==============================================================================
_missing_deps=""
for _cmd in python3 nvim ssh eza bat diff git yt-dlp 7zz brew; do
  if ! command -v "$_cmd" &>/dev/null; then
    _missing_deps="$_missing_deps $_cmd"
  fi
done

if [ ! -x "/Applications/VLC.app/Contents/MacOS/VLC" ]; then
  _missing_deps="$_missing_deps VLC"
fi

if [ -n "$_missing_deps" ]; then
  echo "=========================================================================="
  echo "❤️  ¡Hola, Fabián! Un mensajito de amor para tu terminal:"
  echo "   Noté que en este equipo te faltan algunas cositas para que todo brille:"
  echo "   👉 $_missing_deps"
  echo "   Tus aliases se van a cargar igual, pero esas herramientas no responderán"
  echo "   hasta que las instales. ¡Que tengas un tremendo día de código! ✨"
  echo "=========================================================================="
fi
unset _cmd _missing_deps

## Acceso rápido
alias emdl='cd ~/Proyectos/emdl && python3 emdl.py'
alias zsh-conf='nvim ~/.zshrc'
alias so='source ~/.zshrc; clear'
alias nvim-conf='cd ~/.config/nvim'
alias cleaner='~/Proyectos/chrome_cleaner/chrome_cleaner.sh'
alias ssh-con='export TERM=xterm-256color; ssh -i ~/.ssh/id_ed25519_vps fabsanh@86.48.16.142'
alias ssh-rbp='export TERM=xterm-256color; ssh -i ~/.ssh/id_ed25519_vps solar-assistant@192.168.100.6'
alias ssh-rai='export TERM=xterm-256color; ssh -i ~/.ssh/id_ed25519_vps fabsanh@raimapo -p 22'
alias mount-bacteria='sudo mkdir -p /Volumes/Bacteria && sudo mount -t nfs -o rw,tcp,rsize=65536,wsize=65536,locallocks raimapo:/mnt/bacteria /Volumes/Bacteria'
alias tmux-def='tmux attach-session -t default 2>/dev/null || tmux new-session -s default'

# NPM
alias nrd='npm run dev'
alias nrb='npm run build'

## Markdown Vaults & nvim
alias M='cd ~/Mesh/ && nvim'
alias R='cd ~/Obsidian/Replica && nvim'

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
alias gco='git commit -m'
alias gcam='git commit --amend'
alias glog='git log --decorate'

# YT-DLP para descargar en mp3
alias yt-mp3='yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --embed-metadata'

# Otros aliases
alias c='clear'
alias nv='nvim'
alias 7z='7zz'
alias bi='brew install'
alias vlc='/Applications/VLC.app/Contents/MacOS/VLC'
