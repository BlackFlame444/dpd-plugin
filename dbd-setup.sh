#!/bin/bash
# dbd-setup.sh - Full installer for DBD System Plugin (rewritten)

PLUGIN_DIR="$HOME/.oh-my-zsh/custom/plugins/dbd-plugin"
FONT_DIR="$PLUGIN_DIR/dbd-fonts/export"
CONFIG_FILE="$PLUGIN_DIR/dbd-config.zsh"
FUNCTIONS_FILE="$PLUGIN_DIR/dbd-functions.zsh"
PLUGIN_FILE="$PLUGIN_DIR/dbd-plugin.zsh"
CLI_FILE="$PLUGIN_DIR/dbd-cli.zsh"
DEFAULT_FONT="lowerb"

# Create necessary directories
mkdir -p "$PLUGIN_DIR"
mkdir -p "$FONT_DIR"

# Install dependencies
echo -e "\nInstalling dependencies..."
sudo apt-get update
sudo apt-get install -y figlet lolcat toilet otf2bdf bdf2psf git
clear

# Clone and extract fonts
echo -e "\nDownloading and installing figlet fonts..."
FONT_REPOS=(
    "https://github.com/DoseOfGose/figlet-fonts.git"
    "https://github.com/jltk/figlet-fonts.git"
)

for repo in "${FONT_REPOS[@]}"; do
    tmp_dir=$(mktemp -d)
    git clone "$repo" "$tmp_dir"
    find "$tmp_dir" -type f -name "*.flf" -exec cp {} "$FONT_DIR/" \;
    rm -rf "$tmp_dir"
    clear
done

# Confirm the default font exists
if [[ ! -f "$FONT_DIR/$DEFAULT_FONT.flf" ]]; then
    echo -e "\n⚠️  Default font '$DEFAULT_FONT' not found. Falling back to 'Standard'."
    DEFAULT_FONT="Standard"
fi

# Create config file if missing
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" <<EOF
# DBD System Plugin Configuration
DBD_FONT="$DEFAULT_FONT"
DBD_COLOR="red"
DBD_RANDOM_MODE="false"
DBD_ENABLED="true"
DBD_WIDTH="80"
DBD_FONT_DIR="$FONT_DIR"
EOF
fi

# Create plugin file
cat > "$PLUGIN_FILE" <<'EOF'
source ~/.oh-my-zsh/custom/plugins/dbd-plugin/dbd-functions.zsh
source ~/.oh-my-zsh/custom/plugins/dbd-plugin/dbd-config.zsh

autoload -U add-zsh-hook

# Font Loader (called directly within banner logic)
load_dbd_font() {
    FONT_PATH="$HOME/.dbd-plugin/dbd-fonts/export/${DBD_FONT}.flf"
    if [[ ! -f "$FONT_PATH" ]]; then
        echo "⚠️ Font not found: $FONT_PATH. Falling back to 'Standard'."
        FONT_PATH="$HOME/.dbd-plugin/dbd-fonts/export/Standard.flf"
        if [[ ! -f "$FONT_PATH" ]]; then
            echo "❌ Default font 'Standard' not found. Please install a font."
            return 1
        fi
    fi
    export FIGLET_FONTDIR="$HOME/.oh-my-zsh/custom/plugins/dbd-plugin/dbd-fonts/export"
}

print_dbd_banner() {
    if [[ "$DBD_ENABLED" != "true" ]]; then return; fi
    load_dbd_font || return

    clear

    local dir_name=$(basename "$PWD")

    # Apply Random Mode if enabled
    if [[ "$DBD_RANDOM_MODE" == "true" ]]; then
        DBD_FONT=$(ls ~/dbd-plugin/dbd-fonts/export | shuf -n1 | sed 's/\.flf$//')
        DBD_COLOR=$(echo "cyan red green orange purple blue yellow lolcat" | tr ' ' '\n' | shuf -n1)
    fi

    # Print banner
    if command -v lolcat &>/dev/null; then
        figlet -w $DBD_WIDTH -f "$FONT_PATH" "$dir_name" | lolcat
    else
        figlet -w $DBD_WIDTH -f "$FONT_PATH" "$dir_name"
    fi
    echo ""
    ls --color=auto
}
# Directory Change Hook
add-zsh-hook chpwd print_dbd_banner

# First-run banner (optional welcome)
if [[ ! -f "$HOME/.oh-my-zsh/custom/plugins/dbd-plugin/.first-run" ]]; then
    touch "$HOME/.oh-my-zsh/custom/plugins/dbd-plugin/.first-run"
    clear
    echo "Welcome to the DBD System Plugin" | figlet -w $DBD_WIDTH -f "$FONT_PATH" | eval "$DBD_COLOR"
    sleep 2
fi

# Manual Trigger Command (optional helper)
dbd-show() {
    print_dbd_banner
}

# Config Manager Command
dbd-config() {
    source ~/.oh-my-zsh/custom/plugins/dbd-plugin/dbd-functions.zsh
    dbd-config
}

# Font Converter Helper
dbd-font() {
    source ~/.oh-my-zsh/custom/plugins/dbd-plugin/dbd-functions.zsh
    dbd-font "$@"
}

