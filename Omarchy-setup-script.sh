#!/bin/bash
#----------------------------------Part 0 : Prerairing things ---------------------------------
#0.0.0 Cheching that system is omarchy
if ! grep -qi "omarchy" /etc/os-release 2>/dev/null; then
    echo "============================================================"
    echo " ERROR: This system is NOT Omarchy!"
    echo " This script is designed only for Omarchy. Exiting now..."
    echo "============================================================"
    exit 1
fi
echo "System verified: Omarchy detected."


#0.0.2 Cheching the internet connection 
echo "Checking internet connection..."
if ! ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then 
    echo " ERROR: No internet connection detected!"
    echo " This script cannot work without internet. Exiting now..."
    exit 1
fi
echo "Internet connection verified. Moving forward..."

# 0.0.3 Ensure multilib is enabled (Crucial for Steam & 32-bit Wine drivers)
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "Enabling [multilib] repository in pacman.conf..."
    echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
    sudo pacman -Sy
fi

#0.0.3.1 Auto-Detect Graphics Card and Install 32-bit & Vulkan Drivers
echo "Detecting graphics hardware..."
GPU_INFO=$(lspci | grep -iE 'vga|3d')

if echo "$GPU_INFO" | grep -iq "nvidia"; then
    echo "NVIDIA card detected. Installing official proprietary drivers..."
    sudo pacman -S --noconfirm nvidia-utils lib32-nvidia-utils
elif echo "$GPU_INFO" | grep -iq "amd"; then
    echo "AMD card detected. Installing open-source Radeon Vulkan drivers..."
    sudo pacman -S --noconfirm vulkan-radeon lib32-vulkan-radeon lib32-mesa
elif echo "$GPU_INFO" | grep -iq "intel"; then
    echo "Intel graphics detected. Installing Intel Vulkan drivers..."
    sudo pacman -S --noconfirm vulkan-intel lib32-vulkan-intel lib32-mesa
else
    echo "Generic or Virtual GPU detected. Skipping specialized drivers.And sorry what the hell the gpu do you have ?"
fi




# 0.0.4 Auto-Detect Wi-Fi & Bluetooth Hardware and Install Utilities
echo "Checking for wireless and connectivity hardware..."
HARDWARE_INFO=$(lspci && lsusb)

#0.0.4.1  Wi-Fi check :
if echo "$HARDWARE_INFO" | grep -iqE "wireless|wi-fi|wlan|802.11"; then
    echo "Wi-Fi adapter detected. Ensuring network utilities are installed..."
    sudo pacman -S --noconfirm iw networkmanager
else
    echo "No Wi-Fi adapter detected. Skipping wireless software."
fi

#0.0.4.2 Bluetooth Checking
if echo "$HARDWARE_INFO" | grep -iqE "bluetooth|bt "; then
    echo "Bluetooth adapter detected. Installing BlueZ stack and Blueman manager..."
    sudo pacman -S --noconfirm bluez bluez-utils blueman
    
    # Turning on the bluetooth service 
    sudo systemctl enable --now bluetooth > /dev/null 2>&1
else
    echo "No Bluetooth adapter detected. Skipping Bluetooth software."
fi



#0.1 Starting to make snapshot cuz we need this 
sudo snapper create --type single --description "Before script"

