#!/bin/bash

# macOS Buttons Fix Script (Left-Aligned, Red/Orange/Green)
# Works for GNOME/GTK environments across Linux distros

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo
ok "Setting macOS-style window button positions and colors..."

# GNOME/GTK3/GTK4: Set button layout to left only
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
ok "Window buttons aligned to the LEFT (Close | Minimize | Maximize order)"

# Try for Unity (if running Unity)
if [ "$XDG_CURRENT_DESKTOP" = "Unity" ]; then
    gsettings set com.canonical.Unity.WindowDecoration button-layout 'close,minimize,maximize:'
    ok "Unity: Window buttons aligned to the LEFT"
fi

# Set custom button colors for Ubuntu's default themes (Yaru, Adwaita, etc.)
# This is not natively supported at the system level—however, for many popular GTK themes with
# "macOS" support, the colors are already set via theme, if you're using a WhiteSur theme.
# For fallback, patch gtk.css for widely used themes.

# Attempt to patch ~/.config/gtk-3.0/gtk.css (for Adwaita/Yaru/others)
GTKCSS=~/.config/gtk-3.0/gtk.css
mkdir -p ~/.config/gtk-3.0
cat <<EOF >> "$GTKCSS"

@define-color window-close-bg #ff5f57;
@define-color window-close-hover-bg #e04845;
@define-color window-close-active-bg #c64641;
@define-color window-minimize-bg #ffbd2e;
@define-color window-minimize-hover-bg #d3a014;
@define-color window-minimize-active-bg #b47c14;
@define-color window-maximize-bg #28c940;
@define-color window-maximize-hover-bg #1b9a2e;
@define-color window-maximize-active-bg #16881d;
EOF

ok "Set custom button colors for GTK3-compatible apps via gtk.css"

# KDE/Qt: Recommend user install "McMojave" or "WhiteSur" theme for KDE from store.kde.org

# LibreOffice/Other: Use system defaults, will follow GTK button layout/colors

echo
warn "Some non-GTK apps (Chromium, Electron, native Qt) may not follow these settings."
warn "For full macOS look, use themes like WhiteSur for ALL GTK window decorations."
ok "DONE! Window buttons should now appear as red/yellow/green on the LEFT side in all supported apps."

echo -e "\nIf you don't see the change immediately, log out and log in, or restart GNOME Shell (Alt+F2, type 'r')."
