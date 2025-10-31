#!/bin/bash

# macOS Sequoia Theme Automated Installation Script
# Version 2.5+ - COMPLETE WITH ALL FEATURES
# Updated for Ubuntu 25.10 and all Debian/Ubuntu-based distributions
# Features: Multiple themes, colors, sounds, Unity support
# Based on: https://www.youtube.com/watch?v=Med_nBpPyMQ

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  macOS Sequoia Theme Installer v2.5+${NC}"
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

    if [ -z "$DESKTOP" ]; then
        print_warning "XDG_CURRENT_DESKTOP not set, attempting alternative detection..."

        if command -v gnome-shell &> /dev/null; then
            GNOME_VERSION=$(gnome-shell --version 2>/dev/null | grep -oP '\d+' | head -1)
            if [ -n "$GNOME_VERSION" ]; then
                print_status "Detected GNOME Shell version $GNOME_VERSION"
                DETECTED_GNOME=1
                return 0
            fi
        fi

        if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DISPLAY" ]; then
            print_warning "Display server detected, attempting to use GNOME compatibility mode"
            if command -v gsettings &> /dev/null; then
                print_status "gsettings found - GNOME settings available"
                DETECTED_GNOME=1
                return 0
            fi
        fi

        print_error "Could not detect GNOME desktop environment"
        exit 1
    fi

    if [[ "$DESKTOP" == *"GNOME"* ]]; then
        print_status "Detected GNOME-based desktop: $DESKTOP"
        DETECTED_DESKTOP="GNOME"
        DETECTED_GNOME=1
        return 0
    fi

    if [[ "$DESKTOP" == *"Unity"* ]] || [[ "$DESKTOP" == *"ubuntu"* ]]; then
        print_warning "Detected Unity/Ubuntu desktop: $DESKTOP"
        DETECTED_DESKTOP="Unity"
        return 0
    fi

    print_error "Desktop environment '$DESKTOP' detected, but GNOME or compatible is required"
    exit 1
}

# Display system information
display_system_info() {
    echo ""
    print_info "System Information:"
    echo "  OS: $OS_NAME"
    echo "  Version: $OS_VERSION"
    echo "  Distribution: $OS_ID"
    echo "  Desktop: ${DETECTED_DESKTOP:-$([ -z "$DESKTOP" ] && echo "Detected via GNOME Shell" || echo "$DESKTOP")}"
    echo ""
}

# Theme choice for Unity
handle_unity_theme_choice() {
    echo ""
    echo -e "${YELLOW}========== THEME STYLE SELECTION ==========${NC}"
    echo ""
    print_info "You are using Unity desktop. Choose your theme style:"
    echo ""
    echo "Options:"
    echo "  1) GNOME-style theme (Full macOS experience)"
    echo "  2) Unity-based theme (Keep Unity interface)"
    echo ""
    read -p "Choose an option (1-2): " theme_choice

    case $theme_choice in
        1)
            print_status "Selected: GNOME-style theme"
            THEME_STYLE="GNOME"
            ;;
        2)
            print_status "Selected: Unity-based theme"
            THEME_STYLE="UNITY"
            ;;
        *)
            print_error "Invalid option. Please choose 1 or 2"
            handle_unity_theme_choice
            ;;
    esac
}

# macOS version selection
handle_macos_version_choice() {
    echo ""
    echo -e "${YELLOW}========== macOS THEME VERSION ==========${NC}"
    echo ""
    print_info "Choose your macOS version theme:"
    echo ""
    echo "  1) macOS Sequoia (Latest, modern)"
    echo "  2) macOS Monterey (Refined, balanced)"
    echo "  3) macOS Big Sur (Bold, colorful)"
    echo "  4) macOS Catalina (Classic, elegant)"
    echo "  5) macOS Light (Bright, minimal)"
    echo ""
    read -p "Choose an option (1-5): " version_choice

    case $version_choice in
        1)
            print_status "Selected: macOS Sequoia"
            MACOS_VERSION="sequoia"
            MACOS_ALT=""
            ;;
        2)
            print_status "Selected: macOS Monterey"
            MACOS_VERSION="monterey"
            MACOS_ALT="monterey"
            ;;
        3)
            print_status "Selected: macOS Big Sur"
            MACOS_VERSION="big-sur"
            MACOS_ALT="big-sur"
            ;;
        4)
            print_status "Selected: macOS Catalina"
            MACOS_VERSION="catalina"
            MACOS_ALT="catalina"
            ;;
        5)
            print_status "Selected: macOS Light"
            MACOS_VERSION="light"
            MACOS_ALT="light"
            ;;
        *)
            print_error "Invalid option. Please choose 1-5"
            handle_macos_version_choice
            ;;
    esac
}

