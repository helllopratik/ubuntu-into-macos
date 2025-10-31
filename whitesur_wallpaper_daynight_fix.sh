#!/bin/bash

# WhiteSur Wallpaper Setup Script (menu-based, auto day/night)
# Uses official WhiteSur-wallpapers repo, supports all variants & dynamic switching

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Output helpers
ok()   { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# Ensure git, sudo, and gsettings
for bin in git sudo gsettings; do
    command -v $bin >/dev/null || err "$bin is required. Please install first."; done

# Theme choice menu
echo
echo "========= WhiteSur Wallpaper Theme Selection =========="
echo "Which macOS wallpaper theme do you want?"
echo "1) WhiteSur (macOS Big Sur style - Default)"
echo "2) Monterey"
echo "3) Ventura"
echo "4) Nord"
echo "5) All variants"
read -p "Enter choice [1-5]: " choice

case $choice in
    1) THEME=whitesur;;
    2) THEME=monterey;;
    3) THEME=ventura;;
    4) THEME=nord;;
    5) THEME=all;;
    *) err "Invalid choice. Exiting.";;
esac

# Resolution menu
echo
echo "What screen resolution do you want?"
echo "1) 1080p"
echo "2) 2k"
echo "3) 4k (default)"
read -p "Enter choice [1-3]: " reschoice

case $reschoice in
    1) SCREEN=1080p;;
    2) SCREEN=2k;;
    3|"") SCREEN=4k;;
    *) err "Invalid choice. Exiting.";;
esac

echo
ok "Cloning WhiteSur-wallpapers repo..."
TMPDIR=$(mktemp -d) || err "Failed to make temp dir"
cd $TMPDIR
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-wallpapers.git || err "Clone failed"
cd WhiteSur-wallpapers

# Build installer command dynamically (per readme)
CMD="sudo ./install-gnome-backgrounds.sh"
[[ "$THEME" != "all" ]] && CMD+=" -t $THEME"
[[ -n "$SCREEN" ]] && CMD+=" -s $SCREEN"

echo
warn "Installing GNOME backgrounds (system-wide, needs sudo)..."
echo "Running: $CMD"
eval $CMD || err "Wallpaper installer failed"

ok "Wallpapers and dynamic day/night backgrounds installed!"

# Optional: ask user to set the new dynamic wallpaper (will be in /usr/share/backgrounds/gnome)
WPDIR="/usr/share/backgrounds/gnome"
if [[ -d "$WPDIR" ]]; then
    # Try to find latest XML file for dynamic setup
    WALLS=$(find $WPDIR -name '*.xml' | grep -i -E "$THEME|monterey|ventura|whitesur|nord" | sort)
    if [[ -z "$WALLS" ]]; then
        warn "No dynamic wallpaper found in $WPDIR"
    else
        echo
        echo "Available dynamic day/night wallpapers:"
        i=1
        for x in $WALLS; do echo "$i) $(basename "$x")"; ((i++)); done
        read -p "Select number to apply as your desktop (or press Enter to skip): " num
        if [[ "$num" =~ ^[0-9]+$ ]] && (( num > 0 && num < i )); then
            CHOSEN=$(echo "$WALLS" | sed -n "${num}p")
            URI="file://$CHOSEN"
            gsettings set org.gnome.desktop.background picture-uri "$URI"
            gsettings set org.gnome.desktop.background picture-uri-dark "$URI"
            gsettings set org.gnome.desktop.screensaver picture-uri "$URI"
            ok "Wallpaper set: $(basename "$CHOSEN")"
        else
            warn "No wallpaper changed."
        fi
    fi
    echo
    ok "If you want to manually select later, use GNOME Settings > Background!"
else
    warn "Could not find $WPDIR. Please set the wallpaper manually in settings."
fi

cd ~
rm -rf "$TMPDIR"

ok "Script finished! Your macOS wallpaper with day/night effect is now set (including lock screen)."
