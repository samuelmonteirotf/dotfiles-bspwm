# ╔══════════════════════════════════════════════════════════╗
# ║  ~/.zshrc · NEXUS · Red Team / Crimson                    ║
# ║  base LEAN (sem oh-my-zsh / sem powerlevel10k) ~28ms      ║
# ╚══════════════════════════════════════════════════════════╝

# ════════════════════════════════════════════════════════════
#  1. BASE LEAN  (substitui o preset cachyos-zsh-config)
# ════════════════════════════════════════════════════════════

export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"
export EDITOR="${EDITOR:-nvim}"
export VISUAL="$EDITOR"
export FZF_BASE=/usr/share/fzf

# ── Completions (compinit ≤1×/dia via cache) ────────────────
autoload -Uz compinit
_zcd=${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump
if [[ -n $_zcd(#qN.mh+24) ]]; then compinit -d "$_zcd"; else compinit -C -d "$_zcd"; fi
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{#ff9e3d}[%d]%f'
zstyle ':completion:*:warnings'     format '%F{#8a0f1d}sem matches%f'
command -v dircolors >/dev/null && eval "$(dircolors -b)"
[[ -n $LS_COLORS ]] && zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ── Correção leve de comandos ───────────────────────────────
setopt CORRECT

# ── Cores do `man` (less) ───────────────────────────────────
export LESS_TERMCAP_md="$(tput bold 2>/dev/null; tput setaf 1 2>/dev/null)"  # crimson
export LESS_TERMCAP_me="$(tput sgr0 2>/dev/null)"

# ── Aliases Arch (resgatados do preset CachyOS) ─────────────
alias make="make -j$(nproc)"
alias ninja="ninja -j$(nproc)"
alias n="ninja"
alias c="clear"
alias rmpkg="sudo pacman -Rsn"
alias cleanch="sudo pacman -Scc"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias update="sudo pacman -Syu"
alias apt="man pacman"
alias apt-get="man pacman"
alias please="sudo"
alias tb="nc termbin.com 9999"
alias cleanup='sudo pacman -Rsn $(pacman -Qtdq)'
alias jctl="journalctl -p 3 -xb"
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# ── Git aliases curados (estilo oh-my-zsh) ──────────────────
alias g='git'
alias gst='git status'
alias gss='git status -s'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gcmsg='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git pull'
alias gp='git push'
alias gf='git fetch'
alias gsta='git stash push'
alias gstp='git stash pop'
alias grb='git rebase'
alias gm='git merge'
alias glog='git log --oneline --graph --decorate'
alias glola='git log --graph --pretty="%C(auto)%h%d %s %C(magenta)(%cr) %C(blue)<%an>"'

# ── extract: descompacta qualquer arquivo ───────────────────
extract() {
  local f
  for f in "$@"; do
    [[ -f $f ]] || { print -P "%F{#8a0f1d}não é arquivo:%f $f"; continue; }
    case $f in
      *.tar.bz2|*.tbz2) tar xjf "$f" ;;
      *.tar.gz|*.tgz)   tar xzf "$f" ;;
      *.tar.xz|*.txz)   tar xJf "$f" ;;
      *.tar.zst)        tar --zstd -xf "$f" ;;
      *.tar)            tar xf "$f" ;;
      *.bz2)            bunzip2 "$f" ;;
      *.gz)             gunzip "$f" ;;
      *.xz)             unxz "$f" ;;
      *.zst)            unzstd "$f" ;;
      *.zip)            unzip "$f" ;;
      *.rar)            unrar x "$f" ;;
      *.7z)             7z x "$f" ;;
      *)                print -P "%F{#8a0f1d}formato desconhecido:%f $f" ;;
    esac
  done
}

# ── pkgfile "command not found" handler ─────────────────────
[[ -r /usr/share/doc/pkgfile/command-not-found.zsh ]] && \
  source /usr/share/doc/pkgfile/command-not-found.zsh

# ════════════════════════════════════════════════════════════
#  2. RED TEAM overlay  (sobrepõe a base acima)
# ════════════════════════════════════════════════════════════

# ── História mais robusta ───────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE \
       HIST_REDUCE_BLANKS HIST_VERIFY SHARE_HISTORY INC_APPEND_HISTORY
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS GLOB_DOTS

# ── Cores dos plugins (autosuggest + syntax-highlight) ──────
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#5c2731'
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#ff2b43,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#ff5563'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#ff5563'
ZSH_HIGHLIGHT_STYLES[function]='fg=#ff9e3d'
ZSH_HIGHLIGHT_STYLES[path]='fg=#d7dae0,underline'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#8a0f1d,bold'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#ffc777'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#ffc777'

