#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print with color
print_message() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
    echo -e "${RED}[-]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check for dry-run flag
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    print_warning "Running in DRY-RUN mode - no changes will be made"
fi

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please don't run as root"
    exit 1
fi

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_DIR="$HOME/.config"

# Arrays to store results
MISSING_DIRS=()
EXISTING_DIRS=()
NEW_DIRS=()
BACKUP_DIRS=()

# Function to check if a package is installed
is_package_installed() {
    pacman -Qi "$1" &>/dev/null
    return $?
}

# Function to install a package if not already installed
install_package() {
    local package="$1"
    if ! is_package_installed "$package"; then
        if [ "$DRY_RUN" = true ]; then
            print_message "Would install $package..."
        else
            print_message "Installing $package..."
            sudo pacman -S --noconfirm "$package"
        fi
    else
        print_message "$package is already installed"
    fi
}

# Function to detect NVIDIA GPU
detect_nvidia() {
    if lspci | grep -i "nvidia" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to setup NVIDIA drivers
setup_nvidia() {
    print_message "Setting up NVIDIA drivers..."
    
    # Install NVIDIA packages
    local nvidia_packages=(
        "nvidia"
        "nvidia-utils"
        "nvidia-settings"
        "lib32-nvidia-utils"
        "nvidia-dkms"
        "libva-nvidia-driver-git"
    )
    
    for package in "${nvidia_packages[@]}"; do
        install_package "$package"
    done
    
    print_success "NVIDIA drivers installed"
}

# Function to setup basic system packages
setup_system_packages() {
    print_message "Setting up basic system packages..."
    
    local system_packages=(
        "base-devel"
        "git"
        "curl"
        "wget"
        "unzip"
        "htop"
        "btop"
        "neofetch"
    )
    
    for package in "${system_packages[@]}"; do
        install_package "$package"
    done
}

# Function to setup audio packages
setup_audio() {
    print_message "Setting up audio packages..."
    
    local audio_packages=(
        "pulseaudio"
        "pulseaudio-alsa"
        "pavucontrol"
        "easyeffects"
        "cava"
    )
    
    for package in "${audio_packages[@]}"; do
        install_package "$package"
    done
}

# Function to setup Hyprland and related packages
setup_hyprland() {
    print_message "Setting up Hyprland and related packages..."
    
    local hyprland_packages=(
        "hyprland"
        "waybar"
        "dunst"
        "rofi"
        "wlogout"
        "kitty"
        "foot"
        "fish"
        "zathura"
        "gtk3"
        "gtk4"
        "xsettingsd"
        "pywal"
    )
    
    for package in "${hyprland_packages[@]}"; do
        install_package "$package"
    done
}

# Function to create backup of existing config
backup_config() {
    local config_path="$1"
    if [ -e "$config_path" ] && [ ! -L "$config_path" ]; then
        if [ "$DRY_RUN" = true ]; then
            print_message "Would backup $config_path to ${config_path}.backup"
        else
            print_message "Backing up $config_path to ${config_path}.backup"
            mv "$config_path" "${config_path}.backup"
        fi
        BACKUP_DIRS+=("$config_path")
    fi
}

# Function to create symbolic link
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Remove existing symlink if it exists
    if [ -L "$target" ]; then
        if [ "$DRY_RUN" = true ]; then
            print_message "Would remove existing symlink: $target"
        else
            rm "$target"
        fi
    fi
    
    # Create new symlink
    if [ "$DRY_RUN" = true ]; then
        print_message "Would create symlink: $target -> $source"
    else
        ln -s "$source" "$target"
        print_success "Created symlink: $target -> $source"
    fi
}

# Function to check if a directory exists in dotfiles
check_source_dir() {
    local dir="$1"
    if [ ! -d "$DOTFILES_DIR/$dir" ]; then
        print_error "Directory $dir not found in dotfiles"
        MISSING_DIRS+=("$dir")
        return 1
    fi
    return 0
}

# Function to check if a target directory exists
check_target_dir() {
    local dir="$1"
    if [ -e "$CONFIG_DIR/$dir" ]; then
        if [ -L "$CONFIG_DIR/$dir" ]; then
            print_warning "Symlink already exists: $CONFIG_DIR/$dir"
        else
            print_warning "Directory already exists: $CONFIG_DIR/$dir"
        fi
        EXISTING_DIRS+=("$dir")
    else
        NEW_DIRS+=("$dir")
    fi
}

# Main installation process
print_message "Starting dotfiles installation..."

# Create .config directory if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
    if [ "$DRY_RUN" = true ]; then
        print_message "Would create $CONFIG_DIR directory..."
    else
        print_message "Creating $CONFIG_DIR directory..."
        mkdir -p "$CONFIG_DIR"
    fi
fi

# List of directories to link
DIRS=(
    "btop"
    "cava"
    "dunst"
    "easyeffects"
    "fish"
    "foot"
    "gtk-3.0"
    "gtk-4.0"
    "hypr"
    "kitty"
    "neofetch"
    "nvim"
    "pulse"
    "rofi"
    "tofi"
    "wal"
    "waybar"
    "wlogout"
    "xsettingsd"
    "zathura"
)

# Create symbolic links for each directory
for dir in "${DIRS[@]}"; do
    print_message "\nChecking $dir..."
    if check_source_dir "$dir"; then
        check_target_dir "$dir"
        if [ "$DRY_RUN" = false ]; then
            backup_config "$CONFIG_DIR/$dir"
            create_symlink "$DOTFILES_DIR/$dir" "$CONFIG_DIR/$dir"
        fi
    fi
done

# Setup system packages and drivers
print_message "\n=== Setting up system packages and drivers ==="

# Setup basic system packages
setup_system_packages

# Setup audio
setup_audio

# Setup Hyprland and related packages
setup_hyprland

# Check for NVIDIA and setup if found
if detect_nvidia; then
    print_message "NVIDIA GPU detected"
    setup_nvidia
else
    print_message "No NVIDIA GPU detected"
fi

# Print summary
print_message "\n=== Installation Summary ==="
if [ ${#MISSING_DIRS[@]} -gt 0 ]; then
    print_error "\nMissing directories in dotfiles:"
    printf '%s\n' "${MISSING_DIRS[@]}"
fi

if [ ${#EXISTING_DIRS[@]} -gt 0 ]; then
    print_warning "\nExisting configurations that will be backed up:"
    printf '%s\n' "${EXISTING_DIRS[@]}"
fi

if [ ${#NEW_DIRS[@]} -gt 0 ]; then
    print_message "\nNew configurations to be created:"
    printf '%s\n' "${NEW_DIRS[@]}"
fi

if [ ${#BACKUP_DIRS[@]} -gt 0 ]; then
    print_warning "\nConfigurations that will be backed up:"
    printf '%s\n' "${BACKUP_DIRS[@]}"
fi

if [ "$DRY_RUN" = true ]; then
    print_warning "\nThis was a dry run. No changes were made."
    print_message "To actually install the dotfiles, run: ./install.sh"
else
    print_success "\nDotfiles installation completed!"
    print_message "Please restart your shell or log out and log back in for changes to take effect."
fi 