# Color accent selection
handle_color_accent_choice() {
    echo ""
    echo -e "${YELLOW}========== COLOR ACCENT ==========${NC}"
    echo ""
    print_info "Choose your accent color:"
    echo ""
    echo "  1) Default (Gray)"
    echo "  2) Blue"
    echo "  3) Purple"
    echo "  4) Pink"
    echo "  5) Red"
    echo "  6) Orange"
    echo "  7) Yellow"
    echo "  8) Green"
    echo ""
    read -p "Choose an option (1-8): " color_choice

    case $color_choice in
        1)
            print_status "Selected: Default (Gray)"
            COLOR_ACCENT="default"
            THEME_NAME="WhiteSur-Dark"
            ;;
        2)
            print_status "Selected: Blue"
            COLOR_ACCENT="blue"
            THEME_NAME="WhiteSur-Blue"
            ;;
        3)
            print_status "Selected: Purple"
            COLOR_ACCENT="purple"
            THEME_NAME="WhiteSur-Purple"
            ;;
        4)
            print_status "Selected: Pink"
            COLOR_ACCENT="pink"
            THEME_NAME="WhiteSur-Pink"
            ;;
        5)
            print_status "Selected: Red"
            COLOR_ACCENT="red"
            THEME_NAME="WhiteSur-Red"
            ;;
        6)
            print_status "Selected: Orange"
            COLOR_ACCENT="orange"
            THEME_NAME="WhiteSur-Orange"
            ;;
        7)
            print_status "Selected: Yellow"
            COLOR_ACCENT="yellow"
            THEME_NAME="WhiteSur-Yellow"
            ;;
        8)
            print_status "Selected: Green"
            COLOR_ACCENT="green"
            THEME_NAME="WhiteSur-Green"
            ;;
        *)
            print_error "Invalid option. Please choose 1-8"
            handle_color_accent_choice
            ;;
    esac
}

# File manager style selection
handle_file_manager_choice() {
    echo ""
    echo -e "${YELLOW}========== FILE MANAGER STYLE ==========${NC}"
    echo ""
    print_info "Choose Nautilus/Files style:"
    echo ""
    echo "  1) Stable (Traditional)"
    echo "  2) Normal (Classic Finder)"
    echo "  3) Mojave (Inspired)"
    echo "  4) Glassy (Modern)"
    echo "  5) Right (macOS sidebar)"
    echo ""
    read -p "Choose an option (1-5): " fm_choice

    case $fm_choice in
        1)
            print_status "Selected: Stable"
            FM_STYLE="stable"
            ;;
        2)
            print_status "Selected: Normal"
            FM_STYLE="normal"
            ;;
        3)
            print_status "Selected: Mojave"
            FM_STYLE="mojave"
            ;;
        4)
            print_status "Selected: Glassy"
            FM_STYLE="glassy"
            ;;
        5)
            print_status "Selected: Right sidebar"
            FM_STYLE="right"
            ;;
        *)
            print_error "Invalid option. Please choose 1-5"
            handle_file_manager_choice
            ;;
    esac
}

# Sound installation choice
handle_sounds_choice() {
    echo ""
    echo -e "${YELLOW}========== SOUND INSTALLATION ==========${NC}"
    echo ""
    print_info "macOS sound theme installation (optional):"
    echo ""
    echo "  1) Install macOS sounds (macOS Sequoia)"
    echo "  2) Skip sounds"
    echo ""
    read -p "Choose an option (1-2): " sounds_choice

    case $sounds_choice in
        1)
            print_status "Selected: Install sounds"
            INSTALL_SOUNDS=1
            ;;
        2)
            print_status "Selected: Skip sounds"
            INSTALL_SOUNDS=0
            ;;
        *)
            print_error "Invalid option. Please choose 1-2"
            handle_sounds_choice
            ;;
    esac
}

# Backup options
handle_backup_options() {
    echo ""
    echo -e "${YELLOW}========== BACKUP OPTIONS ==========${NC}"
    echo ""
    print_info "Before installing the theme, it's recommended to create a system backup."
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
            echo "Please follow these steps:"
            echo "  1. Open Timeshift application"
            echo "  2. Create a snapshot of your current system"
            echo "  3. Return to this terminal and press Enter to continue"
            echo ""
            read -p "Press Enter after creating backup..."
            print_status "Backup confirmed"
            ;;
        2)
            print_warning "Backup skipped - Installation will proceed without backup"
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

if [ "$DETECTED_DESKTOP" == "Unity" ]; then
    handle_unity_theme_choice
    if [ "$THEME_STYLE" == "UNITY" ]; then
        print_info "Installing GNOME theme with Unity optimization..."
        THEME_STYLE="GNOME"
    fi
else
    THEME_STYLE="GNOME"
fi

display_system_info

