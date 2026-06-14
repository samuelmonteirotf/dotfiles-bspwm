#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════╗
# ║  dotfiles-bspwm · NEXUS Red Team rice · installer         ║
# ╚══════════════════════════════════════════════════════════╝
#
# Symlinks the configs in this repository into your $HOME, backing up
# anything that is already there. Safe to re-run (idempotent).
#
#   ./setup.sh             install (symlink everything, backup conflicts)
#   ./setup.sh --dry-run   show what would happen, change nothing
#   ./setup.sh --stow      delegate to GNU Stow instead of plain ln -sf
#   ./setup.sh --uninstall remove the symlinks this script created
#   ./setup.sh --help      this help
#
set -euo pipefail

# ── Resolve repo dir from this script's real location (cwd-independent) ──
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
REPO_DIR="$SCRIPT_DIR"
TARGET="${HOME}"
BACKUP_DIR="${HOME}/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# ── Items to link, relative to both repo root and $HOME ─────────────────
# Directories become directory symlinks; files become file symlinks.
ITEMS=(
  # — BSPWM core —
  ".config/bspwm"
  ".config/sxhkd"
  # — Compositor / notifications / lockscreen —
  ".config/picom"
  ".config/dunst"
  ".config/betterlockscreen"
  # — Bar & launcher/menus —
  ".config/polybar"
  ".config/rofi"
  # — Terminals —
  ".config/alacritty"
  ".config/ghostty"
  # — GTK / Qt theming —
  ".config/gtk-3.0"
  ".config/gtk-4.0"
  ".config/qt5ct"
  ".gtkrc-2.0"
  # — Misc —
  ".config/fastfetch"
  ".config/starship.toml"
  ".config/wallpapers"
  # — Home-level shell / X session —
  ".zshrc"
  ".zshenv"
  ".xprofile"
  ".fehbg"
  ".gitconfig"
)

# ── Pretty output ───────────────────────────────────────────────────────
c_red=$'\033[1;31m'; c_grn=$'\033[1;32m'; c_yel=$'\033[1;33m'
c_dim=$'\033[2m';    c_rst=$'\033[0m'
info()  { printf '%s::%s %s\n'  "$c_red" "$c_rst" "$*"; }
ok()    { printf '  %s✓%s %s\n' "$c_grn" "$c_rst" "$*"; }
warn()  { printf '  %s!%s %s\n' "$c_yel" "$c_rst" "$*"; }
skip()  { printf '  %s·%s %s\n' "$c_dim" "$c_rst" "$*"; }

DRY_RUN=0; MODE="install"; USE_STOW=0
for arg in "$@"; do
  case "$arg" in
    --dry-run)   DRY_RUN=1 ;;
    --stow)      USE_STOW=1 ;;
    --uninstall) MODE="uninstall" ;;
    -h|--help)   sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $arg (try --help)"; exit 2 ;;
  esac
done

run() { if [ "$DRY_RUN" -eq 1 ]; then echo "    ${c_dim}would:${c_rst} $*"; else "$@"; fi; }

# ── GNU Stow path (optional) ────────────────────────────────────────────
# Non-config top-level files (setup.sh, README, .gitignore, backups) are kept
# out of $HOME by .stow-local-ignore, so --stow matches the plain install set.
stow_install() {
  command -v stow >/dev/null 2>&1 || { echo "GNU Stow not installed."; exit 1; }
  info "Stowing repository into $TARGET (conflicts are reported by stow)"
  local flags=(--target="$TARGET" --restow)
  [ "$DRY_RUN" -eq 1 ] && flags+=(--no --verbose)
  ( cd "$REPO_DIR" && stow "${flags[@]}" . )
  ok "stow complete"
}

# ── Uninstall: drop symlinks that point back into this repo ─────────────
uninstall() {
  info "Removing symlinks that point into $REPO_DIR"
  local item dest
  for item in "${ITEMS[@]}"; do
    dest="$TARGET/$item"
    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$REPO_DIR/$item")" ]; then
      run rm "$dest"; ok "unlinked $item"
    else
      skip "$item (not our symlink)"
    fi
  done
  warn "Backups (if any) were left untouched under ~/.dotfiles-backup-*"
}

# ── Link a single item. Returns non-zero on real failure so the caller can
#    record it and keep going (instead of set -e aborting the whole run). ──
link_item() {
  local item="$1" src dest backup_target
  src="$REPO_DIR/$item"
  dest="$TARGET/$item"

  if [ ! -e "$src" ]; then
    warn "missing in repo, skipping: $item"
    return 0
  fi

  # Already the correct symlink → nothing to do.
  if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
    skip "$item (already linked)"
    return 0
  fi

  # Ensure the parent directory exists (e.g. ~/.config).
  run mkdir -p "$(dirname "$dest")"

  # Back up an existing target (real file/dir or a foreign symlink).
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    backup_target="$BACKUP_DIR/$item"
    run mkdir -p "$(dirname "$backup_target")"
    run mv "$dest" "$backup_target"
    warn "backed up existing $item -> ${BACKUP_DIR/#$HOME/~}/$item"
  fi

  # -s symlink, -f force, -n treat existing dir symlink as a file.
  run ln -sfn "$src" "$dest"

  # Confirm the link actually landed (guards against ln-into-dir surprises).
  if [ "$DRY_RUN" -eq 0 ] && [ "$(readlink -f "$dest")" != "$(readlink -f "$src")" ]; then
    warn "link verification failed for $item"
    return 1
  fi

  ok "linked $item"
  return 0
}

# ── Install: per-item, isolating failures ───────────────────────────────
install() {
  info "Installing dotfiles from $REPO_DIR"
  [ "$DRY_RUN" -eq 1 ] && warn "DRY RUN — no changes will be made"

  local item failures=()
  for item in "${ITEMS[@]}"; do
    # `if !` keeps set -e from aborting: a failure in link_item is caught here,
    # recorded, and the loop continues with the next item.
    if ! link_item "$item"; then
      failures+=("$item")
    fi
  done

  echo
  if [ "$DRY_RUN" -eq 0 ] && [ -d "$BACKUP_DIR" ]; then
    info "Originals backed up to: $BACKUP_DIR"
  fi

  if [ "${#failures[@]}" -gt 0 ]; then
    warn "${#failures[@]} item(s) failed: ${failures[*]}"
    warn "Your originals are safe under ~/.dotfiles-backup-* — fix and re-run."
    return 1
  fi

  info "Done. Log out and back into the bspwm session (or: ${c_grn}bspc wm -r${c_rst})."
}

# ── Dispatch ────────────────────────────────────────────────────────────
case "$MODE" in
  uninstall) uninstall ;;
  install)   if [ "$USE_STOW" -eq 1 ]; then stow_install; else install; fi ;;
esac
