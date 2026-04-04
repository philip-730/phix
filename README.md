# phix

Phil's Nix configs and toolset — a flake-based system configuration for NixOS (bare metal and WSL) and macOS (Darwin).

## Overview

Phix manages reproducible system configurations across multiple machines using [Nix flakes](https://nixos.wiki/wiki/Flakes) and [home-manager](https://github.com/nix-community/home-manager). It provides a modular structure for shared and per-host settings covering the shell, editor, packages, git, and more.

**Supported platforms:**
- `mactan` — NixOS bare metal (x86_64-linux) — **daily driver** — ASUS laptop, AMD Phoenix, Hyprland on Wayland, LUKS encryption, dual-boot with Windows
- `nixos-home` — NixOS-WSL (x86_64-linux)
- `darwin-work` — macOS (aarch64-darwin)

## Usage

### Apply system configuration

**NixOS bare metal (mactan):**
```bash
sudo nixos-rebuild switch --flake .#mactan
```

**NixOS-WSL:**
```bash
sudo nixos-rebuild switch --flake .#nixos-home
```

**macOS:**
```bash
nix run nix-darwin -- switch --flake .#darwin-work
```

### Development shell

Enter a shell with Nix tooling (nil LSP, nixfmt, statix):
```bash
nix develop
```

Inspect available outputs:
```bash
nix flake show
```

## Structure

```
hosts/          per-machine entry points
modules/
  common/       shared across all systems (nix daemon, gc)
  home/         home-manager modules (shell, editor, packages, git)
  nixos/        NixOS-specific (empty, no shared config yet)
  darwin/       macOS-specific (system defaults)
users/          per-user identity and preferences
lib/            helpers for building host configurations
```

## Customization

- Add a new host: create `hosts/<name>/default.nix` and wire it up in `flake.nix` using `lib.mkNixosHost` (pass `wsl = true` for WSL hosts) or `lib.mkDarwinHost`
- Add a new user: copy an existing file in `users/` and adjust identity, aliases, and extras
- Add packages: set `phix.packages.extra` in your user file
