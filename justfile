# List available recipes
default:
    @just --list

# Format all nix files in place
fmt:
    nixfmt .

# Check formatting without modifying (mirrors CI)
fmt-check:
    git ls-files '*.nix' | grep -v '^learn/' | xargs nixfmt --check

# Lint with statix
lint:
    statix check .

# Find unused nix code with deadnix
dead:
    deadnix .

# Run all checks (mirrors CI)
check: fmt-check lint dead

# Evaluate NixOS configs without building (catches module errors)
eval:
    nix eval --no-update-lock-file .#nixosConfigurations.mactan.config.system.build.toplevel.drvPath
    nix eval --no-update-lock-file .#nixosConfigurations.nixos-home.config.system.build.toplevel.drvPath

# Rebuild NixOS system (defaults to current hostname)
switch host=`hostname`:
    sudo nixos-rebuild switch --flake .#{{host}}

# Rebuild macOS system (defaults to current hostname)
switch-darwin host=`hostname`:
    nix run nix-darwin -- switch --flake .#{{host}}
