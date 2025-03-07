#!/bin/bash
# —————————————————————————————————————————————————————————————————————————————————————————————————————
# DBD INSTALLER SCRIPT
# —————————————————————————————————————————————————————————————————————————————————————————————————————
# ANSI Colour Definitions
  CYAN="\033[36m"
  ORANGE="\033[38;5;208m"
  RED="\033[31m"
  GREEN="\033[38;5;82m"
  RC="\033[0m"

# Define paths
  PLUGIN_DIR="$HOME/.oh-my-zsh/custom/plugins/dbd-plugin"
  FONT_DIR="$PLUGIN_DIR/dbd-fonts"
  DBD_PLUGIN_FILE="$PLUGIN_DIR/dbd-plugin.zsh"
  DBD_CONFIG_FILE="$PLUGIN_DIR/dbd-config.zsh"

# Function to Print ASCII art with lolcat
print_header() {
  clear
  echo -e " 
         █ █         █         █              ▀           
     ▄▀▀▀█ █▀▀▀▄ ▄▀▀▀█   ▄▀▀▀▄ █ █   █ ▄▀▀▀▄ ▀█  █▀▀▄     
     █   █ █   █ █   █   █   █ █ █   █ █   █  █  █  █     
     ▀▄▄▄▀ ▀▄▄▄▀ ▀▄▄▄▀   █▄▄▄▀ █ ▀▄▄▄▀ ▀▄▄▄█ ▄█▄ █  █     
                         █              ▄▄▄▀              
          ▀              ▄         █ █                    
         ▀█  █▀▀▄ ▄▀▀▀  ▀█▀▀ ▄▀▀▀▄ █ █ ▄▀▀▀▄ ▀▄▀▀▄        
          █  █  █ ▀▀▀▀▄  █    ▄▄▄█ █ █ █▄▄▄█  █           
         ▄█▄ █  █ ▀▄▄▄▀  ▀▄▄ ▀▄▄▄█ █ █ ▀▄▄▄▄  █           
                                                          
                                                          " | lolcat
}

# Function to print decorative borders
print_border() {
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" | lolcat 
}

# Function to print success borders
print_success_border() {
    echo -e "${GREEN}++++++++++++++++++++++++++++++++++++++++++++++++++++++++++${RC}"
}

# Function to print failed borders
print_failed_border() {
    echo -e "${RED}----------------------------------------------------------${RC}"
}

# Print header
print_header

# Prompt the user to start or quit
print_border
echo -e "${RC}  Press [${CYAN}Enter${RC}] to Start the Installation or [${RED}q${RC}] to Quit"
print_border
read -r user_input

# Check user input
if [[ "$user_input" == "q" ]]; then
    print_header
    print_failed_border
    echo -e "${RED}         ❌ Installation Cancelled. Exiting ... ${RC}"
    print_failed_border
    exit 0
fi

# Update system and install dependencies
print_header
print_border
echo -e "${CYAN}    📥 Updating System and Installing Requirements ${RC}...    "
print_border
sudo apt-get update >/dev/null 2>&1
sudo apt-get install -y git wget figlet lolcat >/dev/null 2>&1

print_header
print_success_border
echo -e "${GREEN}      ✅ System Updated and Dependencies Installed!       ${RC}"
print_success_border

# Ensure plugin directory exists
mkdir -p "$PLUGIN_DIR"
mkdir -p "$FONT_DIR"

# Clone and install fonts
print_header
print_border
echo -e "${CYAN}            📦 Cloning and installing fonts ...           ${RC}"
print_border
git clone https://github.com/DoseOfGose/figlet-fonts.git "$FONT_DIR/doseofgose" >/dev/null 2>&1
git clone https://github.com/jltk/figlet-fonts.git "$FONT_DIR/jltk" >/dev/null 2>&1

# Move all .flf and .tlf files to the main font directory
find "$FONT_DIR" -type f \( -name "*.flf" -o -name "*.tlf" \) -exec mv {} "$FONT_DIR" \;

# Clean up cloned repositories
rm -rf "$FONT_DIR/doseofgose" "$FONT_DIR/jltk"