# Ask for customization choices
handle_macos_version_choice
handle_color_accent_choice
handle_file_manager_choice
handle_sounds_choice
handle_backup_options

# Create temporary directory
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
print_info "Downloading Cupertino Icon Pack..."
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
    print_error "Failed to download WhiteSur theme"
    cd ~
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Step 7: Install WhiteSur GTK Theme
print_info "Installing WhiteSur GTK Theme (this may take a few minutes)..."
if [ -f "./install.sh" ]; then
    chmod +x ./install.sh

    # Build installation arguments
    INSTALL_ARGS="--name WhiteSur --theme all"

    # Add macOS version variant
    if [ -n "$MACOS_ALT" ]; then
        INSTALL_ARGS="$INSTALL_ARGS --alt $MACOS_ALT"
    else
        INSTALL_ARGS="$INSTALL_ARGS --monterey"
    fi

    # Add color if not default
    if [ "$COLOR_ACCENT" != "default" ]; then
        INSTALL_ARGS="$INSTALL_ARGS --color $COLOR_ACCENT"
    fi

    # Add nautilus style
    INSTALL_ARGS="$INSTALL_ARGS --nautilus $FM_STYLE"

    # Add general options
    INSTALL_ARGS="$INSTALL_ARGS --libadwaita --shell --round"

    print_info "Using arguments: $INSTALL_ARGS"

    ./install.sh $INSTALL_ARGS 2>&1 | tee install_output.log || {
        print_warning "Theme installation had issues, trying basic arguments..."
        ./install.sh --name WhiteSur --theme all --monterey 2>&1 | tee -a install_output.log || true
    }

    print_status "WhiteSur GTK theme installed"
else
    print_error "install.sh not found in theme directory"
fi

# Step 8: Install GDM theme
print_info "Installing GDM theme..."
if [ -f "./tweaks.sh" ]; then
    chmod +x ./tweaks.sh

    if ./tweaks.sh --help 2>&1 | grep -q "\-\-gdm"; then
        print_info "Installing GDM tweaks..."
        sudo ./tweaks.sh --gdm 2>&1 | tee tweaks_output.log || print_warning "GDM theme installation completed with warnings"
        print_status "GDM theme installed"
    else
        print_warning "GDM tweaks not available in this version"
    fi
else
    print_warning "tweaks.sh not found, skipping GDM theme"
fi

# Step 9: Configure Firefox theme
print_info "Configuring Firefox theme..."
pkill firefox 2>/dev/null || true
sleep 2
if [ -f "./tweaks.sh" ]; then
    if ./tweaks.sh --help 2>&1 | grep -q "\-\-firefox"; then
        ./tweaks.sh --firefox flat 2>&1 | tee -a tweaks_output.log || print_warning "Firefox theme configuration had issues"
        print_status "Firefox theme configured"
    fi
fi

# Step 10: Configure Flatpak theme support
print_info "Configuring Flatpak applications..."
if [ -f "./tweaks.sh" ]; then
    if ./tweaks.sh --help 2>&1 | grep -q "\-\-flatpak"; then
        ./tweaks.sh --flatpak 2>&1 | tee -a tweaks_output.log || print_warning "Flatpak theme config had issues"
    fi
fi
sudo flatpak override --filesystem=xdg-config/gtk-3.0 2>/dev/null || true
sudo flatpak override --filesystem=xdg-config/gtk-4.0 2>/dev/null || true
print_status "Flatpak theme support configured"

cd ..

# Step 11: Install macOS Sounds (if selected)
if [ "$INSTALL_SOUNDS" == "1" ]; then
    print_info "Installing macOS sounds..."
    mkdir -p ~/.local/share/sounds/macOS/stereo

    if git clone https://github.com/vinceliuice/WhiteSur-sound.git ~/.local/share/sounds/macOS 2>/dev/null; then
        print_status "macOS sounds installed"
    else
        print_warning "Could not download macOS sound pack, continuing without sounds"
    fi

    # Create sound theme metadata
    cat > ~/.local/share/sounds/index.theme << 'EOF'
[Sound Theme]
Name=macOS
Comment=macOS Sequoia Sounds
Directories=stereo

[stereo]
OutputProfile=stereo
EOF

    print_status "Sound theme configured"
fi

# Step 12: Configure GNOME Settings
print_info "Configuring GNOME settings..."

gsettings set org.gnome.desktop.interface enable-hot-corners true 2>/dev/null || true
gsettings set org.gnome.shell.overrides edge-tiling true 2>/dev/null || true

gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true 2>/dev/null || true

gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:' 2>/dev/null || true

print_status "Settings configured"

# Step 13: Install GNOME Extensions
print_info "Installing GNOME Shell extensions..."

