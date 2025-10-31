Run this code before executing any files 
chmod +x <filename>   ..i.e. chmod +x macify-ubuntu.sh
./<filename>          ..i.e. ./macify-ubuntu.sh 



║         COMPLETE CODE IMPLEMENTATION GUIDE v2.5+                ║
║                                                                 ║
║      macOS Sequoia Theme Installer - Full Source Code           ║
║                                                                 
╚═════════════════════════════════════════════════════════════


📄 FILES PROVIDED
═════════════════════════════════════════════════════════════════

1. macos_sequoia_installer_v2.5_complete.sh
   ├─ Main installer script
   ├─ 709 lines, ~22.5 KB
   ├─ Complete with all features


2. macos_sequoia_uninstaller_v2.5_complete.sh
   ├─ Complete uninstaller
   ├─ 169 lines, ~5.9 KB
   ├─ Safe removal


3. sequoia.sh
   ├─ YT-reference installer script
   ├─ 443 lines, ~15.6 KB


4. undo.sh
   ├─ YT-reference un-installer script
   ├─ 3 lines, 133 bytes


5. whitesur_wallpaper_daynight_fix.sh ( TO APPLY MAC OS WALLPAPER )
   ├─ 487 lines of bash code
   ├─ ~16 KB size
   ├─ Full error handling


6. macos_window_buttons_fix.sh (TO FIX WINDOW BUTTON STYLE)
   ├─ 58 lines of bash code
   ├─ ~2.4 KB size
   ├─ Full error handling  

═════════════════════════════════════════════════════════════════
INSTALLATION INSTRUCTIONS
═════════════════════════════════════════════════════════════════

STEP 1: Copy files to your system
────────────────────────────────────────────────────────────────
$ cp macos_sequoia_installer_v2.5_complete.sh ~/
$ cp macos_sequoia_uninstaller_v2.5_complete.sh ~/


STEP 2: Make scripts executable
────────────────────────────────────────────────────────────────
$ chmod +x ~/macos_sequoia_installer_v2.5_complete.sh
$ chmod +x ~/macos_sequoia_uninstaller_v2.5_complete.sh


STEP 3: Run the installer
────────────────────────────────────────────────────────────────
$ ~/macos_sequoia_installer_v2.5_complete.sh


STEP 4: Follow the interactive menus
────────────────────────────────────────────────────────────────
1. Theme style (GNOME or Unity)
2. macOS version (5 options)
3. Color accent (8 options)
4. File manager style (5 options)
5. Sounds (yes/no)
6. Backup (yes/no)


STEP 5: Wait for installation (~5-30 minutes)
────────────────────────────────────────────────────────────────
Installation will proceed automatically


STEP 6: Reboot when prompted
────────────────────────────────────────────────────────────────
$ sudo reboot


STEP 7: Enjoy your new desktop!
────────────────────────────────────────────────────────────────
Your Ubuntu/Debian system now looks like macOS!


═════════════════════════════════════════════════════════════════
INSTALLER CODE STRUCTURE
═════════════════════════════════════════════════════════════════

MAIN INSTALLER: macos_sequoia_installer_v2.5_complete.sh

SECTION 1: INITIALIZATION (Lines 1-100)
├─ Color definitions
├─ Output functions
├─ OS detection
├─ Desktop environment detection

SECTION 2: INTERACTIVE MENUS (Lines 101-300)
├─ Unity theme choice
├─ macOS version selection (5 versions)
├─ Color accent selection (8 colors)
├─ File manager style selection (5 styles)
├─ Sounds choice
├─ Backup options

SECTION 3: SYSTEM PREPARATION (Lines 301-400)
├─ System update
├─ Essential tools installation
├─ Flatpak setup
├─ Icon pack download
├─ Wallpaper download

SECTION 4: THEME INSTALLATION (Lines 401-500)
├─ WhiteSur theme download
├─ Theme installation with custom options
├─ GDM configuration
├─ Firefox theming
├─ Flatpak support

SECTION 5: SOUNDS INSTALLATION (Lines 501-550)
├─ Sound pack download (optional)
├─ Sound theme configuration
├─ Theme metadata creation

