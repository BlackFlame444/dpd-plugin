# DBD Plugin for Oh-My-Zsh

✨ **DBD (Directory Banner Display)** is a custom plugin for Oh-My-Zsh that displays eye-catching banners whenever you change directories (`cd`). It uses `figlet` and `lolcat` to generate colorful banners, giving your terminal a stylish touch.

---

## 📦 Features

✅ **Custom Banners:** Show directory names in customizable banners.  
✅ **Custom Fonts:** Supports any `.flf` font from figlet's library.  
✅ **Random Mode:** Random fonts and colors every time you change directories.  
✅ **Easy Configuration:** Use `dbd-config` to tweak settings on the fly.  
✅ **Font Converter:** Convert `.ttf` and `.otf` fonts into `.flf` for use with figlet.  
✅ **Auto-Installer:** Comes with a setup script that handles everything.

---

## 🔗 Dependencies

These are automatically installed by `dbd-setup.sh` if missing:

- **figlet:** Generates the banners.
- **lolcat:** Adds rainbow colors (optional).
- **toilet:** Alternative banner generator (optional).
- **otf2bdf** and **bdf2psf:** Convert modern fonts into figlet-compatible `.flf`.

---

## 🚀 Installation

### One-Line Automatic Install

Just run this:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/BlackFlame444/dpd-plugin/refs/heads/main/dbd-setup.sh)"
```

---

### Manual Installation (if you prefer)

1️⃣ Clone the repo into your Oh-My-Zsh custom plugins folder:

```bash
git clone https://github.com/BlackFlame444/dbd-plugin.git ~/.oh-my-zsh/custom/plugins/dbd-plugin
```

2️⃣ Run the setup script directly:

```bash
~/.oh-my-zsh/custom/plugins/dbd-plugin/dbd-setup.sh
```

3️⃣ Reload your shell:

```bash
source ~/.zshrc
```

---

## ⚡ Usage

### Automatic Banner on `cd`
When you change directories, the banner displays automatically:

```bash
cd ~/projects
```

### Manual Trigger (If Needed)
Want to show the banner manually?

```bash
dbd-show
```

---

## ⚙️ Configuration

You can configure everything via the `dbd-config` command:

```bash
dbd-config set font <font_name>  # Set the default font
dbd-config set color <color>     # Set the default color
dbd-config set random on         # Enable random mode
dbd-config show                   # View current configuration
```

---

## ✨ Font Management

### Convert Custom Fonts
Easily convert `.ttf` and `.otf` fonts to figlet `.flf` using:

```bash
dbd-font /path/to/font.ttf
```

### List Available Fonts
See all fonts installed:

```bash
dbd-list-fonts
```

### Add Custom Fonts Manually
Drop your `.flf` files directly into:

```
dbd-ff https://github.com/user/figlet-fonts.git
```

---

## 📂 Folder Structure

```
dbd-plugin/
├── dbd.plugin.zsh          # Main plugin loader
├── dbd-config.zsh          # User configuration
├── dbd-setup.sh            # Installation script
└── /usr/local/share/figlet # System font directory (300+ fonts)
```

---

## ✅ Example Banner

```bash

    █ █         █            █              ▀
▄▀▀▀█ █▀▀▀▄ ▄▀▀▀█      ▄▀▀▀▄ █ █   █ ▄▀▀▀▄ ▀█  █▀▀▄
█   █ █   █ █   █ ▀▀▀▀ █   █ █ █   █ █   █  █  █  █
▀▄▄▄▀ ▀▄▄▄▀ ▀▄▄▄▀      █▄▄▄▀ █ ▀▄▄▄▀ ▀▄▄▄█ ▄█▄ █  █
                       █              ▄▄▄▀
📂 /.oh-my-zsh/custom/plugins/dbd-plugin

dbd-fonts  dbd-config.zsh  dbd-plugin.zsh

```

---

## 💡 Tip

Run `dbd-config` anytime to change your style without editing files manually.

---

## 🛠️ Uninstall (If Needed)

```bash
rm -rf ~/.oh-my-zsh/custom/plugins/dbd-plugin
sed -i '/dbd-plugin/d' ~/.zshrc
source ~/.zshrc
```

---

## 📜 License

MIT License - Modify, share, and enjoy.

---

## 👨‍💻 Author

Developed by **BlackFlame444**  
[GitHub](https://github.com/BlackFlame444)


