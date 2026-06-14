# dotfiles-bspwm - Declarative Unix Desktop Environment

This repository contains the declarative Configuration-as-Code (CoC) files for a hardened, performance-optimized bspwm desktop workspace on Arch Linux. Every component is managed modularly, allowing reproducible environments across workstation nodes.

```
  Window Manager   bspwm + sxhkd
  Status Bar       polybar
  Compositor       picom (glx backend, dual-kawase blur)
  App Launcher     rofi (drun, clipboard, power menu, screenshot utility)
  Notifications    dunst
  Lockscreen       betterlockscreen
  Terminals        ghostty (primary), alacritty (fallback)
  Shell            zsh + starship prompt + zoxide
  Theming          GTK Graphite-red-Dark, Qt qt5ct (Crimson), Papirus-Dark, Bibata
  Display Manager  feh (wallpaper configuration)
  System Fetch     fastfetch
```

## Repository Structure

The repository structure mirrors the `$HOME` directory layout. Configurations are systematically organized to allow direct symlinking:

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

## Workstation Deployment

An automated shell installer handles workspace setup. The script is designed with standard DevOps reliability principles: it is fully idempotent, isolates failures per item, and executes dry-run simulations.

```sh
# Clone the configuration-as-code workspace
git clone git@github.com:samuelmonteirotf/dotfiles-bspwm.git ~/dotfiles-bspwm
cd ~/dotfiles-bspwm

# Execute a dry-run check to preview link targets and conflicts
./setup.sh --dry-run

# Run the installation
./setup.sh
```

### Installation Engine Specifications

The `setup.sh` installer operates under the following automation constraints:

- **Backup Isolation:** If a conflicting configuration directory or file is found in `$HOME`, it is moved to a timestamped backup directory at `~/.dotfiles-backup-YYYYMMDD-HHMMSS/` prior to linking. It never overwrites user data in-place.
- **Idempotency:** Re-running the script skips existing, correctly configured links and runs with zero overhead.
- **Error Isolation:** Command failures during setup are isolated. If one item fails to link, the installer reports the failure, tracks it, and continues processing the remaining configuration items.
- **Stow Compatibility:** Supports GNU Stow deployment. The `--stow` flag delegates linking to stow, using `.stow-local-ignore` to prevent installer scripts from polluting `$HOME`.

To reload the workstation environment after deployment, restart bspwm using the binding `super + alt + r` (runs `bspc wm -r`).

## Package Dependencies

The dependencies required to run this environment are documented in the package lists.

- **Core Workspace:** `bspwm`, `sxhkd`, `polybar`, `picom`, `rofi`, `dunst`, `betterlockscreen`, `feh`, `fastfetch`, `ghostty`, `alacritty`, `zsh`, `starship`.
- **Workspace Helpers:** `rofi-greenclip` (clipboard manager), `maim`, `xclip`, `xdotool` (screenshot pipeline), `nvidia-smi`, `nvidia-settings` (GPU performance metrics), `zoxide` (directory navigation).
- **Workstation Theming:** `ttf-meslo-nerd`, `papirus-icon-theme`, `qt5ct`, `graphite-gtk-theme`, `bibata-cursor-theme`.

The `.zshrc` integrates with CLI tools like `fnm`, `lazygit`, `yazi`, and `fzf`. Every tool is wrapped in guard checks (`command -v`), ensuring the shell loads cleanly even if optional utilities are missing.

## Security and Sanitization Pipeline

This repository is sanitized before publication using automated workflows to prevent data leaks:

- **Credential Protection:** `.gitconfig` contains placeholder name and email configurations.
- **State Exclusion:** Configuration files and history stores for tools like `atuin`, `sops`, `stripe`, SSH keys, GPG keys, and shell history are ignored globally via `.gitignore`.
- **Path Virtualization:** All hardcoded absolute home paths (e.g., `/home/user/`) are virtualized to `$HOME` to ensure system compatibility.

### System Adjustments

You may need to modify specific hardware metrics in your workstation copy:

- **Display Configuration:** `bspwmrc` and `.xprofile` configure a `DP-2` monitor output running at 2560x1440 at 165Hz. Adjust this to match your system display name and resolution.
- **GPU Metrics:** Polybar temperature modules poll `nvidia-smi` and local CPU hwmon endpoints.
- **Qt Theming:** `qt5ct.conf` points to the color scheme at `$HOME/.config/qt5ct/colors/redteam.conf`. Because qt5ct does not expand env variables natively, open the `qt5ct` GUI tool and re-save the redteam palette to resolve pathing on new installations.
