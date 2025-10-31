#!/bin/bash

# macOS Sequoia Theme Uninstaller v2.5+
# Complete removal and cleanup script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  macOS Sequoia Theme Uninstaller${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME=$NAME
    OS_VERSION=$VERSION_ID
fi

print_info "System: $OS_NAME $OS_VERSION"
print_warning "This will remove all macOS theme components"
echo ""

read -p "Are you sure you want to continue? Type 'yes' to proceed: " -r
if [[ ! $REPLY == "yes" ]]; then
    print_info "Uninstallation cancelled"
    exit 0
fi

TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Step 1: Remove WhiteSur GTK Theme
print_info "Removing WhiteSur GTK theme..."
if git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1 2>/dev/null; then
    cd WhiteSur-gtk-theme

    if [ -f "./install.sh" ]; then
        chmod +x ./install.sh
        ./install.sh -r 2>/dev/null || print_warning "Some theme variants may not have been removed"
    fi

    if [ -f "./tweaks.sh" ]; then
        chmod +x ./tweaks.sh
        sudo ./tweaks.sh -g -r 2>/dev/null || print_warning "GDM theme removal had some issues"
        ./tweaks.sh -f -r 2>/dev/null || print_warning "Firefox theme removal had some issues"
        ./tweaks.sh -F -r 2>/dev/null || print_warning "Flatpak theme removal had some issues"
    fi

    cd ..
    print_status "WhiteSur theme removed"
else
    print_warning "Could not download WhiteSur theme for removal, proceeding with manual cleanup"
fi

# Step 2: Remove installed icons
print_info "Removing icon packs..."
rm -rf ~/.icons/Cupertino-Sonoma* 2>/dev/null || true
rm -rf ~/.icons/Cupertino-Ventura* 2>/dev/null || true
rm -rf ~/.icons/Cupertino-Big-Sur* 2>/dev/null || true
rm -rf ~/.icons/Cupertino-Catalina* 2>/dev/null || true
rm -rf ~/.icons/Cupertino-Light* 2>/dev/null || true
print_status "Icon packs removed"

# Step 3: Remove wallpapers
print_info "Removing wallpapers..."
sudo rm -rf /usr/share/backgrounds/WhiteSur* 2>/dev/null || true
print_status "Wallpapers removed"

# Step 4: Remove sound theme
print_info "Removing macOS sounds..."
rm -rf ~/.local/share/sounds/macOS 2>/dev/null || true
rm -f ~/.local/share/sounds/index.theme 2>/dev/null || true
print_status "Sounds removed"

# Step 5: Reset GNOME settings to defaults
print_info "Resetting GNOME settings..."

gsettings reset org.gnome.desktop.interface gtk-theme 2>/dev/null || true
gsettings reset org.gnome.desktop.interface icon-theme 2>/dev/null || true
gsettings reset org.gnome.desktop.wm.preferences theme 2>/dev/null || true
gsettings reset org.gnome.shell.extensions.user-theme name 2>/dev/null || true

gsettings reset org.gnome.shell.extensions.dash-to-dock dock-position 2>/dev/null || true
gsettings reset org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 2>/dev/null || true
gsettings reset org.gnome.shell.extensions.dash-to-dock click-action 2>/dev/null || true

gsettings reset org.gnome.desktop.wm.preferences button-layout 2>/dev/null || true
gsettings reset org.gnome.desktop.sound theme-name 2>/dev/null || true
gsettings reset org.gnome.desktop.sound input-feedback-sounds 2>/dev/null || true

print_status "GNOME settings reset"

# Step 6: Disable extensions
print_info "Disabling theme-related extensions..."

gnome-extensions disable blur-my-shell@aunetx 2>/dev/null || true
gnome-extensions disable burn-my-windows@schneegans.github.com 2>/dev/null || true
gnome-extensions disable coverflow@dgshamal.gmail.com 2>/dev/null || true
gnome-extensions disable magic-lamp@fthx 2>/dev/null || true
gnome-extensions disable compiz-windows-effect@hermes83.github.com 2>/dev/null || true
gnome-extensions disable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null || true

print_status "Extensions disabled"

echo ""
read -p "Do you want to remove the extensions completely? (yes/no): " -r
if [[ $REPLY == "yes" ]]; then
    print_info "Removing extensions..."
    rm -rf ~/.local/share/gnome-shell/extensions/blur-my-shell@aunetx 2>/dev/null || true
    rm -rf ~/.local/share/gnome-shell/extensions/burn-my-windows@schneegans.github.com 2>/dev/null || true
    rm -rf ~/.local/share/gnome-shell/extensions/coverflow@dgshamal.gmail.com 2>/dev/null || true
    rm -rf ~/.local/share/gnome-shell/extensions/magic-lamp@fthx 2>/dev/null || true
    rm -rf ~/.local/share/gnome-shell/extensions/compiz-windows-effect@hermes83.github.com 2>/dev/null || true
    rm -rf ~/.local/share/gnome-shell/extensions/user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null || true
    print_status "Extensions removed"
fi

# Step 7: Remove theme directories
print_info "Removing theme files..."
rm -rf ~/.themes/WhiteSur* 2>/dev/null || true
rm -rf ~/.local/share/themes/WhiteSur* 2>/dev/null || true
print_status "Theme files removed"

# Step 8: Clean up temporary files
print_info "Cleaning up temporary files..."
cd ~
rm -rf "$TEMP_DIR"
print_status "Cleanup complete"

# Step 9: Clear GNOME Shell cache
print_info "Clearing GNOME Shell cache..."
rm -rf ~/.cache/gnome-shell/* 2>/dev/null || true
print_status "Cache cleared"

# Final message
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Uninstallation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
print_warning "Please REBOOT your system to apply all changes"
echo ""

read -p "Press Enter to reboot now or Ctrl+C to reboot later..."
sudo reboot