SECTION 6: GNOME CUSTOMIZATION (Lines 551-650)
├─ Settings configuration
├─ Extension installation (6 extensions)
├─ Extension configuration
├─ Theme application

SECTION 7: COMPLETION (Lines 651-709)
├─ Cleanup
├─ Final messages
├─ Reboot prompt


═════════════════════════════════════════════════════════════════
KEY FUNCTIONS IN INSTALLER
═════════════════════════════════════════════════════════════════

COLOR & OUTPUT FUNCTIONS:
────────────────────────────────────────────────────────────────

print_status()
  Usage: print_status "Message"
  Output: [✓] Message (green)

print_info()
  Usage: print_info "Message"
  Output: [i] Message (blue)

print_warning()
  Usage: print_warning "Message"
  Output: [!] Message (yellow)

print_error()
  Usage: print_error "Message"
  Output: [✗] Message (red)


DETECTION FUNCTIONS:
────────────────────────────────────────────────────────────────

detect_os()
  Purpose: Detect OS name, version, ID
  Source: /etc/os-release
  Sets: OS_NAME, OS_VERSION, OS_ID

check_desktop_environment()
  Purpose: Detect GNOME or Unity
  Methods: XDG_CURRENT_DESKTOP, gnome-shell --version
  Sets: DETECTED_DESKTOP, DETECTED_GNOME


MENU FUNCTIONS:
────────────────────────────────────────────────────────────────

handle_unity_theme_choice()
  Choices: GNOME-style or Unity-based
  Sets: THEME_STYLE

handle_macos_version_choice()
  Choices: Sequoia, Monterey, Big Sur, Catalina, Light
  Sets: MACOS_VERSION, MACOS_ALT, THEME_NAME

handle_color_accent_choice()
  Choices: 8 colors (Default, Blue, Purple, etc.)
  Sets: COLOR_ACCENT, THEME_NAME

handle_file_manager_choice()
  Choices: 5 styles (Stable, Normal, Mojave, Glassy, Right)
  Sets: FM_STYLE

handle_sounds_choice()
  Choices: Yes/No
  Sets: INSTALL_SOUNDS

handle_backup_options()
  Choices: Backup, Skip, Exit
  Actions: Timeshift backup creation


═════════════════════════════════════════════════════════════════
INSTALLATION FLOW
═════════════════════════════════════════════════════════════════

detect_os()
    ↓
check_desktop_environment()
    ↓
[If Unity] handle_unity_theme_choice()
    ↓
display_system_info()
    ↓
handle_macos_version_choice()
    ↓
handle_color_accent_choice()
    ↓
handle_file_manager_choice()
    ↓
handle_sounds_choice()
    ↓
handle_backup_options()
    ↓
System update & package installation
    ↓
Flatpak setup
    ↓
Download: Icons, Wallpapers, Theme
    ↓
Install: Theme with custom options
    ↓
[If sounds] Install: Sound pack
    ↓
Configure: GNOME settings
    ↓
Install: 6 GNOME extensions
    ↓
Configure: Extensions
    ↓
Apply: Final themes
    ↓
Cleanup temporary files
    ↓
Reboot


═════════════════════════════════════════════════════════════════
CUSTOMIZATION OPTIONS
═════════════════════════════════════════════════════════════════

MODIFYING MACOS VERSIONS:

To add a new macOS version, add to handle_macos_version_choice():

*)
    print_status "Selected: New Version"
    MACOS_VERSION="new-version"
    MACOS_ALT="new-version"
    ;;


MODIFYING COLOR ACCENTS:

To add a new color, add to handle_color_accent_choice():

N)
    print_status "Selected: New Color"
    COLOR_ACCENT="newcolor"
    THEME_NAME="WhiteSur-NewColor"
    ;;


MODIFYING FILE MANAGER STYLES:

To add new style, add to handle_file_manager_choice():

N)
    print_status "Selected: New Style"
    FM_STYLE="new-style"
    ;;


MODIFYING EXTENSIONS:

To add new extension, modify extension installation section:

install_gnome_extension EXTENSION_ID "Extension Name"


MODIFYING SOUNDS:

To use different sound pack, modify sounds section:

git clone https://github.com/[your-sound-pack] 
    ~/.local/share/sounds/macOS


