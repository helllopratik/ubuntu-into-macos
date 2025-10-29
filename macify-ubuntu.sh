#!/usr/bin/env bash
# macify-ubuntu.sh — macOS-style transformation for Ubuntu (GNOME)
# Version 4.2 — Transparent Blue Top Panel + Auto Temp Cleanup Fix

set -euo pipefail
IFS=$'\n\t'

# ---- COLORS ----
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

ASSUME_YES=0

usage() {
    cat <<USAGE
Usage: $(basename "$0") [--yes]
Options:
  --yes       Assume yes for all prompts and package installs.
USAGE
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --yes) ASSUME_YES=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 2 ;;
    esac
done

info() { echo -e "${GREEN}[*] $*${NC}"; }
warn() { echo -e "${YELLOW}[!] $*${NC}"; }
err()  { echo -e "${RED}[x] $*${NC}" >&2; }

# ---- REQUIREMENTS ----
info "Updating packages..."
sudo apt update -y
if [ "$ASSUME_YES" -eq 1 ]; then sudo apt upgrade -y; fi

PKGS=(gnome-tweaks gnome-shell-extensions plank unzip git curl wget dconf-cli plymouth-themes fonts-cantarell gnome-shell-extension-manager)
sudo apt install -y "${PKGS[@]}"

# ---- DIRECTORIES ----
THEME_DIR="$HOME/.themes"
ICON_DIR="$HOME/.icons"
FONT_DIR="$HOME/.local/share/fonts"
SOUND_DIR="$HOME/.local/share/sounds"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions"
mkdir -p "$THEME_DIR" "$ICON_DIR" "$FONT_DIR" "$SOUND_DIR" "$EXT_DIR"

clone_repo() {
    local repo="$1" dest="$2"
    if [ ! -d "$dest/.git" ]; then
        git clone --depth=1 "$repo" "$dest"
    else
        git -C "$dest" pull --rebase || true
    fi
}

safe_cleanup() {
    local dir="$1"
    if [ -d "$dir" ]; then
        info "Cleaning up temporary directory: $dir"
        if rm -rf "$dir" 2>/dev/null; then
            info "Removed $dir successfully."
        else
            warn "Permission denied for $dir, retrying with sudo..."
            sudo chattr -i -R "$dir" 2>/dev/null || true
            sudo rm -rf "$dir" || warn "Could not remove $dir, skipping."
        fi
    fi
}

# ---- THEMES ----
info "Installing WhiteSur themes and icons..."
clone_repo "https://github.com/vinceliuice/WhiteSur-gtk-theme.git" "$THEME_DIR/WhiteSur-gtk-theme"
bash "$THEME_DIR/WhiteSur-gtk-theme/install.sh" -t all -c Light -c Dark --dest "$THEME_DIR" || warn "GTK theme failed."

clone_repo "https://github.com/vinceliuice/WhiteSur-icon-theme.git" "$ICON_DIR/WhiteSur-icon-theme"
bash "$ICON_DIR/WhiteSur-icon-theme/install.sh" --dest "$ICON_DIR" || warn "Icon theme failed."

# ---- CURSOR ----
info "Installing macOS Cursor..."
clone_repo "https://github.com/ful1e5/apple_cursor.git" "$ICON_DIR/apple_cursor"
CUR_TAR=$(find "$ICON_DIR/apple_cursor" -maxdepth 1 -type f -iname "*.tar*" | head -n1 || true)
[ -n "$CUR_TAR" ] && tar -xf "$CUR_TAR" -C "$ICON_DIR" || warn "Cursor extract skipped."

# ---- FONTS ----
info "Installing SF Pro Fonts..."
clone_repo "https://github.com/sahibjotsaggu/San-Francisco-Pro-Fonts.git" "$FONT_DIR/SF-Pro"
fc-cache -fv

