# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢ [ DBD System Plugin - Main ] ◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# ———————————————————————————————————————
# ◢◤◢◤◢◤◢◤ [Paths & Setup] ◢◤◢◤◢◤◢◤
# ———————————————————————————————————————
  ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
  PLUGIN_DIR="$ZSH_CUSTOM/plugins/dbd-plugin"
  DBD_CONFIG_FILE="$PLUGIN_DIR/dbd-config.zsh"
  DBD_FONT_DIR="/usr/local/lib/node_modules/figlet/fonts"

# Load configuration on plugin load
  if [[ -f "$DBD_CONFIG_FILE" ]]; then
      source "$DBD_CONFIG_FILE"
  else
      echo "⚠️ Missing config file: $DBD_CONFIG_FILE"
  fi

# ——————————————————————————————————————————————————————————————
# ◢◤◢◤◢◤◢◤ [Font Loader - Loads the selected font] ◢◤◢◤◢◤◢◤
# ——————————————————————————————————————————————————————————————
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

# ———————————————————————————————————————————————————————————————————————————————
# ◢◤◢◤◢◤◢◤ [Font Selector - User selects font via interactive menu] ◢◤◢◤◢◤◢◤
# ———————————————————————————————————————————————————————————————————————————————
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

# —————————————————————————————————————
# ◢◤◢◤◢◤◢◤ [Font Fetcher] ◢◤◢◤◢◤◢◤
# —————————————————————————————————————
dbd-ff() {
    local url="$1"
    local font_name=""
    local font_ext=""
    local temp_dir=""
    local config_file="$HOME/.oh-my-zsh/custom/plugins/dbd-plugin/dbd-config.zsh"

    # Ensure $DBD_FONT_DIR exists
    mkdir -p "$DBD_FONT_DIR"

    if [[ -z "$url" ]]; then
        echo "❌ Please provide a URL to fetch the font."
        return 1
    fi
    
    # Handle GitHub 'blob' links (convert to raw)
    if [[ "$url" == *github.com*blob* ]]; then
        url="${url/blob/raw}"
    fi
    
    # Case 1 — Full Git Repository (clone all fonts)
    if [[ "$url" =~ \.git$ ]]; then
        temp_dir=$(mktemp -d)

        if ! git clone --depth=1 "$url" "$temp_dir" >/dev/null 2>&1; then
            echo "❌ Failed to clone repository: $url"
            rm -rf "$temp_dir"
            return 1
        fi

        # Find first valid font and copy all valid fonts to $DBD_FONT_DIR
        local first_font=""

        for font_file in "$temp_dir"/*.{flf,fig,tlf}(N); do
            if [[ -f "$font_file" ]]; then
                font_name=$(basename "$font_file")
                cp "$font_file" "$DBD_FONT_DIR/$font_name"

                # Set first font found as the active font
                if [[ -z "$first_font" ]]; then
                    first_font="${font_name%.*}"
                fi
            fi
        done

        rm -rf "$temp_dir"

        if [[ -z "$first_font" ]]; then
            echo "❌ No valid fonts found in repository: $url"
            return 1
        fi
        
        # Update DBD_FONT in config
        sed -i "s|^  export DBD_FONT=.*|  export DBD_FONT=\"$first_font\"|" "$config_file"
        echo "✅ Default DBD font set to: $first_font"

        # Reload shell (full refresh)
        source ~/.zshrc
        return 0
    fi
    
    # Case 2 — Direct Font File Download (.flf, .fig, .tlf)
    font_name=$(basename "$url")
    font_ext="${font_name##*.}"

    if [[ ! "$font_ext" =~ ^(flf|fig|tlf)$ ]]; then
        echo "❌ Unsupported file type: $font_name"
        return 1
    fi

    # Download the font into $DBD_FONT_DIR
    local output_path="$DBD_FONT_DIR/$font_name"

    if wget -q -O "$output_path" "$url"; then
        echo "✅ Font fetched and saved to: $output_path"

        local base_font_name="${font_name%.*}"

        # Update DBD_FONT in config
        sed -i "s|^  export DBD_FONT=.*|  export DBD_FONT=\"$base_font_name\"|" "$config_file"
        echo "✅ Default DBD font set to: $base_font_name"

        # Reload shell (full refresh)
        source ~/.zshrc
        return 0
    else
        echo "❌ Failed to fetch font from: $url"
        return 1
    fi
}

# ——————————————————————————————————————————————————————————————————————————————————
# ◢◤◢◤◢◤◢◤ [Config Manager - Opens config for editing & reloads after] ◢◤◢◤◢◤◢◤
# ——————————————————————————————————————————————————————————————————————————————————
dbd-config() {
    ${EDITOR:-nano} "$DBD_CONFIG_FILE"
    source ~/.zshrc
    echo "✅ Config reloaded."
}

# ————————————————————————————————————————————
# ◢◤◢◤◢◤◢◤ [Core Banner Printer] ◢◤◢◤◢◤◢◤
# ————————————————————————————————————————————
print_dbd_banner() {
    [[ "$DBD_ENABLED" != "true" ]] && return
    [[ -n "$DBD_ALREADY_PRINTED" ]] && return
    
    export DBD_ALREADY_PRINTED=1
    clear
    
    # Apply padding
    if (( DBD_PADDING > 0 )); then
        local i; for ((i=0; i<DBD_PADDING; i++)); do echo; done
    fi
    
    load_dbd_font || return
    local current_dir=$(basename "$PWD")

    # Random mode handling
    if { [[ "$DBD_RANDOM_FONT" == "true" ]] || [[ "$DBD_RANDOM_COLOR" == "true" ]]; } && command -v shuf >/dev/null; then
        [[ "$DBD_RANDOM_FONT" == "true" ]] && 
            DBD_FONT=$(find "$DBD_FONT_DIR" -name '*.flf' -printf '%f\n' | shuf -n1 | sed 's/\.flf$//')
        [[ "$DBD_RANDOM_COLOR" == "true" ]] &&
            DBD_COLOR=$(echo "cyan red green orange purple blue yellow lolcat" | tr ' ' '\n' | shuf -n1)
    fi

    # Print the banner
    if [[ "$DBD_COLOR" == "lolcat" ]] && command -v lolcat >/dev/null; then
        figlet -w "$DBD_WIDTH" -f "$DBD_FONT" "$current_dir" | lolcat
    else
        local color_code reset_code='\033[0m'
        case "$DBD_COLOR" in
            red) color_code='\033[31m' ;;
            green) color_code='\033[32m' ;;
            yellow) color_code='\033[33m' ;;
            blue) color_code='\033[34m' ;;
            purple) color_code='\033[35m' ;;
            cyan) color_code='\033[36m' ;;
            orange) color_code='\033[38;5;208m' ;;
            *) color_code='\033[0m' ;;
        esac
        echo -e "${color_code}$(figlet -w "$DBD_WIDTH" -f "$DBD_FONT" "$current_dir")${reset_code}"
    fi

    # Bottom padding
    if (( DBD_PADDING > 0 )); then
        local i; for ((i=0; i<DBD_PADDING; i++)); do echo; done
    fi
}

# ————————————————————————————————————————————————————————
# ◢◤◢◤◢◤◢◤ [Clean Colored Directory Listing] ◢◤◢◤◢◤◢◤
# ————————————————————————————————————————————————————————
show_directory_contents() {
    unset DBD_ALREADY_PRINTED
    local show_hidden=false
    [[ "$1" == "--all" ]] && show_hidden=true

    print_dbd_banner
    
    # Colored path header
    local dir_path="📂 $PWD"
    if [[ "$DBD_COLOR" == "lolcat" ]] && command -v lolcat >/dev/null; then
        echo "$dir_path" | lolcat
    else
        case "$DBD_COLOR" in
            red|green|yellow|blue|purple|cyan|orange) 
                echo -e "\033[1m$(tput setaf ${${DBD_COLOR:0:1}//r/1//g/2//y/3//b/4//p/5//c/6//o/3})$dir_path\033[0m" ;;
            *) echo "$dir_path" ;;
        esac
    fi

    # Colored directory listing (names only)
    echo
    if $show_hidden; then
        ls --color=always -A
    else
        ls --color=always
    fi | column
}

# Public commands
dbs() { show_directory_contents; }
dba() { show_directory_contents --all; }

# —————————————————————————————————————————————————
# ◢◤◢◤◢◤◢◤ [Updated Hooks & Triggers] ◢◤◢◤◢◤◢◤
# —————————————————————————————————————————————————
# Manual Banner Trigger
dbd-show() { print_dbd_banner; }

# Track directory changes (works with auto-cd)
dbd_track_directory_change() {
    # Check if PWD changed (works for cd, auto-cd, pushd, etc.)
    [[ "$DBD_OLD_PWD" != "$PWD" ]] && {
        DBD_OLD_PWD="$PWD"
        if [[ "$DBD_ENABLED" == "true" ]]; then
            unset DBD_ALREADY_PRINTED
            dbs  # Show clean directory listing
        fi
    }
}

# One-time initial banner
dbd_initial_banner_run="false"

dbd-initial-banner() {
    if [[ "$dbd_initial_banner_run" == "false" ]]; then
        DBD_OLD_PWD="$PWD"
        dbs  # Show initial directory listing
        dbd_initial_banner_run="true"
    fi
}

# Set up hooks
autoload -U add-zsh-hook
add-zsh-hook chpwd dbd_track_directory_change
add-zsh-hook precmd dbd-initial-banner

# ——————————————————————————————————————————————————————————————————————————————————————————————————
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ——————————————————————————————————————————————————————————————————————————————————————————————————
