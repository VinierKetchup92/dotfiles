#!/usr/bin/env bash
set -euo pipefail

# Directory where this script (and your repo) lives
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Where to store backups of any existing files we overwrite
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

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

echo "Dotfiles directory: $DOTFILES_DIR"
echo "Backup directory:   $BACKUP_DIR"
echo

read -r -p "This will overwrite existing dotfiles with symlinks. Continue? [y/N] " ans
case "$ans" in
    y|Y|yes|YES) ;;
    *) echo "Aborting."; exit 1 ;;
esac

echo
echo "==> Setting up ~/.bashrc and ~/.bash_profile"
if [ -f "$DOTFILES_DIR/.bashrc" ]; then
    link_file "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
fi

if [ -f "$DOTFILES_DIR/.bash_profile" ]; then
    link_file "$DOTFILES_DIR/.bash_profile" "$HOME/.bash_profile"
fi

echo
echo "==> Setting up ~/.config/* from config/"
mkdir -p "$HOME/.config"

if [ -d "$DOTFILES_DIR/config" ]; then
    for item in "$DOTFILES_DIR"/config/*; do
        [ -e "$item" ] || continue
        name="$(basename "$item")"
        link_file "$item" "$HOME/.config/$name"
    done
else
    echo "No config/ directory found in $DOTFILES_DIR, skipping."
fi

echo
echo "==> Setting up ~/bin from bin/"
mkdir -p "$HOME/bin"

if [ -d "$DOTFILES_DIR/bin" ]; then
    # Make sure everything in bin is executable
    chmod +x "$DOTFILES_DIR"/bin/* 2>/dev/null || true

    for item in "$DOTFILES_DIR"/bin/*; do
        [ -e "$item" ] || continue
        name="$(basename "$item")"
        link_file "$item" "$HOME/bin/$name"
    done
else
    echo "No bin/ directory found in $DOTFILES_DIR, skipping."
fi

echo
echo "All done."

if [ -d "$BACKUP_DIR" ]; then
    echo "Existing files were moved to: $BACKUP_DIR"
fi

echo
echo "Reminder:"
echo "  - Make sure ~/bin is in your PATH."
echo "  - Start a new shell or run: source ~/.bashrc"
