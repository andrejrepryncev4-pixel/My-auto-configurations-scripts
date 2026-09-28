#!/bin/bash
#omarchy-setup script from Andrejrepryncev-Pixel4
#Version 1.0 - Bug fixes (( i am lazy @ss to whrite what i fixed or what )) 
#Time of editing is Monday 28 September 2026 in 18:28 
#omarchy-setup script from Andrejrepryncev-Pixel4
#Null - making sure that the scipt not will fall while active and make snapshot 
set -euo pipefail
clear
#Starting to logging things 
exec > >(tee -a ~/omarchy-setup.log) 2>&1
# Cheching that system is even omarchy
if ! grep -qi "omarchy" /etc/os-release 2>/dev/null; then
    echo "============================================================"
    echo " ERROR: This system is NOT Omarchy!"
    echo " This script is designed only for Omarchy. Exiting now..."
    echo "============================================================"
    exit 1
fi
echo "System verified: Omarchy detected."

#Null.1 - Starting to make snapshot cuz we need this 

if ! sudo snapper list-configs > /dev/null 2>&1; then
    echo "Snapper not configured. Skipping snapshot."
else
   sudo snapper create --type single --description "Before script"
fi



#----------------------------------Part 0 : Prerairing things ---------------------------------
#0.0.0 Cheching the internet connection 
echo "Checking internet connection..."
if ! curl -s --max-time 3 https://archlinux.org> /dev/null 2>&1; then 
    echo " ERROR: No internet connection detected!"
    echo " This script cannot work without internet. Exiting now..."
    exit 1
fi
echo "Internet connection verified. Moving forward..."

# 0.0.1 Ensure multilib is enabled (Crucial for Steam & 32-bit Wine drivers)
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "Enabling [multilib] repository in pacman.conf..."
    echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
    sudo pacman -Sy
fi

#0.0.0.1 Auto-Detect Graphics Card and Install 32-bit & Vulkan Drivers
echo "Detecting graphics hardware..."
GPU_INFO=$(lspci | grep -iE 'vga|3d')

if echo "$GPU_INFO" | grep -iq "nvidia"; then
    echo "NVIDIA card detected. Installing official proprietary drivers..."
    sudo pacman -S --needed --noconfirm nvidia-utils lib32-nvidia-utils
elif echo "$GPU_INFO" | grep -iq "amd"; then
    echo "AMD card detected. Installing open-source Radeon Vulkan drivers..."
    sudo pacman -S --needed --noconfirm mesa vulkan-radeon lib32-vulkan-radeon lib32-mesa
elif echo "$GPU_INFO" | grep -iq "intel"; then
    echo "Intel graphics detected. Installing Intel Vulkan drivers..."
    sudo pacman -S --needed --noconfirm vulkan-intel lib32-vulkan-intel lib32-mesa
else
    echo "Generic or Virtual GPU detected. Skipping specialized drivers.And sorry what the hell the gpu do you have ?"
fi




# 0.0.2 Auto-Detect Wi-Fi & Bluetooth Hardware and Install Utilities
echo "Checking for wireless and connectivity hardware..."
HARDWARE_INFO=$(lspci; lsusb)

#0.0.2.1  Wi-Fi check :
if echo "$HARDWARE_INFO" | grep -iqE "wireless|wi-fi|wlan|802.11"; then
    echo "Wi-Fi adapter detected. Ensuring network utilities are installed..."
    sudo pacman -S --needed --noconfirm iw networkmanager
else
    echo "No Wi-Fi adapter detected. Skipping wireless software."
fi

#0.0.2.2 Bluetooth Checking
if echo "$HARDWARE_INFO" | grep -iqE "bluetooth|bt "; then
    echo "Bluetooth adapter detected. Installing BlueZ stack and Blueman manager..."
    sudo pacman -S --needed --noconfirm bluez bluez-utils blueman
    
    # Turning on the bluetooth service 
    sudo systemctl enable --now bluetooth > /dev/null 2>&1
else
    echo "No Bluetooth adapter detected. Skipping Bluetooth software."
fi




