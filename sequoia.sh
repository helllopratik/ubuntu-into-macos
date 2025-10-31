#!/bin/bash

# macOS Sequoia Theme Automated Installation Script
# Updated for Ubuntu 25.10 and other Debian/Ubuntu-based distributions
# Fixed for Unity, GNOME, and other compatible desktop environments
# Based on: https://www.youtube.com/watch?v=Med_nBpPyMQ

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  macOS Sequoia Theme Installer${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to print colored output
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

# Detect OS and distribution
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$NAME
        OS_VERSION=$VERSION_ID
        OS_ID=$ID
    else
        print_error "Cannot detect OS"
        exit 1
    fi
}

# Check for GNOME or compatible desktop environment
check_desktop_environment() {
    DESKTOP="${XDG_CURRENT_DESKTOP:-}"

    print_info "Checking desktop environment..."

    # If XDG_CURRENT_DESKTOP is not set, try other methods
    if [ -z "$DESKTOP" ]; then
        print_warning "XDG_CURRENT_DESKTOP not set, attempting alternative detection..."

        # Check if GNOME Shell is available
        if command -v gnome-shell &> /dev/null; then
            GNOME_VERSION=$(gnome-shell --version 2>/dev/null | grep -oP '\d+' | head -1)
            if [ -n "$GNOME_VERSION" ]; then
                print_status "Detected GNOME Shell version $GNOME_VERSION"
                DETECTED_GNOME=1
                return 0
            fi
        fi

        # Check if running on Ubuntu with Wayland or X11
        if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DISPLAY" ]; then
            print_warning "Display server detected, attempting to use GNOME compatibility mode"
            if command -v gsettings &> /dev/null; then
                print_status "gsettings found - GNOME settings available"
                DETECTED_GNOME=1
                return 0
            fi
        fi

        print_error "Could not detect GNOME desktop environment"
        print_info "This script requires GNOME desktop environment or compatible alternatives"
        print_info "Please ensure you are running GNOME and try again"
        exit 1
    fi

    # Check if it's GNOME or compatible
    if [[ "$DESKTOP" == *"GNOME"* ]]; then
        print_status "Detected GNOME-based desktop: $DESKTOP"
        DETECTED_GNOME=1
        return 0
    fi

    # Check if it's Ubuntu/Unity (which uses GNOME under the hood)
    if [[ "$DESKTOP" == *"Unity"* ]] || [[ "$DESKTOP" == *"ubuntu"* ]]; then
        print_warning "Detected Unity/Ubuntu desktop: $DESKTOP"
        print_info "Unity uses GNOME components - proceeding with GNOME theme installation"
        print_info "This will work with your system"
        DETECTED_GNOME=1
        return 0
    fi

    # If we reach here, desktop environment is not supported
    print_error "Desktop environment '$DESKTOP' detected, but GNOME or compatible is required"
    print_info "Supported desktop environments:"
    echo "  • GNOME"
    echo "  • Ubuntu Desktop (GNOME-based)"
    echo "  • Ubuntu with Unity"
    echo "  • Other GNOME-based desktops"
    print_error "Your desktop is not compatible with this script"
    exit 1
}

# Display system information
display_system_info() {
    echo ""
    print_info "System Information:"
    echo "  OS: $OS_NAME"
    echo "  Version: $OS_VERSION"
    echo "  Distribution: $OS_ID"
    echo "  Desktop: ${DESKTOP:-Detected via GNOME Shell}"
    echo ""
}

# Backup options
handle_backup_options() {
    echo ""
    echo -e "${YELLOW}========== BACKUP OPTIONS ==========${NC}"
    echo ""
    print_info "Before installing the theme, it's recommended to create a system backup."
    echo "If something goes wrong, you can restore your system from this backup."
    echo ""
    echo "Options:"
    echo "  1) Create backup using Timeshift (RECOMMENDED)"
    echo "  2) Skip backup and install directly"
    echo "  3) Exit installer"
    echo ""
    read -p "Choose an option (1-3): " backup_choice

    case $backup_choice in
        1)
            print_info "Installing Timeshift..."
            if sudo apt install -y timeshift 2>/dev/null; then
                print_status "Timeshift installed"
            else
                print_warning "Timeshift installation may have had issues, but continuing..."
            fi

            echo ""
            print_warning "Timeshift Backup Required"
            echo "Timeshift has been installed. Please follow these steps:"
            echo "  1. Open Timeshift application"
            echo "  2. Create a snapshot of your current system"
            echo "  3. Return to this terminal and press Enter to continue"
            echo ""
            read -p "Press Enter after creating backup..."
            print_status "Backup confirmed"
            ;;
        2)
            print_warning "Backup skipped - Installation will proceed without backup"
            print_warning "If anything goes wrong, you may need to reinstall your system"
            echo ""
            read -p "Are you absolutely sure? Type 'yes' to continue: " confirm
            if [ "$confirm" != "yes" ]; then
                print_info "Installation cancelled"
                exit 0
            fi
            ;;
        3)
            print_info "Installation cancelled"
            exit 0
            ;;
        *)
            print_error "Invalid option. Please choose 1, 2, or 3"
            handle_backup_options
            ;;
    esac
}