# List Available Fonts
dbd-list-fonts() {
    echo "Available DBD Fonts:"
    ls -1 "$DBD_FONT_DIR" | sed 's/\.flf$//'
}

# Initial banner (for first directory shell opens in)
print_dbd_banner
EOF

# Create functions file
cat > "$FUNCTIONS_FILE" <<'EOF'
# ~/.oh-my-zsh/custom/plugins/dbd-plugin/dbd-functions.zsh
# Font Converter (TTF/OTF -> FLF for figlet/DBD)
dbd-font() {
    local font_path="$1"
    local font_name=$(basename "$font_path" | sed 's/\.[^.]*$//')

    if [[ ! -f "$font_path" ]]; then
        echo "❌ Font file not found: $font_path"
        return 1
    fi

    local output_path="$DBD_FONT_DIR/${font_name}.flf"

    mkdir -p "$DBD_FONT_DIR"

    echo "Converting $font_name to figlet format..."
    if command -v otf2bdf &>/dev/null && command -v bdf2psf &>/dev/null; then
        # Convert OTF/TTF to BDF (assuming otf2bdf can handle either)
        tmp_bdf="/tmp/${font_name}.bdf"
        otf2bdf -p 20 "$font_path" -o "$tmp_bdf"

        # Convert BDF to FLF using bdf2psf (aliasing into figlet)
        bdf2psf --fb $tmp_bdf > "$output_path"

        rm -f "$tmp_bdf"

        echo "✅ Font converted and stored at: $output_path"
    else
        echo "❌ Missing converters (otf2bdf or bdf2psf). Install required tools."
        echo "On Debian/Ubuntu, you can install them with:"
        echo "sudo apt-get install otf2bdf bdf2psf"
        return 1
    fi

    # Ask if they want to set it as default
    read -p "Set ${font_name} as your default DBD font? (y/N): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        sed -i "s|^export DBD_FONT=.*|export DBD_FONT=\"$font_name\"|" ~/.oh-my-zsh/custom/plugins/dbd-plugin/dbd-config.zsh
        echo "✅ Default font updated to $font_name"
    fi
}

# Config Manager (simple editor loader)
dbd-config() {
    local config_file="$HOME/.oh-my-zsh/custom/plugins/dbd-plugin/dbd-config.zsh"

    echo "Opening DBD config file..."
    ${EDITOR:-nano} "$config_file"
    source "$config_file"
    echo "✅ Config reloaded."
}

# Optional Helper - List Available Fonts
dbd-list-fonts() {
    echo "Available DBD Fonts:"
    ls -1 "$DBD_FONT_DIR" | sed 's/\.flf$//'
}
EOF

# Create CLI file
cat > "$CLI_FILE" <<'EOF'
# ~/.oh-my-zsh/custom/plugins/dbd-plugin/dbd-cli.zsh

# CLI Commands for DBD Plugin
dbd-config() {
    case "$1" in
        enable) sed -i 's/DBD_ENABLED=.*/DBD_ENABLED=true/' "$CONFIG_FILE" ;;
        disable) sed -i 's/DBD_ENABLED=.*/DBD_ENABLED=false/' "$CONFIG_FILE" ;;
        random) shift; if [[ "$1" == "enable" ]]; then sed -i 's/DBD_RANDOM_MODE=.*/DBD_RANDOM_MODE=true/' "$CONFIG_FILE"; else sed -i 's/DBD_RANDOM_MODE=.*/DBD_RANDOM_MODE=false/' "$CONFIG_FILE"; fi ;;
        font) shift; sed -i "s|DBD_FONT=.*|DBD_FONT=\"$1\"|" "$CONFIG_FILE" ;;
        color) shift; sed -i "s|DBD_COLOR=.*|DBD_COLOR=\"$1\"|" "$CONFIG_FILE" ;;
        width) shift; sed -i "s|DBD_WIDTH=.*|DBD_WIDTH=$1|" "$CONFIG_FILE" ;;
        show) cat "$CONFIG_FILE" ;;
        *) echo "Usage: dbd-config {enable|disable|random enable|random disable|font FONTNAME|color COLOR|width WIDTH|show}" ;;
    esac
}
EOF

# Add to .zshrc if missing
if ! grep -q 'source ~/.oh-my-zsh/custom/plugins/dbd-plugin/dbd-plugin.zsh' "$HOME/.zshrc"; then
    echo 'source ~/.oh-my-zsh/custom/plugins/dbd-plugin/dbd-plugin.zsh' >> "$HOME/.zshrc"
fi

# Finish message
echo -e "\n\033[1;36mDBD System Plugin Installed Successfully!\033[0m"
echo -e "\n\033[1;33mWould you like to restart your terminal now?\033[0m"
read -p "(y/N): " choice

if [[ "$choice" =~ ^[Yy]$ ]]; then
    source ~/.zshrc
    xfce4-terminal &
    exit
else
    echo -e "\n\033[1;32mYou can manually restart your terminal later.\033[0m"
    echo "Just run: source ~/.zshrc"
fi
