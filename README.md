# dotfiles-bspwm · NEXUS Red Team / Crimson

Personal **BSPWM** rice for Arch Linux (CachyOS), themed around a crimson
"Red Team" palette. Everything here is symlinked into `$HOME` by `setup.sh`.

```
  WM        bspwm + sxhkd
  Bar       polybar
  Compositor picom (glx, dual-kawase blur)
  Launcher  rofi (drun / clipboard / power / screenshot)
  Notifs    dunst
  Lock      betterlockscreen
  Terminal  ghostty (primary) · alacritty (fallback)
  Shell     zsh + starship + zoxide + atuin + fnm
  Theme     GTK Graphite-red-Dark · Qt qt5ct (crimson) · Papirus-Dark · Bibata
  Wallpaper feh
  Fetch     fastfetch
```

## Layout

The repo mirrors the structure of `$HOME`, so the path of every file in the
repo is exactly where it ends up on disk:

```
.config/
  bspwm/bspwmrc            picom/picom.conf        rofi/{config,redteam}.rasi
  sxhkd/sxhkdrc            dunst/dunstrc           rofi/scripts/screenshot.sh
  polybar/config.ini       alacritty/alacritty.toml
  polybar/launch.sh        ghostty/config          betterlockscreen/betterlockscreenrc
  polybar/scripts/*.sh     fastfetch/config.jsonc  starship.toml
  gtk-3.0/settings.ini     gtk-4.0/settings.ini    qt5ct/{qt5ct.conf,colors/redteam.conf}
  wallpapers/*.png
.zshrc  .zshenv  .xprofile  .fehbg  .gtkrc-2.0  .gitconfig
setup.sh  .gitignore  .stow-local-ignore
```

## Install

```sh
git clone <this-repo> ~/dotfiles-bspwm
cd ~/dotfiles-bspwm
./setup.sh --dry-run   # preview — changes nothing
./setup.sh             # symlink everything, backing up conflicts
```

`setup.sh`:

- **Symlinks** each entry into `$HOME` with `ln -sfn` (directories become
  directory symlinks, single files become file symlinks).
- **Backs up** anything already present to `~/.dotfiles-backup-<timestamp>/`
  before linking — it never overwrites your files in place.
- Is **idempotent**: re-running skips links that are already correct.
- `--stow` delegates to GNU Stow instead of plain `ln`; `--uninstall` removes
  the symlinks it created; `--help` lists options.

After installing, restart the WM with `super + alt + r` (`bspc wm -r`) or log
back into the bspwm session.

## Dependencies

Core: `bspwm sxhkd polybar picom rofi dunst betterlockscreen feh fastfetch
ghostty alacritty zsh starship`.
Helpers referenced by the configs: `greenclip` (rofi clipboard), `maim`
`xclip` `xdotool` (screenshots), `nvidia-smi`/`nvidia-settings` (GPU modules &
bspwmrc tuning), `zoxide` `atuin` `fnm` `eza` `bat` `fzf` (shell).
Fonts: `MesloLGL Nerd Font`, `FantasqueSansM Nerd Font`.

## Notes & sanitization

This repo was generated from a live system and **sanitized**:

- `.gitconfig` ships with placeholder `user.name` / `user.email` — set your own
  with `git config --global user.name/user.email`.
- Hardcoded `/home/<user>` paths were replaced with `$HOME`.
- No shell history, SSH/GPG keys, API tokens, or secret-manager state
  (`atuin`, `sops`, `stripe`, …) are included; `.gitignore` keeps them out.

System-specific bits you may want to adjust:

- `bspwmrc` / `.xprofile` assume a single **`DP-2`** output at **2560x1440@165**
  with an **NVIDIA** GPU (G-Sync, PowerMizer, clock offsets). Edit the
  `xrandr` / `nvidia-settings` lines for your hardware.
- The polybar GPU/temp modules call `nvidia-smi` and read `coretemp` hwmon.
- `qt5ct.conf` references the crimson palette via
  `color_scheme_path=$HOME/.config/qt5ct/colors/redteam.conf`. qt5ct does **not**
  expand `$HOME`, so if Qt apps don't pick up the crimson colors, open *qt5ct* and
  re-select the **redteam** color scheme once (it rewrites the path absolutely).
