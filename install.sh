#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

need_cmd() { command -v "$1" >/dev/null 2>&1; }
is_arch() { need_cmd pacman; }

backup_file() {
  local target="$1"
  if [ -e "$target" ] || [ -L "$target" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "Backing up $target -> $BACKUP_DIR"
    mv "$target" "$BACKUP_DIR/"
  fi
}

link_file() {
  local src="$1"
  local dest="$2"
  backup_file "$dest"
  echo "Linking $dest -> $src"
  ln -s "$src" "$dest"
}

enable_user_audio() {
  # PipeWire user units
  systemctl --user enable --now pipewire pipewire-pulse wireplumber
}

enable_services() {
  sudo systemctl enable --now NetworkManager

  # Bluetooth optional
  if systemctl list-unit-files | grep -q '^bluetooth\.service'; then
    sudo systemctl enable --now bluetooth
  fi
}

install_packages_arch() {
  echo "==> Sync + upgrade"
  sudo pacman -Sy --needed archlinux-keyring >/dev/null 2>&1 || true
  sudo pacman -Syu --noconfirm

  # This list is tuned for typical Hyprland + Waybar configs.
  # Adjust over time as your dotfiles evolve.
  PKGS=(
    # Hyprland + portals
    hyprland
    xdg-desktop-portal
    xdg-desktop-portal-hyprland

    # Bar + common modules
    waybar
    pavucontrol
    playerctl
    brightnessctl

    # Tray applets / connectivity
    networkmanager
    network-manager-applet
    blueman
    bluez
    bluez-utils

    # Audio
    pipewire
    pipewire-alsa
    pipewire-pulse
    wireplumber

    # Clipboard / screenshots
    wl-clipboard
    grim
    slurp
    swappy

    # Auth agent (GUI prompts)
    polkit-kde-agent

    # Terminal (if your configs assume kitty)
    kitty

    # Fonts/icons that configs commonly rely on
    ttf-jetbrains-mono-nerd
    noto-fonts
    noto-fonts-emoji
    papirus-icon-theme
  )

  echo "==> Installing packages"
  sudo pacman -S --needed "${PKGS[@]}"

  echo "==> Enabling services"
  enable_services

  echo "==> Enabling user audio services"
  enable_user_audio

  echo "==> Optional: install + enable SDDM (graphical login)"
  read -r -p "Install and enable SDDM? [y/N] " ans
  if [[ "$ans" =~ ^([yY]|yes|YES)$ ]]; then
    sudo pacman -S --needed sddm
    sudo systemctl enable sddm
    echo "SDDM enabled. Start now with: sudo systemctl start sddm"
    echo "Or reboot."
  fi
}

link_dotfiles() {
  echo
  echo "Dotfiles directory: $DOTFILES_DIR"
  echo "Backup directory:   $BACKUP_DIR"
  echo

  read -r -p "Symlink dotfiles into \$HOME (backs up existing files)? [y/N] " ans
  case "$ans" in
    y|Y|yes|YES) ;;
    *) echo "Skipping linking."; return 0 ;;
  esac

  echo
  echo "==> Linking ~/.config/* from config/"
  mkdir -p "$HOME/.config"

  if [ -d "$DOTFILES_DIR/config" ]; then
    for item in "$DOTFILES_DIR"/config/*; do
      [ -e "$item" ] || continue
      name="$(basename "$item")"
      link_file "$item" "$HOME/.config/$name"
    done
  else
    echo "No config/ directory found, skipping."
  fi

  echo
  echo "==> Linking ~/bin/* from bin/"
  mkdir -p "$HOME/bin"

  if [ -d "$DOTFILES_DIR/bin" ]; then
    chmod +x "$DOTFILES_DIR"/bin/* 2>/dev/null || true
    for item in "$DOTFILES_DIR"/bin/*; do
      [ -e "$item" ] || continue
      name="$(basename "$item")"
      link_file "$item" "$HOME/bin/$name"
    done
  else
    echo "No bin/ directory found, skipping."
  fi

  echo
  if [ -d "$BACKUP_DIR" ]; then
    echo "Existing files were moved to: $BACKUP_DIR"
  fi

  echo
  echo "Next steps (no reboot required):"
  echo "  - Reload shell: exec bash"
  echo "  - Reload Hyprland (if running): hyprctl reload"
  echo "  - Restart Waybar if needed: pkill waybar; waybar &"
}

usage() {
  cat <<EOF
Usage:
  ./install.sh            # Interactive: ask what to do
  ./install.sh --link     # Only link dotfiles
  ./install.sh --full     # Install packages/services + link dotfiles (fresh install)
EOF
}

main() {
  local mode="${1:-}"

  case "$mode" in
    --help|-h) usage; exit 0 ;;
    --link)
      link_dotfiles
      ;;
    --full)
      if ! is_arch; then
        echo "Error: --full currently supports Arch (pacman) only."
        exit 1
      fi
      install_packages_arch
      link_dotfiles
      ;;
    "")
      echo "Choose what to do:"
      echo "  1) Link dotfiles only"
      echo "  2) Full install (packages + services) then link dotfiles"
      echo "  3) Quit"
      read -r -p "Select [1-3]: " choice
      case "$choice" in
        1) link_dotfiles ;;
        2)
          if ! is_arch; then
            echo "Full install supports Arch (pacman) only."
            exit 1
          fi
          install_packages_arch
          link_dotfiles
          ;;
        *) echo "Done."; exit 0 ;;
      esac
      ;;
    *)
      echo "Unknown option: $mode"
      usage
      exit 1
      ;;
  esac
}

main "$@"