# ---- SOUNDS ----
info "Installing macOS Sounds..."
if [ ! -d "$SOUND_DIR/macOS" ]; then
    mkdir -p "$SOUND_DIR/macOS"
    wget -qO /tmp/macos-sounds.zip https://github.com/EliverLara/macOS-sound-theme/archive/refs/heads/master.zip
    unzip -q /tmp/macos-sounds.zip -d /tmp/
    mv /tmp/macOS-sound-theme-master/* "$SOUND_DIR/macOS/"
    echo "Sound Theme Name=macOS" > "$SOUND_DIR/macOS/index.theme"
    safe_cleanup "/tmp/macOS-sound-theme-master"
    safe_cleanup "/tmp/macos-sounds.zip"
fi

# ---- PLYMOUTH ----
info "Installing macOS Plymouth Splash..."
TMP_PLYMOUTH=$(mktemp -d)
sudo git clone --depth=1 https://github.com/adi1090x/plymouth-themes.git "$TMP_PLYMOUTH"
THEME_PATH=$(find "$TMP_PLYMOUTH" -type d -iname "macos*" | head -n1 || true)
if [ -n "$THEME_PATH" ]; then
    sudo rm -rf /usr/share/plymouth/themes/macos-plymouth
    sudo cp -r "$THEME_PATH" /usr/share/plymouth/themes/macos-plymouth
    sudo plymouth-set-default-theme -R macos-plymouth || warn "Plymouth theme skipped."
fi
safe_cleanup "$TMP_PLYMOUTH"

# ---- APPLY BASIC SETTINGS ----
info "Applying macOS Theme..."
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-light"
gsettings set org.gnome.desktop.wm.preferences theme "WhiteSur-light"
gsettings set org.gnome.desktop.interface icon-theme "WhiteSur"
gsettings set org.gnome.desktop.interface cursor-theme "macOS Big Sur"
gsettings set org.gnome.desktop.interface font-name "SF Pro Display 11"
gsettings set org.gnome.desktop.sound theme-name "macOS"

# ---- DISABLE UBUNTU DOCK & ENABLE DASH-TO-DOCK ----
info "Configuring Dock..."
gnome-extensions disable ubuntu-dock@ubuntu.com || true
gnome-extensions enable dash-to-dock@micxgx.gmail.com || warn "Dash to Dock not installed!"
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'DYNAMIC'
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.2
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 42

# ---- BLUR MY SHELL (TOP PANEL TRANSPARENCY) ----
info "Installing & enabling Blur My Shell extension (for transparent blue top bar)..."
BLUR_UUID="blur-my-shell@aunetx"
BLUR_DIR="$EXT_DIR/$BLUR_UUID"

clone_repo "https://github.com/aunetx/blur-my-shell.git" "$BLUR_DIR"
if [ -d "$BLUR_DIR/schemas" ]; then
    glib-compile-schemas "$BLUR_DIR/schemas"
fi

gnome-extensions enable "$BLUR_UUID" || warn "Could not enable Blur My Shell (enable manually)."

if gsettings list-schemas | grep -q "org.gnome.shell.extensions.blur-my-shell"; then
    gsettings set org.gnome.shell.extensions.blur-my-shell.static-blur true
    gsettings set org.gnome.shell.extensions.blur-my-shell.sigma 40
    gsettings set org.gnome.shell.extensions.blur-my-shell.brightness 0.95
    gsettings set org.gnome.shell.extensions.blur-my-shell.color '#1E88E5'
    gsettings set org.gnome.shell.extensions.blur-my-shell.panel true
    gsettings set org.gnome.shell.extensions.blur-my-shell.panel-opacity 0.35
else
    warn "Could not find blur-my-shell schema — transparency skipped."
fi

# ---- PLANK AUTOSTART ----
mkdir -p ~/.config/autostart
cat <<EOF > ~/.config/autostart/plank.desktop
[Desktop Entry]
Type=Application
Exec=plank
X-GNOME-Autostart-enabled=true
Name=Plank Dock
Comment=macOS-like Dock
EOF

# ---- DONE ----
info "🎉 macOS Look Successfully Applied!"
echo "🔁 Please log out and log back in for all changes to take effect."
echo "💡 Open 'Extensions' → ensure 'Dash to Dock' and 'Blur My Shell' are ON."