print_header
print_success_border
echo -e "${GREEN}                    ✅ Fonts Installed                    ${RC}"
print_success_border

# Create dbd-plugin.zsh
cat << 'EOF' > "$DBD_PLUGIN_FILE"
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤ [ DBD System Plugin - Main ] ◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤                         
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# —————————————————————————————————————————————————————————————————————————————————————————————————————
# Paths & Setup
# —————————————————————————————————————————————————————————————————————————————————————————————————————
  PLUGIN_DIR="$ZSH_CUSTOM/plugins/dbd-plugin"
  DBD_CONFIG_FILE="$PLUGIN_DIR/dbd-config.zsh"
  DBD_FONT_DIR="$PLUGIN_DIR/dbd-fonts"
  FIGLET_FONTDIR="${FIGLET_FONTDIR:-${HOME}/.figlet:/usr/share/figlet}"

# Load configuration on plugin load
  if [[ -f "$DBD_CONFIG_FILE" ]]; then
      source "$DBD_CONFIG_FILE"
  else
      echo "⚠️ Missing config file: $DBD_CONFIG_FILE"
  fi
# —————————————————————————————————————————————————————————————————————————————————————————————————————
# Font Loader - Loads the selected font
# —————————————————————————————————————————————————————————————————————————————————————————————————————
load_dbd_font() {
    FONT_PATH="$DBD_FONT_DIR/${DBD_FONT}.flf"

    if [[ ! -f "$FONT_PATH" ]]; then
        echo "⚠️ Font '$DBD_FONT' not found. Falling back to 'Standard'."
        FONT_PATH="$DBD_FONT_DIR/Standard.flf"
        if [[ ! -f "$FONT_PATH" ]]; then
            echo "❌ 'Standard' font missing. Please reinstall fonts."
            return 1
        fi
    fi

    export FIGLET_FONTDIR="$DBD_FONT_DIR"
}

