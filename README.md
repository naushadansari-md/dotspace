# dotspace ✨

> A reproducible Arch Linux dotfiles setup for Wayland desktops.  
> Includes Hyprland, Niri, Waybar, Kitty, Zsh and related tooling.

---

## 🖼 Preview

![Hyprland](assets/screenshots/hyprland.png)
![Niri](assets/screenshots/niri.png)

---

## 🧭 Table of Contents

- [Preview](#-preview)
- [Quick Start (Recommended)](#-quick-start-recommended)
- [Manual Installation](#-manual-installation)
- [Features](#-features)
- [Structure](#-structure)
- [Package Management](#-package-management)
- [Notes](#-notes)
- [License](#-license)

---

## 🚀 Quick Start (Recommended)

```bash
git clone https://github.com/naushadansari-md/dotspace.git
cd dotspace
chmod +x setup.sh
./setup.sh

## ⚙️ Manual Installation
1️⃣ Install packages only
./install-packages.sh

Options:

./install-packages.sh --dry-run
./install-packages.sh --force
./install-packages.sh --aur-helper yay

2️⃣ Install dotfiles only
./install.sh

Options:

./install.sh --dry-run
./install.sh --force