# ── Aliases · ferramentas modernas ──────────────────────────
alias ls='eza --group-directories-first --icons'
alias l='eza -lh --group-directories-first --icons --git'
alias ll='eza -lah --group-directories-first --icons --git'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --style=plain --paging=never'
alias catt='bat'
alias ip='ip -color=auto'
alias df='df -h'
alias mv='mv -i'
alias cp='cp -i'
alias ..='cd ..'
alias ...='cd ../..'
alias ports='ss -tulpn'
alias myip='curl -s ifconfig.me; echo'
alias serve='python -m http.server'
alias reload='exec zsh'
alias ff='fastfetch'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# ── fzf · tema red team ─────────────────────────────────────
export FZF_DEFAULT_OPTS="
  --height 45% --layout=reverse --border=rounded --margin=1 --padding=1
  --prompt='  ' --pointer='▶' --marker='✓'
  --color=bg+:#1d1014,bg:-1,spinner:#ff2b43,hl:#ff5563
  --color=fg:#d7dae0,header:#ff5563,info:#ff9e3d,pointer:#ff2b43
  --color=marker:#3fb950,fg+:#f4f6fa,prompt:#ff2b43,hl+:#ff2b43,border:#5c2731"

# ── Greeting: system info ao abrir terminal interativo ──────
if [[ -o interactive && -z "$NEXUS_GREETED" ]]; then
  export NEXUS_GREETED=1
  command -v fastfetch >/dev/null && fastfetch
fi

# ── Ferramentas de Produtividade ────────────────────────────
eval "$(starship init zsh)"   # prompt NEXUS Crimson
eval "$(zoxide init zsh)"      # cd inteligente (z)
eval "$(atuin init zsh)"       # histórico melhorado (ctrl+r)
eval "$(navi widget zsh)"      # cheatsheets interativos (ctrl+g)

alias lg='lazygit'
alias y='yazi'
alias ps='procs'
alias du='dust -r'
alias cloc='tokei'
alias zj='zellij'

# ── onefetch ao entrar num repo git diferente ───────────────
autoload -Uz add-zsh-hook
_nexus_last_repo=""
_nexus_onefetch() {
  command -v onefetch >/dev/null || return
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || { _nexus_last_repo=""; return }
  [[ $root == $_nexus_last_repo ]] && return   # mesmo repo → não repete
  _nexus_last_repo=$root
  onefetch 2>/dev/null
}
add-zsh-hook chpwd _nexus_onefetch

# ════════════════════════════════════════════════════════════
#  3. PLUGINS  (sourced por último — ordem importa)
# ════════════════════════════════════════════════════════════
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# ── Keybindings: setas ↑↓ buscam no histórico pelo prefixo ──
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey "${terminfo[kcuu1]}" history-substring-search-up
bindkey "${terminfo[kcud1]}" history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# Node via fnm
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd --shell zsh)"

# Java 17
export JAVA_HOME="$HOME/.local/jdks/jdk-17.0.19+10"
export PATH="$JAVA_HOME/bin:$PATH"

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

# ── VM Kali (libvirt/QEMU) ───────────────────────────────────────────────
# Usa sempre a instância de sistema (sem precisar de -c qemu:///system)
export LIBVIRT_DEFAULT_URI=qemu:///system
KALI_VM="kali"
KALI_BASE_SNAP="base-clean-claude"   # snapshot do "estado limpo" atual

# Energia
alias kali-start='virsh start "$KALI_VM"'          # ligar
alias kali-stop='virsh shutdown "$KALI_VM"'        # desligar (ACPI, limpo)
alias kali-kill='virsh destroy "$KALI_VM"'         # forçar desligamento
alias kali-reboot='virsh reboot "$KALI_VM"'        # reiniciar
alias kali-view='virt-viewer "$KALI_VM" &>/dev/null &!'  # abrir a tela

# Status
alias kali-status='virsh list --all'               # estado das VMs
alias kali-ip='virsh domifaddr "$KALI_VM" --source lease'  # IP da VM

# Snapshots
alias kali-snaps='virsh snapshot-list "$KALI_VM"'  # listar snapshots
alias kali-clear='virsh snapshot-revert "$KALI_VM" "$KALI_BASE_SNAP"'  # VOLTAR ao estado limpo
# kali-save <nome> [descricao]  -> cria um novo snapshot (disco + RAM)
kali-save() { virsh snapshot-create-as --domain "$KALI_VM" --name "$1" --description "${2:-snapshot manual}" --atomic; }
# kali-restore <nome>  -> volta para um snapshot qualquer
kali-restore() { virsh snapshot-revert "$KALI_VM" "$1"; }
# kali-rmsnap <nome>   -> apaga um snapshot
kali-rmsnap() { virsh snapshot-delete "$KALI_VM" "$1"; }
# ─────────────────────────────────────────────────────────────────────────


# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"
alias friday='agy --dangerously-skip-permissions'
