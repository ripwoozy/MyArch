#!/bin/bash
# Minimal Daily Driver Install Script for Thinkpad T480
# This script installs core system components and your dotfiles.
# Run as your regular user (it uses sudo for privileged commands).

set -euo pipefail

#######################
# Configuration
#######################

# Repository URLs and branches
DOTFILES_REPO_URL="https://github.com/ripwoozy/MyArch.git"
DOTFILES_REPO_BRANCH="main"
YAY_REPO_URL="https://aur.archlinux.org/yay.git"
NVIDIA_DRIVERS_REPO_URL="https://github.com/Frogging-Family/nvidia-all.git"

# Directories
CONFIG_DIR="$HOME/.config"
LOCAL_BIN_DIR="$HOME/.local/bin"

# Package arrays
DEPENDENCIES=(
    "bspwm" "kitty" "fastfetch" "picom" "polybar" "rofi" "sxhkd" "feh"
    "playerctl" "dunst" "scrot" "libnotify" "wget" "zsh"
    "alsa-utils" "bluez" "bluez-utils" "bluetui"
    "pipewire" "pipewire-alsa" "pipewire-pulse" "wireplumber"
    "btop" "base-devel"
)
# AUR packages
AUR_PACKAGES=(
    "ttf-jetbrains-mono" "betterlockscreen" "ttf-material-design-icons-desktop-git"
)
X_PACKAGES=(
    "xorg-server" "xorg-xinit" "xorg-xrandr" "libx11" "libxft" "libxinerama" "xorg-xsetroot"
)

# ANSI color codes for pretty output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

#######################
# Helper Functions
#######################

module_name() {
    echo -e "${BLUE}[ $1 ]${NC}"
}

status() {
    echo -e "${GREEN}$1${NC}"
}

error() {
    echo -e "${RED}$1${NC}"
}

handle_error() {
    error "Error while $1."
    echo "Suggestion: $2"
    exit 1
}

# Trap Ctrl+C (SIGINT) to cleanup properly
trap ctrl_c INT
ctrl_c() {
    echo "Ctrl+C pressed. Exiting..."
    cleanup
    exit 1
}

#######################
# Mirror Update Function
#######################

update_mirrors() {
    module_name "Updating Mirrors"
    status "Installing reflector and updating mirror list..."
    sudo pacman -S --noconfirm reflector || handle_error "installing reflector" "Check sudo permissions and internet connection."
    sudo reflector --verbose --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist || handle_error "updating mirrors" "Ensure your internet connection is active."
}

#######################
# Main Functions
#######################

create_classic_folders() {
    module_name "Classic Folders"
    status "Creating classic Linux folders..."
    local folders=(Documents Downloads Music Pictures Videos)
    for folder in "${folders[@]}"; do
        mkdir -p "$HOME/$folder" || handle_error "creating $folder folder" "Check permissions."
    done
}

install_yay() {
    module_name "Yay Installer"
    status "Installing yay..."
    if [ -d "$HOME/yay" ]; then
        status "Yay directory already exists. Skipping clone."
    else
        git clone "$YAY_REPO_URL" "$HOME/yay" || handle_error "cloning yay" "Ensure git is installed."
    fi
    (cd "$HOME/yay" && makepkg -si --noconfirm) || handle_error "building yay" "Ensure build tools are installed."
}

install_aur_packages() {
    module_name "AUR Packages"
    status "Installing AUR packages..."
    yay -S --noconfirm "${AUR_PACKAGES[@]}" || handle_error "installing AUR packages" "Check that yay is installed."
}

install_x_packages() {
    module_name "X11 Packages"
    status "Installing X packages..."
    sudo pacman -S --noconfirm "${X_PACKAGES[@]}" || handle_error "installing X packages" "Check sudo permissions."
}

install_dependencies() {
    module_name "System Dependencies"
    status "Installing dependencies..."
    sudo pacman -S --noconfirm "${DEPENDENCIES[@]}" || handle_error "installing dependencies" "Check sudo permissions."
}

install_nvidia_drivers() {
    module_name "NVIDIA Drivers"
    read -p "Do you want to install NVIDIA drivers? (y/n): " install_nvidia
    case $install_nvidia in
        [yY])
            status "Installing NVIDIA drivers..."
            sudo pacman -S --noconfirm linux-headers || handle_error "installing linux-headers" "Check sudo permissions."
            git clone "$NVIDIA_DRIVERS_REPO_URL" "$HOME/NVIDIA" || handle_error "cloning NVIDIA drivers" "Ensure git is installed."
            (cd "$HOME/NVIDIA" && makepkg -si --noconfirm) || handle_error "building NVIDIA drivers" "Ensure build tools are installed."
            ;;
        *)
            status "Skipping NVIDIA drivers installation."
            ;;
    esac
}

clone_dotfiles_repo() {
    module_name "Dotfiles Repo"
    status "Cloning dotfiles repository..."
    git clone -b "$DOTFILES_REPO_BRANCH" "$DOTFILES_REPO_URL" "$HOME/.dotfiles" || handle_error "cloning dotfiles" "Check git and URL."
}

