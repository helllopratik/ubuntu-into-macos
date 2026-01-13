#!/bin/bash

# macOS Sequoia Theme Automated Installation Script
# Version 2.6 – GNOME + Cinnamon SAFE
# Supports: GNOME (full), Unity (partial), Cinnamon (GTK-only)

set -e
trap 'echo -e "\033[1;33m[!] Non-fatal error occurred, continuing...\033[0m"' ERR

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status(){ echo -e "${GREEN}[✓]${NC} $1"; }
print_info(){ echo -e "${BLUE}[i]${NC} $1"; }
print_warning(){ echo -e "${YELLOW}[!]${NC} $1"; }
print_error(){ echo -e "${RED}[✗]${NC} $1"; }

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  macOS Sequoia Theme Installer v2.6${NC}"
echo -e "${BLUE}========================================${NC}"

# -------------------- OS DETECTION --------------------
detect_os() {
    . /etc/os-release
    OS_NAME=$NAME
    OS_VERSION=$VERSION_ID
    OS_ID=$ID
}

# -------------------- DE DETECTION --------------------
check_desktop_environment() {
    DESKTOP_RAW="${XDG_CURRENT_DESKTOP:-}"
    DESKTOP=$(echo "$DESKTOP_RAW" | tr '[:upper:]' '[:lower:]')

    print_info "Checking desktop environment..."

    if [[ "$DESKTOP" == *"gnome"* ]]; then
        DE_MODE="gnome"
        DETECTED_DESKTOP="GNOME"
    elif [[ "$DESKTOP" == *"unity"* ]] || [[ "$DESKTOP" == *"ubuntu"* ]]; then
        DE_MODE="unity"
        DETECTED_DESKTOP="Unity"
    elif [[ "$DESKTOP" == *"cinnamon"* ]]; then
        DE_MODE="cinnamon"
        DETECTED_DESKTOP="Cinnamon"
    else
        print_error "Unsupported desktop: $DESKTOP_RAW"
        exit 1
    fi

    print_status "Detected desktop: $DETECTED_DESKTOP"
}

display_system_info() {
    echo ""
    print_info "System Information:"
    echo "  OS: $OS_NAME $OS_VERSION"
    echo "  Desktop: $DETECTED_DESKTOP"
    echo ""
}

# -------------------- MAIN FLOW --------------------
detect_os
check_desktop_environment
display_system_info

if [[ "$DE_MODE" == "cinnamon" ]]; then
    print_warning "Cinnamon LIMITED MODE enabled"
    echo "  ✔ GTK theme, icons, wallpapers, sounds"
    echo "  ✗ GNOME Shell, GDM, extensions"
fi

# -------------------- USER CHOICES --------------------
read -p "Install macOS sounds? (y/n): " INSTALL_SOUNDS
INSTALL_SOUNDS=$([[ "$INSTALL_SOUNDS" == "y" ]] && echo 1 || echo 0)
enable_event_sounds() {
    print_info "Checking system event sound settings..."

    # Cinnamon
    if gsettings list-schemas | grep -q "org.cinnamon.desktop.sound"; then
        CURRENT=$(gsettings get org.cinnamon.desktop.sound event-sounds 2>/dev/null || echo "false")

        if [[ "$CURRENT" != "true" ]]; then
            gsettings set org.cinnamon.desktop.sound event-sounds true || true
            print_status "Enabled event sounds (Cinnamon)"
        else
            print_status "Event sounds already enabled (Cinnamon)"
        fi
        return
    fi

    # GNOME
    if gsettings list-schemas | grep -q "org.gnome.desktop.sound"; then
        CURRENT=$(gsettings get org.gnome.desktop.sound event-sounds 2>/dev/null || echo "false")

        if [[ "$CURRENT" != "true" ]]; then
            gsettings set org.gnome.desktop.sound event-sounds true || true
            print_status "Enabled event sounds (GNOME)"
        else
            print_status "Event sounds already enabled (GNOME)"
        fi
        return
    fi

    print_warning "No supported sound schema found — skipping"
}

# -------------------- TEMP DIR --------------------
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# -------------------- UPDATE --------------------
print_info "Updating system..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y libcanberra-gtk-module libcanberra-gtk3-module sox || true
sudo apt install -y libcanberra-gtk-module libcanberra-gtk3-module || true

print_status "System updated"

# -------------------- PACKAGES --------------------
print_info "Installing required packages..."

if [[ "$DE_MODE" == "cinnamon" ]]; then
    sudo apt install -y git curl wget sassc \
        libglib2.0-dev-bin libxml2-utils imagemagick \
        optipng unzip jq dbus-x11
else
    sudo apt install -y git curl wget sassc \
        gnome-tweaks gnome-shell-extension-manager \
        libglib2.0-dev-bin libxml2-utils imagemagick \
        dialog optipng inkscape dbus-x11 \
        jq unzip python3-gi gir1.2-gnome-shell-extensions
