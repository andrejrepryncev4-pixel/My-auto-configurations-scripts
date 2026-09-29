#!/bin/bash
#omarchy-setup script from Andrejrepryncev-Pixel4
#Version 1.7.1 - Fixed || true syntax error, Oh My Zsh check
#Time of editing is Monday 29 September 2026 in 12:38
#omarchy-setup script from Andrejrepryncev-Pixel4
#And this is my look how i like the system and if you dont like well just write the script for yourself
#Null - making sure that the script not will fall while active and make snapshot

#----------------------------------Part (Null): Checking if you legit or not---------------------------------

set -euo pipefail

REAL_USER=$(logname 2>/dev/null || echo "${SUDO_USER:-$USER}")

if [ "$EUID" -eq 0 ]; then
    echo "ERROR: Not launch the script from root!"
    echo "xdg-settings will go in root settings not in your home directory"
    echo "Launch without sudo: bash $0"
    exit 1
fi
clear
#Starting to logging things 
LOG_FILE="$HOME/omarchy-setup-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
# Checking that system is even omarchy
if ! grep -qi "omarchy" /etc/os-release 2>/dev/null; then
    echo "============================================================"
    echo " ERROR: This system is NOT Omarchy!"
    echo " This script is designed only for Omarchy. Exiting now..."
    echo "============================================================"
    exit 1
fi
echo "System verified: Omarchy detected."

#Null.1 - Starting to make snapshot cuz we need this and checking for it

if ! sudo snapper list-configs > /dev/null 2>&1; then
  echo "Snapper not configured. Exiting now"  
  exit 1
else
   sudo snapper create -c root --type single --description "Before script"
fi


#----------------------------------Part 0 : Preparing things ---------------------------------
#0.0 Checking the internet connection
echo "Checking internet connection..."
if ! curl -s --max-time 3 https://archlinux.org> /dev/null 2>&1; then 
    echo " ERROR: No internet connection detected!"
    echo " This script cannot work without internet. Exiting now... And where do you live why no internet here ?"
    exit 1
fi
echo "Internet connection verified. Moving forward..."

# 0.1 Ensure multilib is enabled (Crucial for Steam & 32-bit Wine drivers)
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "Enabling [multilib] repository in pacman.conf..."
    echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
    sudo pacman -Sy
fi

#0.2 Auto-Detect Graphics Card and Install 32-bit & Vulkan Drivers
echo "Detecting graphics hardware..."
GPU_INFO=$(lspci | grep -iE 'vga|3d')

if echo "$GPU_INFO" | grep -iq "nvidia"; then
    echo "NVIDIA card detected. Installing official proprietary drivers..."
    sudo pacman -S --needed --noconfirm nvidia-utils lib32-nvidia-utils || true
elif echo "$GPU_INFO" | grep -iq "amd"; then
    echo "AMD card detected. Installing open-source Radeon Vulkan drivers..."
    sudo pacman -S --needed --noconfirm mesa vulkan-radeon lib32-vulkan-radeon lib32-mesa || true
elif echo "$GPU_INFO" | grep -iq "intel"; then
    echo "Intel graphics detected. Installing Intel Vulkan drivers..."
    sudo pacman -S --needed --noconfirm vulkan-intel lib32-vulkan-intel lib32-mesa|| true
else
    echo "Generic or Virtual GPU detected. Skipping specialized drivers. And sorry what the hell the gpu do you have ?"
fi




# 0.3 Auto-Detect Wi-Fi & Bluetooth Hardware and Install Utilities
echo "Checking for wireless and connectivity hardware..."
HARDWARE_INFO=$(lspci; lsusb)

#0.3.1  Wi-Fi check :
if echo "$HARDWARE_INFO" | grep -iqE "wireless|wi-fi|wlan|802.11"; then
    echo "Wi-Fi adapter detected. Ensuring network utilities are installed..."
    sudo pacman -S --needed --noconfirm iw networkmanager || true
else
    echo "No Wi-Fi adapter detected. Skipping wireless software."
fi

#0.3.2 Bluetooth Checking
if echo "$HARDWARE_INFO" | grep -iqE "bluetooth|bt "; then
    echo "Bluetooth adapter detected. Installing BlueZ stack and Blueman manager..."
    sudo pacman -S --needed --noconfirm bluez bluez-utils blueman || true
    # Turning on the bluetooth service 
    sudo systemctl enable --now bluetooth > /dev/null 2>&1