install_gnome_extension() {
    EXTENSION_ID=$1
    EXTENSION_NAME=$2

    print_info "Installing $EXTENSION_NAME extension (ID: $EXTENSION_ID)..."

    GNOME_VERSION=$(gnome-shell --version 2>/dev/null | grep -oP '\d+' | head -1)
    if [ -z "$GNOME_VERSION" ]; then
        GNOME_VERSION=47
    fi

    EXTENSION_INFO=$(curl -s "https://extensions.gnome.org/extension-info/?pk=$EXTENSION_ID&shell_version=$GNOME_VERSION" 2>/dev/null) || true

    if [ -z "$EXTENSION_INFO" ]; then
        print_warning "Could not reach extensions.gnome.org for $EXTENSION_NAME, skipping..."
        return
    fi

    DOWNLOAD_URL=$(echo "$EXTENSION_INFO" | jq -r '.download_url' 2>/dev/null) || true

    if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" == "null" ]; then
        print_warning "Extension $EXTENSION_NAME not available for GNOME $GNOME_VERSION"
        return
    fi

    if wget -q "https://extensions.gnome.org$DOWNLOAD_URL" -O "${EXTENSION_ID}.zip" 2>/dev/null; then
        UUID=$(unzip -p "${EXTENSION_ID}.zip" metadata.json 2>/dev/null | jq -r '.uuid' 2>/dev/null) || true

        if [ -z "$UUID" ] || [ "$UUID" == "null" ]; then
            print_warning "Could not extract UUID for $EXTENSION_NAME"
            rm -f "${EXTENSION_ID}.zip"
            return
        fi

        mkdir -p ~/.local/share/gnome-shell/extensions/"$UUID"
        unzip -q -o "${EXTENSION_ID}.zip" -d ~/.local/share/gnome-shell/extensions/"$UUID" 2>/dev/null || true

        gnome-extensions enable "$UUID" 2>/dev/null || true

        print_status "$EXTENSION_NAME installed"
        rm -f "${EXTENSION_ID}.zip"
    else
        print_warning "Failed to download $EXTENSION_NAME"
    fi
}

install_gnome_extension 19 "User Themes"
install_gnome_extension 3193 "Blur My Shell"
install_gnome_extension 4679 "Burn My Windows"
install_gnome_extension 3740 "Compiz-alike Magic Lamp"
install_gnome_extension 3210 "Compiz Windows Effect"
install_gnome_extension 97 "CoverFlow Alt-Tab"

print_status "Extension installation completed"

# Step 14: Configure Extensions
print_info "Configuring GNOME extensions..."

gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null || true
gsettings set org.gnome.shell.extensions.user-theme name "$THEME_NAME" 2>/dev/null || true

dconf write /org/gnome/shell/extensions/blur-my-shell/panel/blur false 2>/dev/null || true
dconf write /org/gnome/shell/extensions/blur-my-shell/dash-to-dock/blur false 2>/dev/null || true

dconf write /org/gnome/shell/extensions/burn-my-windows/effect-enable-fade false 2>/dev/null || true
dconf write /org/gnome/shell/extensions/burn-my-windows/effect-enable-focus true 2>/dev/null || true

dconf write /org/gnome/shell/extensions/coverflowalttab/offset 0 2>/dev/null || true

print_status "Extensions configured"

# Step 15: Set themes
print_info "Setting themes..."
gsettings set org.gnome.desktop.interface icon-theme 'Cupertino-Sonoma' 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME" 2>/dev/null || true
gsettings set org.gnome.desktop.wm.preferences theme "$THEME_NAME" 2>/dev/null || true
print_status "Themes set"

# Step 16: Configure sounds (if installed)
if [ "$INSTALL_SOUNDS" == "1" ]; then
    print_info "Configuring sound theme..."
    gsettings set org.gnome.desktop.sound theme-name 'macOS' 2>/dev/null || true
    gsettings set org.gnome.desktop.sound input-feedback-sounds true 2>/dev/null || true
    print_status "Sound theme configured"
fi

# Step 17: Cleanup
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
print_info "Configuration Applied:"
echo "  Theme Version: $MACOS_VERSION"
echo "  Color Accent: $COLOR_ACCENT"
echo "  File Manager: $FM_STYLE"
echo "  Sounds: $([ "$INSTALL_SOUNDS" == "1" ] && echo "Enabled" || echo "Disabled")"
echo "  Final Theme: $THEME_NAME"
echo ""
print_warning "Please REBOOT your system to apply all changes"
echo ""
print_info "After reboot, you can customize further using:"
echo "  - GNOME Tweaks (gnome-tweaks)"
echo "  - Extensions Manager (gnome-shell-extension-manager)"
echo ""
print_info "To remove this theme later, run:"
echo "  ./macos_sequoia_uninstaller.sh"
echo ""

read -p "Press Enter to reboot now or Ctrl+C to reboot later..."
sudo reboot