move_and_make_executable() {
    module_name "Config Folders"
    status "Deploying configuration files to $CONFIG_DIR..."
    for folder in "$HOME/.dotfiles"/*/; do
        config_name=$(basename "$folder")
        mkdir -p "$CONFIG_DIR/$config_name"
        cp -r "$folder"* "$CONFIG_DIR/$config_name/" || handle_error "copying $config_name files" "Check permissions."
        chmod -R +x "$CONFIG_DIR/$config_name" 2>/dev/null || true

        # Special handling for polybar scripts
        if [[ "$config_name" == "polybar" ]]; then
            [ -d "$CONFIG_DIR/polybar/scripts" ] && chmod -R +x "$CONFIG_DIR/polybar/scripts" || true
        fi
    done

    # Ensure dunst configuration exists
    mkdir -p "$CONFIG_DIR/dunst"
    touch "$CONFIG_DIR/dunst/dunstrc"
    chmod +x "$CONFIG_DIR/dunst/dunstrc" 2>/dev/null || true
}

copy_local_bin() {
    module_name "Local Bin"
    status "Copying local bin scripts to $LOCAL_BIN_DIR..."
    mkdir -p "$LOCAL_BIN_DIR"
    cp -r "$HOME/.dotfiles/local/bin/"* "$LOCAL_BIN_DIR/" || handle_error "copying local bin scripts" "Check permissions."
    chmod +x "$LOCAL_BIN_DIR/"* || true
}

enable_betterlockscreen_service() {
    module_name "Betterlockscreen Service"
    status "Enabling betterlockscreen service for $USER..."
    sudo systemctl enable betterlockscreen@"$USER" || handle_error "enabling betterlockscreen service" "Check systemd permissions."
}

setup_zsh() {
    module_name "Zsh Setup"
    status "Installing Oh My Zsh..."
    # Install Oh My Zsh non-interactively (optional)
    sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" || handle_error "installing Oh My Zsh" "Check internet connection and wget."
    status "Deploying .zshrc from dotfiles..."
    mv "$HOME/.dotfiles/.zshrc" "$HOME/" || handle_error "moving .zshrc" "Check permissions."
    status "Installing Zsh plugins..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" \
        || handle_error "installing zsh-autosuggestions" "Ensure git is installed."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" \
        || handle_error "installing zsh-syntax-highlighting" "Ensure git is installed."
}

copy_xinitrc_file() {
    module_name "Xinitrc"
    status "Copying .xinitrc file..."
    cp "$HOME/.dotfiles/.xinitrc" "$HOME/.xinitrc" || handle_error "copying .xinitrc" "Check permissions."
    chmod +x "$HOME/.xinitrc" || handle_error "making .xinitrc executable" "Check permissions."
}

move_wallpapers_and_set() {
    module_name "Wallpapers"
    status "Deploying wallpapers..."
    mkdir -p "$HOME/Pictures/Wallpapers" || handle_error "creating Wallpapers directory" "Check permissions."
    cp -r "$HOME/.dotfiles/wallpapers/"* "$HOME/Pictures/Wallpapers/" || handle_error "copying wallpapers" "Check permissions."

    status "Setting default wallpaper..."
    if [ -x "$HOME/.local/bin/wallp" ] && [ -f "$HOME/Pictures/Wallpapers/winter.jpg" ]; then
        "$HOME/.local/bin/wallp" "$HOME/Pictures/Wallpapers/winter.jpg" || handle_error "setting wallpaper" "Check wallp script and wallpaper file."
    else
        error "wallp script not found or default wallpaper missing."
    fi
}

cleanup() {
    module_name "Cleanup"
    status "Cleaning up temporary directories..."
    rm -rf "$HOME/yay" "$HOME/NVIDIA" "$HOME/.dotfiles"
}

#######################
# Main Execution Flow
#######################

main() {
    update_mirrors
    create_classic_folders
    install_yay
    install_aur_packages
    install_x_packages
    install_dependencies
    clone_dotfiles_repo
    move_and_make_executable
    copy_local_bin
    enable_betterlockscreen_service
    copy_xinitrc_file
    move_wallpapers_and_set
    install_nvidia_drivers
    # Uncomment the next line if you want to set up zsh and Oh My Zsh
    # setup_zsh

    status "Installation completed successfully!"
    cleanup
}

#######################
# Start Script
#######################

# Display ASCII art header
echo -e "${GREEN}"
cat << "EOF"
███╗   ███╗██╗   ██╗     █████╗ ██████╗  ██████╗██╗  ██╗
████╗ ████║╚██╗ ██╔╝    ██╔══██╗██╔══██╗██╔════╝██║  ██║
██╔████╔██║ ╚████╔╝     ███████║██████╔╝██║     ███████║
██║╚██╔╝██║  ╚██╔╝      ██╔══██║██╔══██╗██║     ██╔══██║
██║ ╚═╝ ██║   ██║       ██║  ██║██║  ██║╚██████╗██║  ██║
╚═╝     ╚═╝   ╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
              THINKPAD T480 EDITION
EOF
echo -e "${NC}"

main
