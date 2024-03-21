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
DEPENDENCIES=("bspwm" "kitty" "neofetch" "picom" "polybar" "rofi" "sxhkd" "feh" "playerctl" "dunst" "scrot" "libnotify" "wget" "zsh" "pulseaudio" "python-pywal")
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

# Trap Ctrl+C and call cleanup function
trap ctrl_c INT

# Function to handle Ctrl+C
ctrl_c() {
    echo "Ctrl+C pressed. Exiting..."
    cleanup
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
    makepkg -si --noconfirm || handle_error "installing yay" "Ensure you have necessary build tools installed."
}

# Function to install packages using yay
install_aur_packages() {
    module_name "AUR Packages"
    status "Installing AUR packages..."
    yay -S --noconfirm ${AUR_PACKAGES[@]} || handle_error "installing AUR packages" "Ensure yay is installed." "install_yay"
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
    read -p "Do you want to install NVIDIA drivers? (y/n): " install_nvidia
    case $install_nvidia in
        y|Y)
            sudo pacman -S --noconfirm linux-headers || handle_error "installing linux-headers" "Ensure you have necessary permissions."
            git clone $NVIDIA_DRIVERS_REPO_URL "$HOME/NVIDIA" || handle_error "installing NVIDIA drivers" "Ensure git is installed."
            cd "$HOME/NVIDIA" || exit
            makepkg -si || handle_error "installing NVIDIA drivers" "Ensure you have necessary build tools installed." ;;
        *)
            echo "Skipping NVIDIA drivers installation." ;;
    esac
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
        cp -r "$folder"/* "$CONFIG_DIR/$config_name/" || handle_error "copying files" "Ensure you have necessary permissions."
        chmod +x "$CONFIG_DIR/$config_name"/* || handle_error "making files executable" "Ensure you have necessary permissions."
    done

    # Create dunstrc
    mkdir "$CONFIG_DIR/dunst/"
    touch "$CONFIG_DIR/dunst/dunstrc"
    chmod +x "$CONFIG_DIR/dunst/dunstrc" || handle_error "making file executable" "Ensure you have necessary permissions."

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
    sudo systemctl enable betterlockscreen@$USER || handle_error "enabling betterlockscreen service" "Ensure you have necessary permissions."
}

# Function to install Oh My Zsh
setup_zsh() {
    module_name "Zsh Configuration"
    status "Installing Oh My Zsh..."
    sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" || handle_error "installing Oh My Zsh" "Ensure curl is installed and internet connection is available."
    status "Moving .zshrc to $CONFIG_DIR..."
    mv ~/.dotfiles/.zshrc "$CONFIG_DIR/" || handle_error "moving .zshrc file" "Ensure you have necessary permissions." 
    status "Installing Zsh autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || handle_error "installing Zsh autosuggestions plugin" "Ensure git is installed." 
    status "Installing Zsh syntax highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || handle_error "installing Zsh syntax highlighting plugin" "Ensure git is installed."
}

# Function to copy .xinitrc file from the repo
copy_xinitrc_file() {
    module_name "Xinitrc File"
    status "Copying .xinitrc file from the repository..."
    cp ~/.dotfiles/.xinitrc ~/.xinitrc || handle_error "copying .xinitrc file" "Ensure you have necessary permissions."
    chmod +x ~/.xinitrc || handle_error "copying .xinitrc file" "Ensure you have necessary permissions."
}


# Function to move wallpapers and set a wallpaper
move_wallpapers_and_set() {
    module_name "Wallpapers"
    status "Moving wallpapers to $HOME/Pictures/Wallpapers..."
    mkdir -p "$HOME/Pictures/Wallpapers" || handle_error "creating Wallpapers directory" "Ensure you have necessary permissions." 
    mv ~/.dotfiles/wallpapers/* "$HOME/Pictures/Wallpapers/" || handle_error "moving wallpapers" "Ensure you have necessary permissions." 

    status "Setting wallpaper..."
    ~/.local/bin/wallp "$HOME/Pictures/Wallpapers/winter.jpg" || handle_error "setting wallpaper" "Ensure wallp script is installed and the wallpaper file exists." 
}


# Function to clean up temporary directories and files
cleanup() {
    module_name "Cleanup"
    status "Cleaning up temporary directories and files..."
    rm -rf "$HOME/yay" "$HOME/NVIDIA" "$HOME/.dotfiles" # Add more directories to clean up as needed
}

# Main function
main() {
    create_classic_folders
    install_yay
    install_aur_packages
    install_x_packages
    install_dependencies
    clone_repo
    move_and_make_executable
    copy_local_bin
    enable_betterlockscreen_service
    copy_xinitrc_file
    move_wallpapers_and_set
    install_nvidia_drivers
    #setup_zsh



    echo -e "${GREEN}Dotfiles installation completed!${NC}"

    # Perform cleanup
    cleanup
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