#0.2 Finding the fastes mirror updating transaction keys and updating data of pacman aur and the installing flatpack 
sudo cachyos-rate-mirrors > /dev/null 2>&1
sudo pacman-key --init
sudo pacman-key --populate archlinux cachyos > /dev/null 2>&1
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm flatpak


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
INPUT_SETTINGS='
 hl.config({
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
LOOK_SETTINGS='
--      The transperency of terminal 
hl.window_rule({
  match = {class = "foot"},
  opacity = "0.8 override 0.8 override 1.0 override",
})

--      Animation of workspace changing
hl.animation({leaf = "workspaces", enabled = true, speed = 10, bezier = "default", style = "slide"})
'

if grep -q "workspaces" "$LOOK_CONFIG" 2>/dev/null; then
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
omarchy-webapp-remove hey
omarchy-webapp-remove basecamp
omarchy-webapp-remove chatgpt
omarchy-webapp-remove whatsapp
omarchy-webapp-remove x
omarchy-webapp-remove zoom
omarchy-webapp-remove google-maps       
omarchy-webapp-remove google-messages



#2.1 Installing what neeeded from pacman/aur
sudo pacman -S --noconfirm firefox base-devel git jre-openjdk 7zip  qbittorrent python  gnome-boxes steam htop 

#2.1.1.1 Setting the firefox and links for it as main and rebooting hyperland 
xdg-settings set default-web-browser firefox.desktop
xdg-mime default firefox.desktop x-scheme-handler/http
xdg-mime default firefox.desktop x-scheme-handler/https
hyprctl reload


#2.1.2 The sepparate line for wine cuz its important 
sudo pacman -S --noconfirm wine wine-mono wine-gecko winetricks
yay -S --noconfirm ttf-ms-fonts

#2.1.4 Yay installing things 
yay -S --noconfirm woeusb-gui  happ-desktop-bin vesctop-bin spotify elyprismlauncher-bin hydra-launcher-bin

# 2.2 ADDED: All required Qylock, Qt5, Qt6, and GStreamer dependencies
echo "--> Installing login screen theme dependencies..."
sudo pacman -S --noconfirm \
    sddm perl \
    qt5-declarative qt5-graphicaleffects qt5-quickcontrols2 qt5-multimedia \
    qt6-multimedia qt6-multimedia-ffmpeg \
    gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly

#----------------------------------Part 2.2 : Plugins Installation ----------------------------

echo "Starting Omarchy plugins installation phase..."

# 2.2.1. Network status
echo "Installing Network Speed status plugin..."
omarchy plugin add https://github.com/brightwalker25/omarchy-net-speed.git --enable
echo "============================================================"
echo " ACTION REQUIRED: Network Speed plugin installed!"
echo " The script will now open the Omarchy plugin settings."
echo " Configure your network units (bits/bytes) and panel view."
echo " Once done, PRESS [ENTER] IN THIS TERMINAL to continue."
echo "============================================================"
omarchy menu summon style.plugins &
read -p "Waiting for Network Speed setup... Press Enter: "

# 2.2.2. Git notifications and actions
echo "Istalling Foamy GitHub plugin..."
omarchy plugin add https://github.com/foamrider/foamy-github.git --enable
echo "============================================================"
echo " ACTION REQUIRED: GitHub plugin installed!"
echo " Please click the widget cog and configure your repository paths."
echo " Once done, PRESS [ENTER] IN THIS TERMINAL to continue."
echo "============================================================"
read -p "Waiting for GitHub setup... Press Enter: "

# 2.2.3. Audio control
echo "Installing Foamy Audio control plugin..."
omarchy plugin add https://github.com/foamrider/foamy-audio.git --enable
echo "============================================================"
echo " ACTION REQUIRED: Audio plugin installed!"
echo " Open the panel, check your PipeWire outputs or AirPlay setup."
echo " Once done, PRESS [ENTER] IN THIS TERMINAL to continue."
echo "============================================================"
read -p "Waiting for Audio setup... Press Enter: "

# 2.2.4. The system resources usage
echo "Installing Foamy Vitals resource plugin..."
omarchy plugin add https://github.com/foamrider/foamy-vitals.git --enable
echo "============================================================"
echo " ACTION REQUIRED: Vitals resource plugin installed!"
echo " Configure your warning thresholds or CPU/GPU temperature sensors."
echo " Once done, PRESS [ENTER] IN THIS TERMINAL to continue."
echo "============================================================"
read -p "Waiting for Vitals setup... Press Enter: "

# 2.2.5. System tray
echo "Installing Foamy Tray plugin..."
omarchy plugin add https://github.com/foamrider/foamy-tray.git --enable
echo "============================================================"
echo " ACTION REQUIRED: System Tray plugin installed!"
echo " Ensure your background apps (Steam, Discord) show up on the bar."
echo " Once done, PRESS [ENTER] IN THIS TERMINAL to continue."
echo "============================================================"
read -p "Waiting for System Tray setup... Press Enter: "


# Cheching the system is a Pc or a latop  (does we have the battery or not)
if ls /sys/class/power_supply/ | grep -q "^BAT"; then
    echo "Battery found! Device identified as a Laptop."
    echo "Installing Foamy Power battery plugin..."
    omarchy plugin add https://github.com/foamrider/foamy-power.git --enable
    echo "============================================================"
    echo " ACTION REQUIRED: Laptop Battery plugin installed!"
    echo " Configure separate AC and Battery profiles if needed."
    echo " Once done, PRESS [ENTER] IN THIS TERMINAL to continue."
    echo "============================================================"
    read -p "Waiting for Battery setup... Press Enter: "
else
    echo "No battery found. Device identified as a Desktop PC. Skipping battery plugin."
fi

echo "All plugins configured successfully! Moving to the final stage..."




#----------------------------------Part 3 : Finish-----------------------------
#3.1 Cheching what do we have on a disk and if something finded we addding it to limine
sudo limine-entry-tool --scan > /dev/null 2>&1

#3.2 Rebooting 
echo "Script is finished rebooting in 10 seconds"
for i in {10..1}; do
    echo -ne "Rebooting in $i seconds...\r"
    sleep 1
done

echo -e "\nRebooting now!"
sudo reboot