# —————————————————————————————————————————————————————————————————————————————————————————————————————
# Font Selector - User selects font via interactive menu
# —————————————————————————————————————————————————————————————————————————————————————————————————————
dbd-font() {
    fonts=($(ls -1 "$DBD_FONT_DIR" | sed 's/\.flf$//' | sort))
    total_fonts=${#fonts[@]}

    if ((total_fonts == 0)); then
        echo "❌ No fonts found in $DBD_FONT_DIR"
        return 1
    fi

    echo -e "\n📜 Available Fonts:\n"
    cols=4
    for ((i=0; i<total_fonts; i++)); do
        printf "[%02d] %-20s" "$((i+1))" "${fonts[$i]}"
        (( (i+1) % cols == 0 )) && echo ""
    done
    echo -e "\n[00] Quit"

    read -p "Select a font by number: " selection
    if [[ "$selection" == "00" || -z "$selection" ]]; then
        echo "❎ Font selection cancelled."
        return 1
    fi

    if ((selection < 1 || selection > total_fonts)); then
        echo "❌ Invalid selection."
        return 1
    fi

    selected_font="${fonts[$((selection-1))]}"

    # Update config file with selected font
    sed -i "s|^export DBD_FONT=.*|export DBD_FONT=\"$selected_font\"|" "$DBD_CONFIG_FILE"
    echo "✅ Font updated to: $selected_font"

    source "$DBD_CONFIG_FILE"
    echo "✅ Configuration reloaded."
}
# —————————————————————————————————————————————————————————————————————————————————————————————————————
# Font Fetcher
# —————————————————————————————————————————————————————————————————————————————————————————————————————
dbd-ff() {
    local url="$1"
    local font_name

    # Ensure $DBD_FONT_DIR exists
    mkdir -p "$DBD_FONT_DIR"

    if [[ -z "$url" ]]; then
        echo "❌ Please provide a URL to fetch the font."
        return 1
    fi

    # Extract filename (lowerb.flf, etc.)
    font_name=$(basename "$url")

    # Handle GitHub 'blob' links by converting to 'raw'
    if [[ "$url" == *github.com*blob* ]]; then
        url="${url/blob/raw}"
    fi

    # Download the font
    local output_path="$DBD_FONT_DIR/$font_name"
    if wget -q -O "$output_path" "$url"; then
        echo "✅ Font fetched and saved to: $output_path"

        # Strip .flf extension from font name for the config
        font_name="${font_name%.flf}"

        # Update dbd-config.zsh to set this as the new font
        sed -i "s|^export DBD_FONT=.*|export DBD_FONT=\"$font_name\"|" "$HOME/.oh-my-zsh/custom/plugins/dbd-plugin/dbd-config.zsh"
        echo "✅ Default DBD font set to: $font_name"

        # Re-source the plugin to apply immediately
        source "$HOME/.oh-my-zsh/custom/plugins/dbd-plugin/dbd-config.zsh"
        print_dbd_banner
    else
        echo "❌ Failed to fetch font from: $url"
        return 1
    fi
}

# —————————————————————————————————————————————————————————————————————————————————————————————————————
# Config Manager - Opens config for editing & reloads after
# —————————————————————————————————————————————————————————————————————————————————————————————————————
dbd-config() {
    ${EDITOR:-nano} "$DBD_CONFIG_FILE"
    source "$DBD_CONFIG_FILE"
    echo "✅ Config reloaded."
}

# —————————————————————————————————————————————————————————————————————————————————————————————————————
# Banner Printer - Prints banner & directory contents
# —————————————————————————————————————————————————————————————————————————————————————————————————————
print_dbd_banner() {
    if [[ "$DBD_ENABLED" != "true" ]]; then return; fi
    load_dbd_font || return

    clear
    local current_dir=$(basename "$PWD")

    # Random Mode Handling
    if [[ "$DBD_RANDOM_MODE" == "true" ]]; then
        if command -v shuf > /dev/null; then
            DBD_FONT=$(ls "$DBD_FONT_DIR" | shuf -n1 | sed 's/\.flf$//')
            DBD_COLOR=$(echo "cyan red green orange purple blue yellow lolcat" | tr ' ' '\n' | shuf -n1)
        else
            echo "⚠️ 'shuf' not found. Random mode disabled."
        fi
    fi

    # Color Handling
    local color_code=""
    case "$DBD_COLOR" in
        red) color_code='\033[31m' ;;
        green) color_code='\033[32m' ;;
        yellow) color_code='\033[33m' ;;
        blue) color_code='\033[34m' ;;
        purple) color_code='\033[35m' ;;
        cyan) color_code='\033[36m' ;;
        orange) color_code='\033[38;5;208m' ;;
        lolcat) color_code="" ;;  # lolcat handles its own color
        *) color_code='\033[0m' ;;
    esac

    local reset_code='\033[0m'

    # Print the actual banner
    if [[ "$DBD_COLOR" == "lolcat" && -x "$(command -v lolcat)" ]]; then
        figlet -w "$DBD_WIDTH" -f "$DBD_FONT" "$current_dir" | lolcat
    else
        echo -e "${color_code}$(figlet -w "$DBD_WIDTH" -f "$DBD_FONT" "$current_dir")${reset_code}"
    fi

    # Show directory contents
    if ! ls --color=auto; then
        echo "❌ Failed to list directory contents."
    fi
}


# —————————————————————————————————————————————————————————————————————————————————————————————————————
# Hooks & Triggers
# —————————————————————————————————————————————————————————————————————————————————————————————————————
# Manual Banner Trigger
  dbd-show() { print_dbd_banner; }

# Hook to Trigger Banner on Directory Change (cd)
  autoload -U add-zsh-hook
  add-zsh-hook chpwd print_dbd_banner

# Force Initial Banner on Plugin Load (safe timing)
  autoload -Uz add-zsh-hook

# Add hook to run AFTER zsh fully initializes
  add-zsh-hook precmd print_dbd_banner

# —————————————————————————————————————————————————————————————————————————————————————————————————————
EOF

# Create dbd-config.zsh
cat << 'EOF' > "$DBD_CONFIG_FILE"
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤ [ DBD System Plugin Configuration ] ◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤                     
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# --------------------------------------------------------------------------------
# ~/.oh-my-zsh/custom/plugins/dbd-plugin/dbd-config.zsh
# --------------------------------------------------------------------------------
# Plugin Root Directory (automatically set)
  export DBD_PLUGIN_DIR="$HOME/.oh-my-zsh/custom/plugins/dbd-plugin"
