#!/bin/bash

# GNOME/GTK: Set left side window buttons as (close, minimize, maximize)
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'

# For Unity
if [ "$XDG_CURRENT_DESKTOP" = "Unity" ]; then
    gsettings set com.canonical.Unity.WindowDecoration button-layout 'close,minimize,maximize:'
fi

echo "[✓] Buttons set to left side (close, minimize, maximize) in GNOME/GTK Apps."

# If using Firefox, also force system's title bar to get GNOME pattern:
if pgrep -x firefox >/dev/null; then
    echo "[i] Please ensure 'Use system title bar and borders' is enabled in Firefox settings (Menu > Customize Toolbar)"
fi

# Electron & Chrome/Chromium Note:
echo "[i] For Electron/Chrome/Chromium-native apps, button location cannot be controlled at system-level, only by their theme or startup flags (or custom patching)."
echo "[!] Most Electron apps follow their own button layout and may not match GNOME's."

# Button colors: For true colored macOS-style buttons, you must use a GTK/Window theme like WhiteSur, macOS-3, or McMojave that provides colored button icons. GNOME and most Linux WM don't let you color the buttons individually via gsettings alone.
echo "[i] For colored 'traffic light' buttons, please use a macOS-like GTK theme such as WhiteSur."

# To reload live:
echo "[i] If changes do not show up instantly, log out/in or restart GNOME Shell (Alt+F2, then type r)."