else
    echo "No Bluetooth adapter detected. Skipping Bluetooth software. My mom have blue tooth on pc"
fi
#0.4 Finding the fastest mirror, updating transaction keys and updating data of pacman AUR and installing flatpak
sudo pacman-key --init || true
sudo pacman-key --populate archlinux cachyos > /dev/null 2>&1 || true
if command -v cachyos-rate-mirrors &>/dev/null; then
    sudo cachyos-rate-mirrors > /dev/null 2>&1 || true
fi
sudo pacman -Syu --noconfirm || true
sudo pacman -S --needed --noconfirm flatpak || true
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true

# 0.5 Backup of everything
if [ -d "$HOME/.config" ] && [ ! -d "$HOME/.config.bak" ]; then
    echo "Creating backup of ~/.config..."
    cp -a "$HOME/.config" "$HOME/.config.bak"
    echo "Backup created: ~/.config.bak"
else
    echo "Backup already exists or ~/.config not found. Skipping. Delete ~/.config.bak manually if you want a fresh backup."
fi
clear
#----------------------------------Part 1 : Customisations( Zsh ) ---------------------------------
# Preparing zsh + oh my zsh   terminal
echo "=== Installing Zsh and dependencies ==="
sudo pacman -S --noconfirm --needed zsh zsh-completions git curl base-devel || true

USER_NAME="$REAL_USER"
USER_HOME=$(eval echo "~$REAL_USER")  

# Backup  of old zsh if it exists
if [ -f "$USER_HOME/.zshrc" ]; then
    echo "=== Backing up existing .zshrc ==="
    cp "$USER_HOME/.zshrc" "$USER_HOME/.zshrc.bak"
fi

echo "=== Non-interactive Oh My Zsh installation ==="
ZSH_CUSTOM="$USER_HOME/.oh-my-zsh/custom"

# Installing oh my zsh
if [ -d "$USER_HOME/.oh-my-zsh" ]; then
    echo "=== Oh My Zsh already installed. Skipping. ==="
else
    echo "=== Downloading Oh My Zsh installer ==="
    OHMYZSH_INSTALLER="/tmp/ohmyzsh-install.sh"
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o "$OHMYZSH_INSTALLER"
    echo "Installer SHA256:"
    sha256sum "$OHMYZSH_INSTALLER"
    sudo -u "$USER_NAME" sh "$OHMYZSH_INSTALLER" --unattended
    rm -f "$OHMYZSH_INSTALLER"
fi

echo "=== Cloning Zsh plugins ==="
# Cloning plugins 
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    PLUGIN_DIR="$ZSH_CUSTOM/plugins/$plugin"
    if [ -d "$PLUGIN_DIR" ]; then
        echo "Plugin $plugin already exists, updating..."
        sudo -u "$USER_NAME" git -C "$PLUGIN_DIR" pull
    else
        echo "Cloning $plugin..."
        sudo -u "$USER_NAME" git clone "https://github.com/zsh-users/$plugin.git" "$PLUGIN_DIR"
    fi
done

# Creating config file 
echo "=== Creating new .zshrc ==="
if [ -f "$USER_HOME/.zshrc" ]; then
    echo "Existing .zshrc found. Overwrite with the script's version? [y/N]"
    read -r overwrite < /dev/tty || overwrite="n"
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
        echo "Skipping .zshrc overwrite. Backup is at ~/.zshrc.bak"
    else
        cat << 'EOF' | sudo -u "$REAL_USER" tee "$USER_HOME/.zshrc" > /dev/null
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="clean"
plugins=(git zsh-completions zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
EOF
    fi
else
    # If no file creating it 
    sudo -u "$REAL_USER" tee "$USER_HOME/.zshrc" > /dev/null << 'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="clean"
plugins=(git zsh-completions zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
EOF
fi   

# Changing default shell to Zsh
echo "=== Changing default shell to Zsh ==="
sudo chsh -s /usr/bin/zsh "$REAL_USER"
echo "=== Zsh installation successfully completed! ==="

#----------------------------------Part 1 : Customisations( Hyprland ) ---------------------------------

# 1.0 Going to the directory of the Hyprland setup
HYPR_DIR="$HOME/.config/hypr"

# 1.1 Checking that the directory exists
if [ ! -d "$HYPR_DIR" ]; then
    echo "Error: directory $HYPR_DIR is not found."
    exit 1
fi
# 1.2 Pasting the eng/ru layout in the system and making it switch

INPUT_CONFIG="$HYPR_DIR/input.lua"
INPUT_SETTINGS=' hl.config({
   input = {
     kb_layout = "us,ru",
    kb_options = "grp:alt_shift_toggle",
  }
})'

