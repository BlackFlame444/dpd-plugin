# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤ [ DBD System Plugin Configuration ] ◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# --------------------------------------------------------------------------------
# ~/.oh-my-zsh/custom/plugins/dbd-plugin/dbd-config.zsh
# --------------------------------------------------------------------------------
# Plugin Root Directory (automatically set)
  export DBD_PLUGIN_DIR="$HOME/.oh-my-zsh/custom/plugins/dbd-plugin/"
# --------------------------------------------------------------------------------
# Font Storage Directory (auto-created when plugin loads)
  export DBD_FONT_DIR="/usr/local/share/figlet"
# --------------------------------------------------------------------------------
# Default font (must match a valid .flf file in $DBD_FONT_DIR)
  export DBD_FONT="lowerb"
# --------------------------------------------------------------------------------
# Banner colors (options: red, green, yellow, blue, purple, cyan, orange, lolcat)
  export DBD_COLOR="lolcat"
# --------------------------------------------------------------------------------
# Banner padding (number of blank lines above/below the banner)
  export DBD_PADDING="0"
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
  export DBD_WIDTH="200"
# --------------------------------------------------------------------------------
