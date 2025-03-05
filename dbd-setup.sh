#!/bin/bash
# dbd-setup.sh - Complete setup script for DBD System Plugin

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

# Install dependencies (figlet, lolcat, toilet, font converters)
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y figlet lolcat toilet otf2bdf bdf2psf git

# Download and install figlet fonts from repositories
echo "Downloading and installing figlet fonts..."
FONT_REPOS=(
    "https://github.com/DoseOfGose/figlet-fonts.git"
    "https://github.com/jltk/figlet-fonts.git"
)

for repo in "${FONT_REPOS[@]}"; do
    repo_name=$(basename "$repo" .git)
    git clone "$repo" "$PLUGIN_DIR/$repo_name"
    
    # Find and copy all .flf files to the font directory
    find "$PLUGIN_DIR/$repo_name" -type f -name "*.flf" -exec cp {} "$FONT_DIR/" \;
    
    rm -rf "$PLUGIN_DIR/$repo_name"
done


# Set the default font
if [[ -f "$FONT_DIR/$DEFAULT_FONT.flf" ]]; then
    echo "Setting default font to $DEFAULT_FONT..."
else
    echo "⚠️ Default font $DEFAULT_FONT not found. Please ensure it is installed."
    DEFAULT_FONT="Standard"  # Fallback font
fi

# Create the configuration file if missing
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" <<EOF
# DBD System Plugin Configuration

DBD_FONT="$DEFAULT_FONT"  # Default figlet font
DBD_COLOR="cyan"     # Default color
DBD_RANDOM_MODE="false"  # off = static banner, font & color. on = random on every 'cd'
DBD_ENABLED="true"   # Enable or disable the plugin
DBD_WIDTH="80"       # Default width for the banner
DBD_FONT_DIR="$PLUGIN_DIR/dbd-fonts/export"
EOF
fi

# Create dbd-plugin.zsh script
cat > "$PLUGIN_FILE" <<'EOF'
# ~/.dbd-plugin/dbd-plugin.zsh
source ~/.dbd-plugin/dbd-functions.zsh
source ~/.dbd-plugin/dbd-config.zsh

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
    export FIGLET_FONTDIR="$HOME/.dbd-plugin/dbd-fonts/export"
}

# Banner Printer
print_dbd_banner() {
    if [[ "$DBD_ENABLED" != "true" ]]; then return; fi
    load_dbd_font || return

    clear

    local dir_name=$(basename "$PWD")

    # Apply Random Mode if enabled
    if [[ "$DBD_RANDOM_MODE" == "true" ]]; then
        DBD_FONT=$(ls ~/.dbd-plugin/dbd-fonts/export | shuf -n1 | sed 's/\.flf$//')
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
if [[ ! -f "$HOME/.dbd-plugin/.first-run" ]]; then
    touch "$HOME/.dbd-plugin/.first-run"
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
    source ~/.dbd-plugin/dbd-functions.zsh
    dbd-config
}

# Font Converter Helper
dbd-font() {
    source ~/.dbd-plugin/dbd-functions.zsh
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

# Create dbd-functions.zsh script
cat > "$FUNCTIONS_FILE" <<'EOF'
# ~/.dbd-plugin/dbd-functions.zsh - DBD System Plugin Functions

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
        sed -i "s|^export DBD_FONT=.*|export DBD_FONT=\"$font_name\"|" ~/.dbd-plugin/dbd-config.zsh
        echo "✅ Default font updated to $font_name"
    fi
}

# Config Manager (simple editor loader)
dbd-config() {
    local config_file="$HOME/.dbd-plugin/dbd-config.zsh"

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

# Create dbd-cli.zsh script
cat > "$CLI_FILE" <<'EOF'
#!/bin/bash
# dbd-cli.zsh - Command-line interface for DBD System Plugin

print_dbd_banner() {
    ~/.dbd-plugin/dbd-plugin.zsh
}

print_dbd_banner
EOF

# Add sourcing to ~/.zshrc if missing
if ! grep -q 'source ~/.dbd-plugin/dbd-plugin.zsh' "$HOME/.zshrc"; then
    echo 'source ~/.dbd-plugin/dbd-plugin.zsh' >> "$HOME/.zshrc"
    echo "DBD System Plugin added to .zshrc. Please restart your shell."
else
    echo "DBD System Plugin already present in .zshrc."
fi

# Reload and Reboot Terminal or Skip
echo ""
echo -e "\e[1;36mDBD System Plugin installation completed!\e[0m"
echo ""
echo -e "\e[1;32mPress Enter to reload shell and reboot terminal now.\e[0m"
echo -e "\e[1;33mOr press 's' to skip (you can reload manually later).\e[0m"
read -n1 -p "> " choice
echo ""

if [[ "$choice" == "s" || "$choice" == "S" ]]; then
    echo -e "\e[1;33mSkipping shell reload and reboot.\e[0m"
    echo -e "\e[1;34mYou can manually reload later by running:\e[0m"
    echo -e "    \e[1;32msource ~/.zshrc\e[0m"
else
    echo -e "\e[1;32mReloading shell and rebooting terminal...\e[0m"
    sleep 0.5
    source ~/.zshrc

    # Attempt to detect the terminal emulator
    if [[ -z "$TERMINAL_EMULATOR" ]]; then
        # Attempt to detect based on $TERM if TERMINAL_EMULATOR is not set
        if [[ -n "$TERM" ]]; then
            case "$TERM" in
                *xterm*)
                    TERMINAL_EMULATOR="xterm"
                    ;;
                *gnome*)
                    TERMINAL_EMULATOR="gnome-terminal"
                    ;;
                *konsole*)
                    TERMINAL_EMULATOR="konsole"
                    ;;
                *xfce*)
                    TERMINAL_EMULATOR="xfce4-terminal"
                    ;;
                *qterminal*)
                    TERMINAL_EMULATOR="qterminal"
                    ;;
                *)
                    TERMINAL_EMULATOR="unknown"
                    ;;
            esac
        fi
    fi

# Inform the user about the detected terminal emulator
echo "Detected terminal emulator: $TERMINAL_EMULATOR"

# If the terminal emulator is not recognized, fall back to the default shell
if [[ "$TERMINAL_EMULATOR" == "unknown" ]]; then
        echo -e "\e[1;31mUnknown terminal emulator, falling back to generic shell command...\e[0m"
        (sleep 0.5 && $SHELL) & disown
    else
        # Proceed with terminal-specific actions
        case "$TERMINAL_EMULATOR" in
            "qterminal")
                echo -e "\e[1;33mClosing the current terminal and opening a new qterminal...\e[0m"
                exit
                qterminal & disown
                ;;
            "xfce4-terminal")
                echo -e "\e[1;33mClosing the current terminal and opening a new xfce4-terminal...\e[0m"
                exit
                xfce4-terminal & disown
                ;;
            "gnome-terminal")
                echo -e "\e[1;33mClosing the current terminal and opening a new gnome-terminal...\e[0m"
                exit
                gnome-terminal & disown
                ;;
            "konsole")
                echo -e "\e[1;33mClosing the current terminal and opening a new konsole...\e[0m"
                exit
                konsole & disown
                ;;
            *)
                echo -e "\e[1;31mUnknown terminal emulator: $TERMINAL_EMULATOR\e[0m"
                echo -e "\e[1;33mFalling back to default shell: (sleep 0.5 && $SHELL)\e[0m"
                (sleep 0.5 && $SHELL) & disown
                ;;
        esac
    fi
fi