# Main installation flow
detect_os
check_desktop_environment
display_system_info
handle_backup_options

# Create temporary directory for downloads
TEMP_DIR=$(mktemp -d)
print_info "Working directory: $TEMP_DIR"
cd "$TEMP_DIR"

# Step 1: Update system
print_info "Updating system packages..."
sudo apt update
sudo apt upgrade -y
print_status "System updated"

# Step 2: Install essential tools
print_info "Installing essential tools..."
sudo apt install -y git curl wget sassc gnome-tweaks gnome-shell-extension-manager \
    libglib2.0-dev-bin libxml2-utils imagemagick dialog optipng inkscape \
    dbus-x11 jq unzip python3-gi gir1.2-gnome-shell-extensions 2>/dev/null || \
    sudo apt install -y git curl wget sassc gnome-tweaks gnome-shell-extension-manager \
    libglib2.0-dev-bin libxml2-utils imagemagick optipng unzip jq dbus-x11
print_status "Essential tools installed"

# Step 3: Setup Flatpak
print_info "Setting up Flatpak..."
if ! command -v flatpak &> /dev/null; then
    sudo apt install -y flatpak 2>/dev/null || true
    print_status "Flatpak installed"
else
    print_status "Flatpak already installed"
fi
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
print_status "Flatpak configured"

