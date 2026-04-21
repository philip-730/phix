# phix

Phil's Nix configs and toolset — a flake-based system configuration for NixOS (bare metal, cloud, and WSL) and macOS (Darwin).

## Overview

Phix manages reproducible system configurations across multiple machines using [Nix flakes](https://nixos.wiki/wiki/Flakes) and [home-manager](https://github.com/nix-community/home-manager). It provides a modular structure for shared and per-host settings covering the shell, editor, packages, git, and more.

**Machines:**
- `mactan` — NixOS bare metal (x86_64-linux) — **daily driver** — ASUS laptop, AMD Phoenix, Hyprland on Wayland, LUKS encryption
- `vegeta` — NixOS cloud server (x86_64-linux) — Hetzner cx33, IPv6-only, Tailscale-only after bootstrap — infra managed in [capsule-corp](https://github.com/philip-730/capsule-corp)
- `nixos-home` — NixOS-WSL (x86_64-linux)
- `darwin-work` — macOS (aarch64-darwin)

## Usage

### Apply system configuration

**NixOS bare metal (mactan):**
```bash
sudo nixos-rebuild switch --flake .#mactan
```

**NixOS cloud server (vegeta):**
```bash
sudo nixos-rebuild switch --flake github:philip-730/phix#vegeta
```

**NixOS-WSL:**
```bash
sudo nixos-rebuild switch --flake .#nixos-home
```

**macOS:**
```bash
nix run nix-darwin -- switch --flake .#darwin-work
```

### Secrets (agenix)

Secrets are managed with [agenix](https://github.com/ryantm/agenix). Encrypted `.age` files live in `secrets/` and are decrypted on activation by the host's SSH host key into `/run/agenix/` (tmpfs — never touches disk).

**Encrypt a secret:**
```bash
nix develop  # agenix is in the dev shell
cd secrets/
cat ~/.secrets/my_secret | agenix -e my_secret.age
```

**Rekey all secrets** (after adding a new host or rotating keys):
```bash
cd secrets/
agenix -r
```

Recipients (who can decrypt each secret) are defined in `secrets/secrets.nix`. Public keys are centralized in `modules/ssot/keys.nix`.

### Development shell

Enter a shell with Nix tooling (nil LSP, nixfmt, statix, deadnix, agenix):
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
  nixos/        NixOS-specific (zsh, GitHub SSH known hosts)
  darwin/       macOS-specific (system defaults)
  ssot/         single source of truth (SSH public keys)
users/          per-user identity and preferences
secrets/        agenix-encrypted secrets (.age files) and recipient config
lib/            helpers for building host configurations
```

## Customization

- Add a new host: create `hosts/<name>/default.nix` and wire it up in `flake.nix` using `lib.mkNixosHost` or `lib.mkDarwinHost`
- Add a new user: copy an existing file in `users/` and adjust identity, aliases, and extras
- Add packages: set `phix.packages.extra` in your user file
- Add a secret: add it to `secrets/secrets.nix`, encrypt with `agenix -e`, reference via `age.secrets.<name>` in the host config
