#!/bin/bash
# macify-ubuntu.sh — macOS-style transformation for Ubuntu (GNOME)

set -e

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "${GREEN}=== Macify Ubuntu ===${NC}"

# ---- 1. DEPENDENCIES ----
echo -e "${YELLOW}Updating packages and installing dependencies...${NC}"
sudo apt update -y
sudo apt install -y \
  gnome-tweaks gnome-shell-extensions plank wget unzip git curl dconf-cli plymouth-themes \
  fonts-cantarell gnome-shell-extension-manager

# ---- 2. DIRECTORIES ----
THEME_DIR="$HOME/.themes"
ICON_DIR="$HOME/.icons"
FONT_DIR="$HOME/.local/share/fonts"
SOUND_DIR="$HOME/.local/share/sounds"
BIN_DIR="$HOME/.local/bin"
mkdir -p "$THEME_DIR" "$ICON_DIR" "$FONT_DIR" "$SOUND_DIR" "$BIN_DIR"

# ---- 3. CLONE/UPDATE FUNCTION ----
clone_or_update_repo() {
    local repo_url="$1"
    local dest_dir="$2"
    if [ -d "$dest_dir/.git" ]; then
        echo -e "${YELLOW}Updating existing repo: $dest_dir${NC}"
        git -C "$dest_dir" pull --rebase || echo -e "${RED}Warning: Could not update $dest_dir${NC}"
    elif [ -d "$dest_dir" ]; then
        echo -e "${YELLOW}Directory exists, skipping: $dest_dir${NC}"
    else
        echo -e "${GREEN}Cloning: $repo_url${NC}"
        git clone --depth=1 "$repo_url" "$dest_dir"
    fi
}

# ---- 4. THEMES ----
echo -e "${GREEN}Installing macOS GTK Theme...${NC}"
clone_or_update_repo "https://github.com/vinceliuice/WhiteSur-gtk-theme.git" "$THEME_DIR/WhiteSur-gtk-theme"
cd "$THEME_DIR/WhiteSur-gtk-theme"
./install.sh -t all -c Light -c Dark --dest "$THEME_DIR" || echo "GTK theme install skipped."

echo -e "${GREEN}Installing macOS Icon Theme...${NC}"
clone_or_update_repo "https://github.com/vinceliuice/WhiteSur-icon-theme.git" "$ICON_DIR/WhiteSur-icon-theme"
cd "$ICON_DIR/WhiteSur-icon-theme"
./install.sh --dest "$ICON_DIR" || echo "Icon theme install skipped."

echo -e "${GREEN}Installing macOS Cursor...${NC}"
clone_or_update_repo "https://github.com/ful1e5/apple_cursor.git" "$ICON_DIR/apple_cursor"
cd "$ICON_DIR/apple_cursor"
if [ ! -d "$ICON_DIR/macOS Big Sur" ]; then
    tar -xf macOS\ Big\ Sur.tar.gz -C "$ICON_DIR" || echo "Cursor extraction skipped."
else
    echo -e "${YELLOW}Cursor already installed.${NC}"
fi

echo -e "${GREEN}Installing San Francisco Fonts...${NC}"
clone_or_update_repo "https://github.com/sahibjotsaggu/San-Francisco-Pro-Fonts.git" "$FONT_DIR/SF-Pro"
fc-cache -fv

# ---- 5. SOUNDS ----
echo -e "${GREEN}Installing macOS Sounds...${NC}"
SOUND_THEME_DIR="$SOUND_DIR/macOS"
if [ ! -d "$SOUND_THEME_DIR" ]; then
    mkdir -p "$SOUND_THEME_DIR"
    cd "$SOUND_THEME_DIR"
    wget -qO macos-sounds.zip "https://github.com/EliverLara/macOS-sound-theme/archive/refs/heads/master.zip"
    unzip -q macos-sounds.zip
    mv macOS-sound-theme-master/* . && rm -rf macOS-sound-theme-master macos-sounds.zip
    echo "Sound Theme Name=macOS" > index.theme
else
    echo -e "${YELLOW}macOS sound theme already installed.${NC}"
fi

# ---- 6. BOOT SPLASH (PLYMOUTH) ----
echo -e "${GREEN}Installing macOS Boot Splash (Plymouth theme)...${NC}"
PLYMOUTH_DIR="/usr/share/plymouth/themes"
TMP_PLYMOUTH="/tmp/plymouth-themes"
sudo rm -rf "$TMP_PLYMOUTH"
sudo git clone --depth=1 https://github.com/adi1090x/plymouth-themes.git "$TMP_PLYMOUTH"

# Detect the correct macOS-like folder (theme name may vary)
THEME_PATH=$(find "$TMP_PLYMOUTH" -type d -iname "macos*" | head -n 1)

if [ -z "$THEME_PATH" ]; then
    echo -e "${RED}macOS Plymouth theme not found in repo. Skipping.${NC}"
else
    sudo rm -rf "$PLYMOUTH_DIR/macos-plymouth"
    sudo cp -r "$THEME_PATH" "$PLYMOUTH_DIR/macos-plymouth"
    sudo plymouth-set-default-theme -R macos-plymouth || echo -e "${YELLOW}Warning: Plymouth apply failed. You can set it manually.${NC}"
fi

sudo rm -rf "$TMP_PLYMOUTH"

# ---- 7. APPLY SETTINGS ----
echo -e "${GREEN}Applying macOS appearance...${NC}"

APPLY_CMD="gsettings"
if ! pgrep -x "gnome-shell" >/dev/null; then
    APPLY_CMD="dbus-launch gsettings"
fi

$APPLY_CMD set org.gnome.desktop.interface gtk-theme "WhiteSur-light"
$APPLY_CMD set org.gnome.desktop.interface icon-theme "WhiteSur"
$APPLY_CMD set org.gnome.desktop.interface cursor-theme "macOS Big Sur"
$APPLY_CMD set org.gnome.desktop.interface font-name "SF Pro Display 11"
$APPLY_CMD set org.gnome.desktop.sound theme-name "macOS"
$APPLY_CMD set org.gnome.desktop.wm.preferences theme "WhiteSur-light"

# ---- 8. PLANK DOCK ----
mkdir -p ~/.config/autostart
cat <<EOF > ~/.config/autostart/plank.desktop
[Desktop Entry]
Type=Application
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Plank Dock
Comment=macOS-like Dock
EOF

# ---- 9. AUTO DAY/NIGHT SWITCHER ----
SWITCHER="$BIN_DIR/mac-theme-switcher.sh"
cat <<'EOS' > "$SWITCHER"
#!/bin/bash
HOUR=$(date +%H)
if [ $HOUR -ge 6 ] && [ $HOUR -lt 18 ]; then
    gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-light"
    gsettings set org.gnome.desktop.wm.preferences theme "WhiteSur-light"
else
    gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-dark"
    gsettings set org.gnome.desktop.wm.preferences theme "WhiteSur-dark"
fi
EOS
chmod +x "$SWITCHER"
(crontab -l 2>/dev/null | grep -v "$SWITCHER" ; echo "*/30 * * * * $SWITCHER") | crontab -

# ---- 10. DONE ----
echo -e "${GREEN}🎉 macOS Look Successfully Applied!${NC}"
echo -e "🔁 Please log out and log back in for all visual changes to take effect."
echo -e "💡 If GNOME still shows default theme, open GNOME Tweaks → Appearance → select 'WhiteSur'."

