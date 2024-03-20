#!/bin/bash

# Continue script execution with superuser privileges

# Define repository URLs
DOTFILES_REPO_URL="https://github.com/ripwoozy/MyArch.git"
YAY_REPO_URL="https://aur.archlinux.org/yay.git"
NVIDIA_DRIVERS_REPO_URL="https://github.com/Frogging-Family/nvidia-all.git"

# Define directories
CONFIG_DIR="$HOME/.config"
LOCAL_BIN_DIR="$HOME/.local/bin"

# Define packages
DEPENDENCIES=("bspwm" "kitty" "neofetch" "picom" "polybar" "rofi" "sxhkd" "feh" "playerctl" "dunst" "scrot")
AUR_PACKAGES=("ttf-jetbrains-mono" "betterlockscreen" "ttf-material-design-icons-desktop-git")
X_PACKAGES=("xorg-server" "xorg-xinit" "xorg-xrandr" "libx11" "libxft" "libxinerama" "xorg-xsetroot")

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display module name
module_name() {
    echo -e "${BLUE}[ $1 ]${NC}"
}

# Function to display status
status() {
    echo -e "${GREEN}$1${NC}"
}

# Function to display error
error() {
    echo -e "${RED}$1${NC}"
}

# Function to handle errors
handle_error() {
    error "Error occurred while $1."
    echo "Possible Solution: $2"
    if [ -n "$3" ]; then
        $3
    fi
    exit 1
}

# Function to check if a package is installed
check_installed() {
    pacman -Qs "$1" >/dev/null 2>&1
}

# Function to create classic Linux folders
create_classic_folders() {
    module_name "Classic Linux Folders"
    status "Creating classic Linux folders..."
    # Check if the directories already exist
    if [ -d "$HOME/Documents" ] || [ -d "$HOME/Downloads" ] || [ -d "$HOME/Music" ] || [ -d "$HOME/Pictures" ] || [ -d "$HOME/Videos" ]; then
        read -p "One or more classic Linux folders already exist. Do you want to overwrite them? (y/n): " overwrite
        case $overwrite in
            y|Y)
                mkdir -p "$HOME/Documents" "$HOME/Downloads" "$HOME/Music" "$HOME/Pictures" "$HOME/Videos" || handle_error "creating classic Linux folders" "Ensure you have necessary permissions." 
                ;;
            *)
                echo "Skipping classic Linux folders creation."
                ;;
        esac
    else
        mkdir -p "$HOME/Documents" "$HOME/Downloads" "$HOME/Music" "$HOME/Pictures" "$HOME/Videos" || handle_error "creating classic Linux folders" "Ensure you have necessary permissions." 
    fi
}

# Function to install yay
install_yay() {
    module_name "Yay"
    status "Installing yay..."
    git clone $YAY_REPO_URL "$HOME/yay" || handle_error "installing yay" "Ensure git is installed." 
    cd "$HOME/yay" || exit
    makepkg -si || handle_error "installing yay" "Ensure you have necessary build tools installed." 
}
# Function to install packages using yay
install_aur_packages() {
    module_name "AUR Packages"
    status "Installing AUR packages..."
    yay -S ${AUR_PACKAGES[@]} || handle_error "installing AUR packages" "Ensure yay is installed." "install_yay"
}

# Function to install X packages
install_x_packages() {
    module_name "X11 Packages"
    status "Installing X packages..."
    sudo pacman -S --noconfirm ${X_PACKAGES[@]} || handle_error "installing X packages" "Ensure you have necessary permissions." 
}

# Function to install NVIDIA drivers from Git
install_nvidia_drivers() {
    module_name "NVIDIA Drivers"
    status "Installing NVIDIA drivers..."
    git clone $NVIDIA_DRIVERS_REPO_URL "$HOME/NVIDIA" || handle_error "installing NVIDIA drivers" "Ensure git is installed." 
    cd "$HOME/NVIDIA" || exit
    makepkg -si || handle_error "installing NVIDIA drivers" "Ensure you have necessary build tools installed." 
}

# Function to install dependencies
install_dependencies() {
    module_name "System Dependencies"
    status "Installing dependencies..."
    sudo pacman -S --noconfirm ${DEPENDENCIES[@]} || handle_error "installing dependencies" "Ensure you have necessary permissions." 
}

# Function to clone the dotfiles repository
clone_repo() {
    module_name "Dotfiles Repository"
    status "Cloning dotfiles repository..."
    git clone $DOTFILES_REPO_URL ~/.dotfiles || handle_error "cloning dotfiles repository" "Ensure git is installed." 
}

# Function to move folders into .config and make files executable
move_and_make_executable() {
    module_name "Configuration Folders"
    status "Moving configuration folders to $CONFIG_DIR and making files executable..."
    # Move and make executable for each configuration folder
    for folder in ~/.dotfiles/*/; do
        config_name=$(basename "$folder")
        mkdir -p "$CONFIG_DIR/$config_name"
        mv "$folder"/* "$CONFIG_DIR/$config_name/"
        chmod +x "$CONFIG_DIR/$config_name"/*
    done

    # Create dunstrc
    touch "$CONFIG_DIR/dunst/dunstrc"
    chmod +x "$CONFIG_DIR/dunst/dunstrc"

    # Move wal folder
    mv ~/.dotfiles/wal "$CONFIG_DIR/"
}

# Function to copy local bin scripts
copy_local_bin() {
    module_name "Local Bin Scripts"
    status "Copying local bin scripts to $LOCAL_BIN_DIR and making them executable..."
    mkdir -p "$LOCAL_BIN_DIR"
    cp -r ~/.dotfiles/local/bin/* "$LOCAL_BIN_DIR/"
    chmod +x "$LOCAL_BIN_DIR"/*
}

# Function to enable betterlockscreen systemd service
enable_betterlockscreen_service() {
    module_name "Betterlockscreen Service"
    status "Enabling betterlockscreen service for $USER..."
    systemctl --user enable betterlockscreen@$USER || handle_error "enabling betterlockscreen service" "Ensure you have necessary permissions." 
}

# Function to copy .xinitrc file from the repo
copy_xinitrc_file() {
    module_name "Xinitrc File"
    status "Copying .xinitrc file from the repository..."
    cp ~/.dotfiles/.xinitrc ~/.xinitrc || handle_error "copying .xinitrc file" "Ensure you have necessary permissions." 
    chmod +x ~/.xinitrc || handle_error "copying .xinitrc file" "Ensure you have necessary permissions." 
}

# Main function
main() {
    create_classic_folders
    install_yay
    install_aur_packages
    install_x_packages
    install_nvidia_drivers  # Optional installation of NVIDIA drivers
    install_dependencies
    clone_repo
    move_and_make_executable
    copy_local_bin
    enable_betterlockscreen_service
    copy_xinitrc_file

    echo -e "${GREEN}Dotfiles installation completed!${NC}"
}

# Execute the main function
echo -e "${GREEN}"
echo "███╗   ███╗██╗   ██╗     █████╗ ██████╗  ██████╗██╗  ██╗"
echo "████╗ ████║╚██╗ ██╔╝    ██╔══██╗██╔══██╗██╔════╝██║  ██║"
echo "██╔████╔██║ ╚████╔╝     ███████║██████╔╝██║     ███████║"
echo "██║╚██╔╝██║  ╚██╔╝      ██╔══██║██╔══██╗██║     ██╔══██║"
echo "██║ ╚═╝ ██║   ██║       ██║  ██║██║  ██║╚██████╗██║  ██║"
echo "╚═╝     ╚═╝   ╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝"
echo -e "${NC}"                                                      
main