# Step 4: Download and install Cupertino Icon Pack
print_info "Downloading Cupertino Sonoma Icon Pack..."
if git clone https://github.com/USBA/Cupertino-Ventura-iCons.git 2>/dev/null; then
    mkdir -p ~/.icons
    if [ -d "Cupertino-Ventura-iCons" ]; then
        cp -r Cupertino-Ventura-iCons/Cupertino-Sonoma* ~/.icons/ 2>/dev/null || \
            cp -r Cupertino-Ventura-iCons/* ~/.icons/ 2>/dev/null || true
        print_status "Icon pack installed"
    fi
else
    print_warning "Could not download icon pack, continuing without it"
fi

# Step 5: Download and install WhiteSur Wallpapers
print_info "Downloading WhiteSur wallpapers..."
if git clone https://github.com/vinceliuice/WhiteSur-wallpapers.git 2>/dev/null; then
    cd WhiteSur-wallpapers
    if [ -f "install-wallpapers.sh" ]; then
        sudo bash ./install-wallpapers.sh 2>/dev/null || print_warning "Wallpaper installation had some issues"
    fi
    cd ..
    print_status "Wallpapers processed"
else
    print_warning "Could not download wallpapers, continuing..."
fi

# Step 6: Download WhiteSur GTK Theme
print_info "Downloading WhiteSur GTK Theme..."
if git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1 2>/dev/null; then
    cd WhiteSur-gtk-theme
    print_status "WhiteSur theme downloaded"
else
    print_error "Failed to download WhiteSur theme - this is critical"
    print_info "Cleaning up and exiting..."
    cd ~
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Step 7: Install WhiteSur GTK Theme
print_info "Installing WhiteSur GTK Theme (this may take a few minutes)..."
if [ -f "./install.sh" ]; then
    chmod +x ./install.sh
    ./install.sh \
        --name WhiteSur \
        --theme all \
        --monterey \
        --nautilus stable \
        --libadwaita \
        --shell --icon apple \
        --panel-height bigger \
        --round 2>/dev/null || print_warning "Theme installation completed with some warnings"
    print_status "WhiteSur GTK theme installed"
else
    print_error "install.sh not found in theme directory"
fi

# Step 8: Install GDM theme
print_info "Installing GDM theme..."
if [ -f "./tweaks.sh" ]; then
    chmod +x ./tweaks.sh
    sudo ./tweaks.sh --gdm --no-darken --background 2>/dev/null || print_warning "GDM theme installation completed with warnings"
    print_status "GDM theme installed"
else
    print_warning "tweaks.sh not found, skipping GDM theme"
fi

# Step 9: Configure Firefox theme
print_info "Configuring Firefox theme..."
pkill firefox 2>/dev/null || true
sleep 2
if [ -f "./tweaks.sh" ]; then
    ./tweaks.sh --firefox flat 2>/dev/null || print_warning "Firefox theme configuration completed with warnings"
    print_status "Firefox theme configured"
fi

# Step 10: Configure Flatpak theme support
print_info "Configuring Flatpak applications..."
if [ -f "./tweaks.sh" ]; then
    ./tweaks.sh --flatpak 2>/dev/null || print_warning "Flatpak theme config completed with warnings"
fi
sudo flatpak override --filesystem=xdg-config/gtk-3.0 2>/dev/null || true
sudo flatpak override --filesystem=xdg-config/gtk-4.0 2>/dev/null || true
print_status "Flatpak theme support configured"

cd ..

# Step 11: Configure GNOME Settings via gsettings
print_info "Configuring GNOME settings..."

# Enable hot corners
gsettings set org.gnome.desktop.interface enable-hot-corners true 2>/dev/null || true
gsettings set org.gnome.shell.overrides edge-tiling true 2>/dev/null || true

# Configure dock
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true 2>/dev/null || true

# Window button placement
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:' 2>/dev/null || true

print_status "GNOME settings configured"

# Step 12: Install GNOME Extensions
print_info "Installing GNOME Shell extensions..."

install_gnome_extension() {
    EXTENSION_ID=$1
    EXTENSION_NAME=$2

    print_info "Installing $EXTENSION_NAME extension (ID: $EXTENSION_ID)..."

    # Get GNOME Shell version
    GNOME_VERSION=$(gnome-shell --version 2>/dev/null | grep -oP '\d+' | head -1)
    if [ -z "$GNOME_VERSION" ]; then
        print_warning "Could not detect GNOME version, trying default..."
        GNOME_VERSION=47
    fi

    # Try to download extension info
    EXTENSION_INFO=$(curl -s "https://extensions.gnome.org/extension-info/?pk=$EXTENSION_ID&shell_version=$GNOME_VERSION" 2>/dev/null) || true

    if [ -z "$EXTENSION_INFO" ]; then
        print_warning "Could not reach extensions.gnome.org for $EXTENSION_NAME, skipping..."
        return
    fi

    # Extract download URL
    DOWNLOAD_URL=$(echo "$EXTENSION_INFO" | jq -r '.download_url' 2>/dev/null) || true

    if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" == "null" ]; then
        print_warning "Extension $EXTENSION_NAME not available for GNOME $GNOME_VERSION"
        return
    fi

    # Download extension
    if wget -q "https://extensions.gnome.org$DOWNLOAD_URL" -O "${EXTENSION_ID}.zip" 2>/dev/null; then
        # Extract UUID from zip
        UUID=$(unzip -p "${EXTENSION_ID}.zip" metadata.json 2>/dev/null | jq -r '.uuid' 2>/dev/null) || true

        if [ -z "$UUID" ] || [ "$UUID" == "null" ]; then
            print_warning "Could not extract UUID for $EXTENSION_NAME"
            rm -f "${EXTENSION_ID}.zip"
            return
        fi

        # Install extension
        mkdir -p ~/.local/share/gnome-shell/extensions/"$UUID"
        unzip -q -o "${EXTENSION_ID}.zip" -d ~/.local/share/gnome-shell/extensions/"$UUID" 2>/dev/null || true

        # Enable extension
        gnome-extensions enable "$UUID" 2>/dev/null || true

        print_status "$EXTENSION_NAME installed"
        rm -f "${EXTENSION_ID}.zip"
    else
        print_warning "Failed to download $EXTENSION_NAME"
    fi
}

# Install extensions with fallback
print_info "Attempting to install GNOME extensions..."
install_gnome_extension 19 "User Themes"
install_gnome_extension 3193 "Blur My Shell"
install_gnome_extension 4679 "Burn My Windows"
install_gnome_extension 3740 "Compiz-alike Magic Lamp"
install_gnome_extension 3210 "Compiz Windows Effect"
install_gnome_extension 97 "CoverFlow Alt-Tab"

print_status "Extension installation completed"

# Step 13: Configure GNOME Extensions
print_info "Configuring GNOME extensions..."

gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null || true

gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark' 2>/dev/null || true

dconf write /org/gnome/shell/extensions/blur-my-shell/panel/blur false 2>/dev/null || true
dconf write /org/gnome/shell/extensions/blur-my-shell/dash-to-dock/blur false 2>/dev/null || true

dconf write /org/gnome/shell/extensions/burn-my-windows/effect-enable-fade false 2>/dev/null || true
dconf write /org/gnome/shell/extensions/burn-my-windows/effect-enable-focus true 2>/dev/null || true

dconf write /org/gnome/shell/extensions/coverflowalttab/offset 0 2>/dev/null || true

print_status "Extensions configured"

# Step 14: Set icon theme
print_info "Setting icon theme..."
gsettings set org.gnome.desktop.interface icon-theme 'Cupertino-Sonoma' 2>/dev/null || true
print_status "Icon theme set"

# Step 15: Set GTK theme
print_info "Setting GTK theme..."
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark' 2>/dev/null || true
gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Dark' 2>/dev/null || true
print_status "GTK theme set"

# Step 16: Cleanup
print_info "Cleaning up temporary files..."
cd ~
rm -rf "$TEMP_DIR"
print_status "Cleanup complete"

# Final message
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
print_warning "Please REBOOT your system to apply all changes"
echo ""
print_info "After reboot, you can customize further using:"
echo "  - GNOME Tweaks"
echo "  - Extensions Manager"
echo ""
print_info "To remove this theme later, run:"
echo "  ./macos_sequoia_uninstaller.sh"
echo ""

read -p "Press Enter to reboot now or Ctrl+C to reboot later..."
sudo reboot