# --------------------------------------------------------------------------------
# Font Storage Directory (auto-created when plugin loads)
  export DBD_FONT_DIR="$DBD_PLUGIN_DIR/dbd-fonts"
# --------------------------------------------------------------------------------
# Default font (must match a valid .flf file in $DBD_FONT_DIR)
  export DBD_FONT="lowerb"
# --------------------------------------------------------------------------------
# Banner colors (options: red, green, yellow, blue, purple, cyan, orange, lolcat)
  export DBD_COLOR="lolcat"
# --------------------------------------------------------------------------------
# Banner padding (number of blank lines above/below the banner)
  export DBD_PADDING="2"
# --------------------------------------------------------------------------------
# Random Font Mode (true = randomly picks font on each directory change)
  export DBD_RANDOM_FONT="false"
# --------------------------------------------------------------------------------
# Random Color Mode (true = randomly picks colors on each directory change)
  export DBD_RANDOM_COLOR="false"
# --------------------------------------------------------------------------------
# Master switch (true = plugin enabled, false = plugin does nothing)
  export DBD_ENABLED="true"
# --------------------------------------------------------------------------------
# Banner width (controls figlet width for better fitting in terminal)
  export DBD_WIDTH="80"
# --------------------------------------------------------------------------------
# Ensure Font Directory Exists (so plugin never breaks on first run)
  mkdir -p "$DBD_FONT_DIR"
# --------------------------------------------------------------------------------
EOF

# Clear and print the header for the "Adding DBD Plugin" step
print_header
print_border
echo -e "${CYAN}           🔧 Adding DBD Plugin to .zshrc... ${RC}"
print_border

# Add Plugin to .zshrc
SOURCE_LINE='source $ZSH_CUSTOM/plugins/dbd-plugin/dbd-plugin.zsh'

# Check if the source line already exists
if ! grep -qF "$SOURCE_LINE" "$HOME/.zshrc"; then
    # Check if the plugins=() block exists
    if grep -q '^plugins=(' "$HOME/.zshrc"; then
        # Insert the source line directly after the plugins=() block
        sed -i "/^plugins=(/a $SOURCE_LINE" "$HOME/.zshrc"
    else
        # Fallback: Append the source line to the end of the file
        echo "$SOURCE_LINE" >> "$HOME/.zshrc"
    fi

    # Clear and print the header again for the "Added Successfully" step
    print_header
    print_success_border
    echo -e "${GREEN}           ✅ DBD Plugin Added to .zshrc.             ${RC}"
    print_success_border
else
    # Clear and print the header again for the "Already Exists" step
    print_header
    print_failed_border
    echo -e "${ORANGE}         ⚠️ DBD Plugin is Already in .zshrc           ${RC}"
    print_failed_border
fi

# Clear and print the header again for the final completion message
print_header
print_border
echo -e "${GREEN}                ✅ Installation Complete!                  ${RC}"
echo -e "     The DBD Plugin Has Been Installed and Configured              ${RC}"
echo -e "      The terminal will now restart to apply changes               ${RC}"
print_border

# Sleep for 3 seconds to allow the user to read the message
sleep 3

# Detect the current terminal emulator
CURRENT_TERMINAL=$(ps -o comm= -p "$(($(ps -o ppid= -p "$(($(ps -o sid= -p "$$")))")))")

# Restart the detected terminal emulator
case "$CURRENT_TERMINAL" in
    gnome-terminal)
        gnome-terminal &
        ;;
    konsole)
        konsole &
        ;;
    xterm)
        xterm &
        ;;
    xfce4-terminal)
        xfce4-terminal &
        ;;
    alacritty)
        alacritty &
        ;;
    kitty)
        kitty &
        ;;
    mate-terminal)
        mate-terminal &
        ;;
    lxterminal)
        lxterminal &
        ;;
    *)
        echo -e "${RED}Unable to detect the current terminal emulator. Please restart your terminal manually.${RC}"
        exit 1
        ;;
esac

# Exit the script
exit 0
# —————————————————————————————————————————————————————————————————————————————————————————————————————