#0.2 Finding the fastes mirror updating transaction keys and updating data of pacman aur and the installing flatpack 
sudo pacman-key --init
sudo pacman-key --populate archlinux cachyos > /dev/null 2>&1
sudo cachyos-rate-mirrors > /dev/null 2>&1
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#----------------------------------Part 1 : Customisations---------------------------------

# 1.0 Going to the derectory of the hyperland setup 
HYPR_DIR="$HOME/.config/hypr"


# 1.1 Chehing that the derectory exists 
if [ ! -d "$HYPR_DIR" ]; then
    echo "Error the derectory  $HYPR_DIR is not found."
    exit 1
fi
# 1.2 Pasting the eng/ru layout in the system and making it swith 

INPUT_CONFIG="$HYPR_DIR/input.lua"
INPUT_SETTINGS=' hl.config({
   input = {
     kb_layout = "us,ru",
    kb_options = "grp:alt_shift_toggle",
  }
})'

# 1.3 Chechking that the changes appyed in the iput 
if grep -q "grp:alt_shift_toggle" "$INPUT_CONFIG"; then
    echo "The configuration in $INPUT_CONFIG already exists not changing anything else"
else
    echo "$INPUT_SETTINGS" >> "$INPUT_CONFIG"
    echo "The configuration applyed in  $INPUT_CONFIG"
fi

# 1.4 Allpying the looknfeel lua in configuration the transperency and the workspace shifting 
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
    echo "The configuration applyed in looknfeel"
fi


# 1.5 Appying it pplying the theme  and restaring wayland 
THEME_NAME="nord"
omarchy-theme-set "$THEME_NAME" > /dev/null 2>&1
hyprctl reload


#----------------------------------Part 2 : Removing bloatware and installing all what needed---------------------------------

#2.0 Removing bloatware and web apps
for pkg in chromium  aether kdenlive moonlight-qt obs-studio cliamp; do
  pacman -Qq "$pkg" &>/dev/null && sudo pacman -R --noconfirm "$pkg"
done
omarchy-webapp-remove hey || true
omarchy-webapp-remove basecamp || true
omarchy-webapp-remove chatgpt || true
omarchy-webapp-remove whatsapp || true
omarchy-webapp-remove x || true
omarchy-webapp-remove zoom || true
omarchy-webapp-remove google-maps || true
omarchy-webapp-remove google-messages || true



#2.1 Installing what neeeded from pacman/aur
sudo pacman -S --needed --noconfirm firefox base-devel git jre-openjdk 7zip  qbittorrent python  gnome-boxes steam htop 

#2.1.1.1 Setting the firefox and links for it as main and rebooting hyperland 
xdg-settings set default-web-browser firefox.desktop
xdg-mime default firefox.desktop x-scheme-handler/http
xdg-mime default firefox.desktop x-scheme-handler/https
hyprctl reload


#2.1.2 The sepparate line for wine cuz its important 
sudo pacman -S --needed --noconfirm wine wine-mono wine-gecko winetricks
yay -S --needed --noconfirm ttf-ms-fonts

#2.1.4 Yay installing things 
yay -S --needed --noconfirm woeusb-gui  happ-desktop-bin vesctop-bin spotify elyprismlauncher-bin hydra-launcher-bin || true 

# 2.2 ADDED: All required Qylock, Qt5, Qt6, and GStreamer dependencies
echo "--> Installing login screen theme dependencies..."
sudo pacman -S --needed --noconfirm \
    sddm perl \
    qt5-declarative qt5-graphicaleffects qt5-quickcontrols2 qt5-multimedia \
    qt6-multimedia qt6-multimedia-ffmpeg \
    gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly

#----------------------------------Part 3 : Finish-----------------------------
#3.1 Cheching what do we have on a disk and if something finded we addding it to limine
if command -v limine-entry-tool &>/dev/null; then
    sudo limine-entry-tool --scan > /dev/null 2>&1 || true
fi
#3.2 Rebooting 
echo "Script is finished. Reboot now? [y/N]"
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    sudo reboot
else
    echo "Ok, no reboot. Do it manually when ready."
fi