fi

print_status "Packages installed"

# -------------------- ICONS --------------------
print_info "Installing icons..."
git clone https://github.com/USBA/Cupertino-Ventura-iCons.git
mkdir -p ~/.icons
cp -r Cupertino-Ventura-iCons/* ~/.icons/ || true
print_status "Icons installed"

# -------------------- CURSOR THEME --------------------
print_info "Installing macOS cursor theme..."

git clone https://github.com/vinceliuice/McMojave-cursors.git
cd McMojave-cursors
chmod +x install.sh
./install.sh
cd ..

print_status "Cursor theme installed"

# -------------------- WALLPAPERS --------------------
print_info "Installing wallpapers..."
git clone https://github.com/vinceliuice/WhiteSur-wallpapers.git
sudo bash WhiteSur-wallpapers/install-wallpapers.sh || true
print_status "Wallpapers installed"

# -------------------- GTK THEME --------------------
print_info "Installing WhiteSur GTK theme..."
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
cd WhiteSur-gtk-theme
chmod +x install.sh

if [[ "$DE_MODE" == "cinnamon" ]]; then
    ./install.sh --name WhiteSur --theme all --round
else
    ./install.sh --name WhiteSur --theme all --libadwaita --shell --round
fi

print_status "GTK theme installed"
cd ..

# -------------------- CURSOR APPLY --------------------
print_info "Applying cursor theme..."

if [[ "$DE_MODE" == "cinnamon" ]]; then
    gsettings set org.cinnamon.desktop.interface cursor-theme "McMojave-cursors" || true
else
    gsettings set org.gnome.desktop.interface cursor-theme "McMojave-cursors" || true
fi

print_status "Cursor theme applied"
# -------------------- X11 CURSOR FALLBACK --------------------
print_info "Setting X11 cursor fallback..."

mkdir -p ~/.icons/default

cat > ~/.icons/default/index.theme <<EOF
[Icon Theme]
Name=Default
Inherits=McMojave-cursors
EOF

print_status "X11 cursor fallback set"

# -------------------- GNOME ONLY --------------------
if [[ "$DE_MODE" != "cinnamon" ]]; then
    print_info "Applying GNOME tweaks..."

    gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark" || true
    gsettings set org.gnome.desktop.interface icon-theme "Cupertino-Sonoma" || true
    gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:' || true

    print_status "GNOME configured"
fi

# -------------------- CINNAMON SETTINGS --------------------
if [[ "$DE_MODE" == "cinnamon" ]]; then
    gsettings set org.cinnamon.desktop.interface gtk-theme "WhiteSur-Dark" || true
    gsettings set org.cinnamon.desktop.interface icon-theme "Cupertino-Sonoma" || true
    gsettings set org.cinnamon.desktop.wm.preferences theme "WhiteSur-Dark" || true
fi

# -------------------- macOS SOUNDS --------------------
if [[ "$INSTALL_SOUNDS" == "1" ]]; then
    print_info "Installing macOS sound theme..."

    SOUND_BASE="$HOME/.local/share/sounds"
    SOUND_DIR="$SOUND_BASE/macOS"

    # Ensure base directory exists
    mkdir -p "$SOUND_BASE"

    # Clean previous install (if any)
    rm -rf "$SOUND_DIR"

    # Clone correct repository
    if git clone https://github.com/vinceliuice/WhiteSur-sound-theme.git "$SOUND_DIR"; then
        print_status "macOS sound files downloaded"
    else
        print_warning "Failed to download macOS sound theme, skipping sounds"
        INSTALL_SOUNDS=0
    fi

    # Create index.theme ONLY if directory exists
    if [[ -d "$SOUND_DIR" ]]; then
        cat > "$SOUND_DIR/index.theme" <<EOF
[Sound Theme]
Name=macOS
Comment=macOS Sequoia Sounds
Directories=stereo

[stereo]
OutputProfile=stereo
EOF
        print_status "Sound theme metadata created"
    fi

    # Enable event sounds safely
    if [[ "$DE_MODE" == "cinnamon" ]]; then
        gsettings set org.cinnamon.desktop.sound theme-name "macOS" || true
        gsettings set org.cinnamon.desktop.sound event-sounds true || true
    else
        gsettings set org.gnome.desktop.sound theme-name "macOS" || true
        gsettings set org.gnome.desktop.sound event-sounds true || true
    fi

    print_status "macOS sound theme activated"
fi

# -------------------- CLEANUP --------------------
cd ~
rm -rf "$TEMP_DIR"
print_status "Cleanup complete"

# -------------------- DONE --------------------
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation Complete${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
print_warning "Please reboot to apply all changes"
read -p "Press Enter to reboot or Ctrl+C to cancel..."
sudo reboot
