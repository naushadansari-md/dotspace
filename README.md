# dotspace ✨

A reproducible **Arch Linux dotfiles setup** for modern **Wayland desktops**.

Includes:

- Hyprland
- Niri
- Waybar
- Kitty
- Zsh
- Supporting Wayland tooling

Designed for Arch Linux and Arch-based distributions.

---

## Preview

![Hyprland](assets/screenshots/hyprland.png)
![Niri](assets/screenshots/niri.png)

---

## Table of Contents

- [Preview](#preview)
- [Quick Start (Recommended)](#quick-start-recommended)
- [Manual Installation](#manual-installation)
  - [Install packages only](#install-packages-only)
  - [Install dotfiles only](#install-dotfiles-only)
  - [Recommended order (manual mode)](#recommended-order-manual-mode)
- [Features](#features)
- [Structure](#structure)
- [Package Management](#package-management)
- [Backup & Restore](#backup--restore)
- [Uninstall](#uninstall)
- [Notes](#notes)
- [License](#license)

---

## Quick Start (Recommended)

The fastest way to install everything.

```bash
git clone https://github.com/naushadansari-md/dotspace.git
cd dotspace
chmod +x setup.sh
./setup.sh
```


## Structure

```text
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
```
