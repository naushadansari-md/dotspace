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
## Manual Installation

Use this method if you want full control over the installation process.

Ideal when:

You want to inspect packages before installing

You only want configs

You only want packages

You are debugging

Install packages only

Installs official Arch packages and AUR packages separately.

./install-packages.sh
| Option             | Description                                  |
| ------------------ | -------------------------------------------- |
| `--dry-run`        | Preview installation without making changes  |
| `--force`          | Reinstall packages even if already installed |
| `--aur-helper yay` | Manually specify AUR helper (`yay` / `paru`) |

Example
./install-packages.sh --dry-run
./install-packages.sh --aur-helper paru

stall dotfiles only

Creates symlinks and backs up existing configurations.

./install.sh

What it does:

Creates symlinks under ~/.config

Links .zshrc to ~/.zshrc

Automatically backs up existing configs

Skips already-linked files

Safe to run multiple times

| Option      | Description                |
| ----------- | -------------------------- |
| `--dry-run` | Preview changes only       |
| `--force`   | Overwrite existing configs |

| Option      | Description                |
| ----------- | -------------------------- |
| `--dry-run` | Preview changes only       |
| `--force`   | Overwrite existing configs |

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