# 1.3 Checking that the changes applied in the input
if grep -q "grp:alt_shift_toggle" "$INPUT_CONFIG"; then
    echo "The configuration in $INPUT_CONFIG already exists not changing anything else"
else
    echo "$INPUT_SETTINGS" >> "$INPUT_CONFIG"
    echo "The configuration applied in $INPUT_CONFIG"
fi

# 1.4 Applying the looknfeel lua in configuration the transparency and the workspace shifting
LOOK_CONFIG="$HYPR_DIR/looknfeel.lua"
LOOK_SETTINGS='hl.window_rule({
  match = {class = "foot"},
  opacity = "0.8 override 0.8 override 1.0 override",
})
hl.animation({leaf = "workspaces", enabled = true, speed = 10, bezier = "default", style = "slide"})'

if grep -q 'leaf = "workspaces"' "$LOOK_CONFIG" 2>/dev/null; then
    echo "The configuration already exists not changing anything else"
else
    echo "$LOOK_SETTINGS" >> "$LOOK_CONFIG"
    echo "The configuration applied in looknfeel"
fi

# 1.5 Applying the theme and restarting Wayland
THEME_NAME="nord"
omarchy-theme-set "$THEME_NAME" > /dev/null 2>&1
hyprctl reload 2>/dev/null || true

clear
#----------------------------------Part 2 : Removing bloatware and installing all what needed---------------------------------

#2.0 Removing bloatware and web apps
for pkg in chromium  aether kdenlive moonlight-qt obs-studio cliamp; do
  pacman -Qq "$pkg" &>/dev/null && sudo pacman -R --noconfirm "$pkg" || true 
done
omarchy-webapp-remove hey || true
omarchy-webapp-remove basecamp || true
omarchy-webapp-remove chatgpt || true
omarchy-webapp-remove whatsapp || true
omarchy-webapp-remove x || true
omarchy-webapp-remove zoom || true
omarchy-webapp-remove google-maps || true
omarchy-webapp-remove google-messages || true

#2.1 Installing what needed from pacman/aur
sudo pacman -S --needed --noconfirm firefox  jre-openjdk 7zip  qbittorrent python  gnome-boxes steam htop || true

#2.1.1 Setting the firefox and links for it as main and rebooting Hyprland
xdg-settings set default-web-browser firefox.desktop
xdg-mime default firefox.desktop x-scheme-handler/http
xdg-mime default firefox.desktop x-scheme-handler/https
hyprctl reload 2>/dev/null || true

#2.1.2 The separate line for wine cuz its important
sudo pacman -S --needed --noconfirm wine wine-mono wine-gecko winetricks || true
yay -S --needed --noconfirm ttf-ms-fonts

# 2.1.3 Checking for yay
if ! command -v yay &>/dev/null; then
    echo "yay not found. Installing from AUR..."
    cd /tmp 
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
fi

#2.1.4 Yay installing things 
yay -S --needed --noconfirm woeusb-gui  happ-desktop-bin vesctop-bin spotify elyprismlauncher-bin hydra-launcher-bin || true 

# 2.2 All required Qylock, Qt5, Qt6, and GStreamer dependencies
echo "--> Installing login screen theme dependencies..."
sudo pacman -S --needed --noconfirm \
    sddm perl \
    qt5-declarative qt5-graphicaleffects qt5-quickcontrols2 qt5-multimedia \
    qt6-multimedia qt6-multimedia-ffmpeg \
    gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly || true

#----------------------------------Part 3 : Finish-----------------------------
#3.1 Checking what do we have on a disk and if something found we adding it to Limine
if command -v limine-entry-tool &>/dev/null; then
    sudo limine-entry-tool --scan > /dev/null 2>&1 || true
fi
#3.2 Rebooting 
echo "Script is finished. Reboot now? [y/N]"
read -r answer < /dev/tty || answer="n"
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Log saved to: $LOG_FILE"
    clear
    sudo reboot
else
    echo "Ok, no reboot. Do it manually when ready."
    echo "Log saved to: $LOG_FILE"
fi