═════════════════════════════════════════════════════════════════
VARIABLES USED
═════════════════════════════════════════════════════════════════

SYSTEM VARIABLES:
├─ OS_NAME: Ubuntu, Debian, etc.
├─ OS_VERSION: 25.10, 24.04, etc.
├─ OS_ID: ubuntu, debian, etc.
├─ DETECTED_DESKTOP: GNOME or Unity
├─ DETECTED_GNOME: 0 or 1
├─ DESKTOP: XDG_CURRENT_DESKTOP value

USER CHOICE VARIABLES:
├─ THEME_STYLE: GNOME or UNITY
├─ MACOS_VERSION: sequoia, monterey, big-sur, catalina, light
├─ MACOS_ALT: Version variant for install.sh
├─ COLOR_ACCENT: gray, blue, purple, pink, red, orange, yellow, green
├─ THEME_NAME: WhiteSur-[Color] (final theme name)
├─ FM_STYLE: stable, normal, mojave, glassy, right
├─ INSTALL_SOUNDS: 0 or 1
├─ backup_choice: 1, 2, or 3

INSTALLATION VARIABLES:
├─ TEMP_DIR: Temporary directory for downloads
├─ GNOME_VERSION: Detected GNOME Shell version
├─ EXTENSION_ID: Extension ID from gnome.org
├─ UUID: Extension UUID
├─ INSTALL_ARGS: Arguments for WhiteSur install.sh


═════════════════════════════════════════════════════════════════
ERROR HANDLING
═════════════════════════════════════════════════════════════════

Script uses "set -e" which means:
├─ Exits on first error
├─ Each command must succeed
├─ Logical flow is preserved

Fallback mechanisms:
├─ Theme installation falls back to basic arguments
├─ Extensions continue if one fails
├─ Missing packages don't stop installation
├─ GDM tweaks are optional

Try-catch patterns:
├─ ./install.sh command || fallback_command
├─ git clone || print_warning
├─ if command_exists; then use_it; else skip; fi


═════════════════════════════════════════════════════════════════
LOGGING & DEBUGGING
═════════════════════════════════════════════════════════════════

Output captured to files:
├─ install_output.log: Theme installation output
├─ tweaks_output.log: GDM/Firefox/Flatpak tweaks

Colored output for easy reading:
├─ [✓] Green: Success
├─ [i] Blue: Information
├─ [!] Yellow: Warning
├─ [✗] Red: Error

To enable verbose debugging:
├─ Add "set -x" after shebang
├─ Removes "2>/dev/null" redirects
├─ Shows all executed commands


═════════════════════════════════════════════════════════════════
UNINSTALLER CODE STRUCTURE
═════════════════════════════════════════════════════════════════

UNINSTALLER: macos_sequoia_uninstaller_v2.5_complete.sh

SECTION 1: INITIALIZATION (Lines 1-50)
├─ Color definitions
├─ Output functions

SECTION 2: CONFIRMATION (Lines 51-70)
├─ Display system info
├─ Require "yes" confirmation

SECTION 3: REMOVAL (Lines 71-150)
├─ Remove WhiteSur theme
├─ Remove icon packs
├─ Remove wallpapers
├─ Remove sound theme
├─ Reset GNOME settings
├─ Disable extensions

SECTION 4: CLEANUP (Lines 151-169)
├─ Remove extension files
├─ Remove theme directories
├─ Clear cache
├─ Reboot


═════════════════════════════════════════════════════════════════
USAGE EXAMPLES
═════════════════════════════════════════════════════════════════

BASIC INSTALLATION:

$ ./macos_sequoia_installer_v2.5_complete.sh
→ Follow prompts for each choice
→ Select: Sequoia + Blue + Glassy + Sounds + Backup
→ Wait for completion
→ Reboot


QUICK INSTALLATION (No backup):

$ ./macos_sequoia_installer_v2.5_complete.sh
→ Select: Sequoia + Gray + Stable + No Sounds + Skip Backup
→ Faster installation (5-10 minutes)


UNINSTALLATION:

$ ./macos_sequoia_uninstaller_v2.5_complete.sh
→ Type "yes" to confirm
→ Wait for removal
→ Optional: Remove extensions
→ Reboot


USING TIMESHIFT BACKUP:

$ timeshift --list
→ Shows all backups

$ timeshift --restore --snapshot '<snapshot-name>'
→ Restores system to backup


═════════════════════════════════════════════════════════════════
TROUBLESHOOTING
═════════════════════════════════════════════════════════════════

IF INSTALLER FAILS:

1. Check error messages
2. Read logs: tail install_output.log
3. Check internet connection
4. Verify disk space: df -h
5. Try running again

IF THEME DOESN'T APPLY:

1. Verify reboot completed
2. Check GNOME Tweaks
3. Verify theme installed: ls ~/.themes/
4. Reset gsettings manually:
   $ gsettings set org.gnome.desktop.interface \
     gtk-theme 'WhiteSur-Dark'
5. Restart GNOME Shell: Alt+F2 'r'

IF SOUNDS DON'T WORK:

1. Check if installed: ls ~/.local/share/sounds/macOS
2. Test sound: paplay ~/.local/share/sounds/macOS/stereo/bell.oga
3. Check volume: pactl get-sink-volume 0
4. Reconfigure: gsettings set org.gnome.desktop.sound \
   theme-name 'macOS'

IF EXTENSIONS FAIL:

1. Check GNOME version: gnome-shell --version
2. Open Extensions Manager
3. Check for errors
4. Try reloading: systemctl --user restart org.gnome.Shell.target


═════════════════════════════════════════════════════════════════
MODIFICATION GUIDE
═════════════════════════════════════════════════════════════════

TO ADD NEW macOS VERSION:

1. Find handle_macos_version_choice() function
2. Add new case with unique version name
3. Add corresponding IF statement in theme installation
4. Ensure WhiteSur repository supports the variant

Example:
5)
    print_status "Selected: macOS Ventura"
    MACOS_VERSION="ventura"
    MACOS_ALT="ventura"
    ;;


TO ADD NEW COLOR:

1. Find handle_color_accent_choice() function
2. Add new case with unique color name
3. Update THEME_NAME to match theme name
4. Ensure theme variant exists in installation

Example:
9)
    print_status "Selected: Cyan"
    COLOR_ACCENT="cyan"
    THEME_NAME="WhiteSur-Cyan"
    ;;


TO MODIFY THEME INSTALLATION:

1. Find WhiteSur installation section (~line 450)
2. Modify INSTALL_ARGS variable
3. Add/remove arguments based on WhiteSur --help
4. Test with different argument combinations


TO ADD NEW GNOME EXTENSION:

1. Find GNOME extensions installation section (~line 600)
2. Add: install_gnome_extension EXTENSION_ID "Name"
3. Find extension ID from extensions.gnome.org
4. Test installation


═════════════════════════════════════════════════════════════════
VERSION INFORMATION
═════════════════════════════════════════════════════════════════

Current Version: 2.5+

Key Features:
✓ 5 macOS theme versions
✓ 8 color accents
✓ 5 file manager styles
✓ macOS sounds
✓ Unity support
✓ Complete customization
✓ 709 lines, fully documented
✓ Production-ready code

Previous Versions:
├─ v2.4: Added macOS sounds
├─ v2.3: Fixed WhiteSur compatibility
├─ v2.2: Added theme style choice
├─ v2.1: Added Unity support
├─ v2.0: Added Debian/Ubuntu support
└─ v1.0: Initial release


═════════════════════════════════════════════════════════════════
SUPPORT & DOCUMENTATION
═════════════════════════════════════════════════════════════════

For complete documentation, see:
├─ MACOS_THEME_OPTIONS.txt (theme details)
├─ MACOS_SOUNDS_GUIDE.txt (sounds setup)
├─ WHITESUR_COMPATIBILITY_FIX.txt (script fixes)
├─ README.md (comprehensive guide)
├─ FINAL_DELIVERY_v2.5.txt (complete overview)

Online resources:
├─ WhiteSur: github.com/vinceliuice/WhiteSur-gtk-theme
├─ Icons: github.com/USBA/Cupertino-Ventura-iCons
├─ Sounds: github.com/vinceliuice/WhiteSur-sound

Message: Download 'Coverflow Alt-Tab' from extension manager 

═════════════════════════════════════════════════════════════════
