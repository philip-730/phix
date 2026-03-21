# phix

Phil's Nix configs and toolset — a flake-based system configuration for NixOS and macOS (Darwin).

## Overview

Phix manages reproducible system configurations across multiple machines using [Nix flakes](https://nixos.wiki/wiki/Flakes) and [home-manager](https://github.com/nix-community/home-manager). It provides a modular structure for shared and per-host settings covering the shell, editor, packages, git, desktop, and more.

**Supported platforms:**
- `nixos-home` — NixOS (x86_64-linux)
- `darwin-work` — macOS (aarch64-darwin)

## Usage

### Apply system configuration

**NixOS:**
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
  nixos/        NixOS-specific (desktop, networking)
  darwin/       macOS-specific (system defaults)
users/          per-user identity and preferences
lib/            helpers for building host configurations
```

## Customization

- Add a new host: create `hosts/<name>/default.nix` and wire it up in `flake.nix` using `lib.mkNixosHost` or `lib.mkDarwinHost`
- Add a new user: copy an existing file in `users/` and adjust identity, aliases, and extras
- Add packages: set `phix.packages.extra` in your user file
