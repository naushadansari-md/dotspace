# dotspace ✨

> A reproducible Arch Linux dotfiles setup for Wayland desktops.  
> Includes Hyprland, Niri, Waybar, Kitty, Zsh and related tooling.

---

## 🖼 Preview

![Hyprland](assets/screenshots/hyprland.png)
![Niri](assets/screenshots/niri.png)

---

## 🧭 Table of Contents

- [Preview](#preview)
- [Quick Start (Recommended)](#quick-start-recommended)
- [Manual Installation](#manual-installation)
- [Features](#features)
- [Structure](#structure)
- [Package Management](#package-management)
- [Notes](#notes)
- [License](#license)

---

## 🚀 Quick Start (Recommended)

```bash
git clone https://github.com/naushadansari-md/dotspace.git
cd dotspace
chmod +x setup.sh
./setup.sh
---

## ⚙️ Manual Installation

Use this if you prefer to run components individually.

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

## 🚀 Features

Arch / Arch-based OS detection

Safe backup before overwriting configs

Dry-run mode for safe testing

AUR auto-detection (yay / paru)

Single-command setup (setup.sh)

Clean idempotent symlink system

Modular installer (packages + configs separated)

Home dotfile support (.zshrc)

Safe to run multiple times

## 🧱 Structure
dotspace/
├── setup.sh
├── install.sh
├── install-packages.sh
├── packages/
│   ├── pkglist.txt
│   └── aur-pkglist.txt
├── scripts/
│   └── pkglist.sh
├── hypr/
├── niri/
├── waybar/
├── kitty/
├── zsh/
├── .zshrc
├── assets/
│   └── screenshots/
└── README.md

## 📦 Package Management
Generate package lists:

./scripts/pkglist.sh packages

Restore official packages:

sudo pacman -Syu --needed - < packages/pkglist.txt

Install AUR packages:

yay -S --needed - < packages/aur-pkglist.txt

## ⚠️ Notes

Designed for Arch Linux and Arch-based distributions

Existing configs are backed up automatically to:

~/.config-backup-YYYYMMDD-HHMMSS

.zshrc is linked directly to:

~/.zshrc

All install scripts are idempotent (safe to re-run)

## 📄 License
MIT © Naushad Ansari

---

## ✅ Now Apply

```bash
cd ~/dotspace
nano README.md
# delete everything
# paste the full version above
git add README.md
git commit -m "Fix README formatting completely"
git push

---
