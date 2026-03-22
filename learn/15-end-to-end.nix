# ── 15 · End-to-End: From Command to Running System ──────────────────────────
#
# This lesson traces exactly what happens when you run:
#
#   sudo nixos-rebuild switch --flake .#nixos-home
#
# We follow two specific values through the entire stack:
#
#   A) phix.nix.enable = true   → /etc/nix/nix.conf
#   B) phix.zsh.aliases         → ~/.zshrc
#
# Have everything open. This is the full picture.
#
# ──────────────────────────────────────────────────────────────────────────────

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 1: EVALUATION
# Nix reads all .nix files and computes what the system should look like.
# Nothing is built yet. No I/O. Pure computation.
# ═══════════════════════════════════════════════════════════════════════════════

# ── 1.1 flake.nix is the entry point ─────────────────────────────────────────
#
# Nix reads flake.nix and evaluates outputs { ... }.
# See: flake.nix:23
#
#   outputs = { self, nixpkgs, nix-darwin, home-manager, ... }@inputs:
#     let
#       lib = import ./lib { inherit inputs; };   ← loads lib/default.nix
#     in
#     {
#       nixosConfigurations.nixos-home = lib.mkNixosHost {
#         system     = "x86_64-linux";
#         hostModule = ./hosts/nixos-home;
#         wsl        = true;
#       };
#     }
#
# `nixos-rebuild switch --flake .#nixos-home` asks for nixosConfigurations.nixos-home.

# ── 1.2 lib.mkNixosHost assembles the modules list ───────────────────────────
#
# See: lib/default.nix:10-33
#
#   nixosSystem {
#     system      = "x86_64-linux";
#     specialArgs = { inherit inputs; };   ← inputs available in every module
#     modules     = [
#       ../modules/common        → modules/common/default.nix
#       ../modules/nixos         → modules/nixos/default.nix  (empty)
#       home-manager module      → from inputs.home-manager.nixosModules
#       { home-manager.useGlobalPkgs = true; ... sharedModules = [../modules/home]; }
#       ./hosts/nixos-home       → hosts/nixos-home/default.nix
#     ];
#   }

# ── 1.3 Each module's imports are expanded ────────────────────────────────────
#
# modules/common/default.nix:
#   imports = [ ./nix.nix ]      ← adds modules/common/nix.nix to the list
#
# modules/home/default.nix (via sharedModules):
#   imports = [ ./zsh.nix ./git.nix ./packages.nix ./editor.nix ]
#
# Final expanded module list (simplified):
#   modules/common/nix.nix
#   modules/nixos/default.nix    (empty)
#   home-manager NixOS module
#   { home-manager config }
#   hosts/nixos-home/default.nix
#   [home-manager submodules for user philip]:
#     modules/home/zsh.nix
#     modules/home/git.nix
#     modules/home/packages.nix
#     modules/home/editor.nix
#     users/phil-personal.nix

# ── 1.4 All options declarations are merged ───────────────────────────────────
#
# NixOS calls every module function and collects all `options` blocks:
#
#   From modules/common/nix.nix:7-39:
#     options.phix.nix.enable             = bool, default false
#     options.phix.nix.gc.enable          = bool, default true
#     options.phix.nix.gc.frequency       = str,  default "weekly"
#     options.phix.nix.gc.keepGenerations = int,  default 5
#     options.phix.nix.substituters       = listOf str, default [...]
#     options.phix.nix.trustedPublicKeys  = listOf str, default [...]
#
#   From modules/home/zsh.nix:7-48:
#     options.phix.zsh.enable      = bool, default false
#     options.phix.zsh.aliases     = attrsOf str, default {}
#     options.phix.zsh.historySize = int, default 10000
#     ... etc.
#
#   Plus thousands of options from nixpkgs (nix.settings.*, networking.*, etc.)
#   and home-manager (programs.zsh.*, home.packages, etc.)

# ── 1.5 All config values are merged ──────────────────────────────────────────
#
# NixOS collects all `config` blocks from all modules and deep-merges them.
#
# Value A: phix.nix.enable
# ─────────────────────────
#   hosts/nixos-home/default.nix:21  →  phix.nix.enable = true
#   (no other module sets this)
#   Merged result: config.phix.nix.enable = true
#
# Value B: phix.zsh.aliases
# ──────────────────────────
#   users/phil-personal.nix:13-20  →  phix.zsh.aliases = { ll = "eza -la"; ... }
#   (no other module sets this)
#   Merged result: config.phix.zsh.aliases = { ll = "eza -la"; cat = "bat"; ... }

# ── 1.6 mkIf conditions are resolved ─────────────────────────────────────────
#
# Value A path:
#   modules/common/nix.nix:41   →  lib.mkIf cfg.enable { nix = { ... }; }
#   cfg.enable = true           →  mkIf unwraps, nix.settings.* enters the merge
#
#   modules/common/nix.nix:50   →  lib.mkIf cfg.gc.enable { nix.gc = { ... }; }
#   cfg.gc.enable = true (default) → mkIf unwraps, nix.gc.* enters the merge
#
# Value B path:
#   modules/home/zsh.nix:50     →  lib.mkIf cfg.enable ( lib.mkMerge [ ... ] )
#   cfg.enable = true           →  outer mkIf unwraps, mkMerge items evaluated
#
#   modules/home/zsh.nix:68     →  lib.mkIf cfg.starship.enable { programs.starship = ...; }
#   cfg.starship.enable = true (default) → mkIf unwraps, starship config enters merge

# ── 1.7 Final merged config (relevant excerpt) ────────────────────────────────
#
# After all merges and resolutions, the relevant parts of config look like:
#
# Value A result:
#   nix.settings.experimental-features = [ "nix-command" "flakes" ];
#   nix.settings.substituters          = [ "https://cache.nixos.org" ];
#   nix.settings.trusted-public-keys   = [ "cache.nixos.org-1:..." ];
#   nix.settings.auto-optimise-store   = true;
#   nix.gc.automatic                   = true;
#   nix.gc.options                     = "--delete-older-than +5";
#
# Value B result (in home-manager context for user philip):
#   programs.zsh.enable                = true;
#   programs.zsh.shellAliases          = { ll = "eza -la"; cat = "bat"; ... };
#   programs.zsh.history.size          = 10000;
#   programs.zsh.autosuggestion.enable = true;
#   programs.zsh.syntaxHighlighting.enable = true;
#   programs.starship.enable           = true;
#   programs.starship.enableZshIntegration = true;

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 2: REALISATION
# Nix takes the evaluated config and builds everything needed.
# Downloads, compiles, creates store paths.
# ═══════════════════════════════════════════════════════════════════════════════

# ── 2.1 Nix computes what needs to be built ───────────────────────────────────
#
# nixpkgs translates nix.settings.* into a nix.conf derivation.
# home-manager translates programs.zsh.* into a .zshrc derivation.
# home-manager translates home.packages into a user profile derivation.
#
# For each derivation, Nix checks:
# - Is this already in the store? (same hash = already built)
# - Is it in a binary cache? (download instead of build)
# - Otherwise: build from source

# ── 2.2 Store paths are created ───────────────────────────────────────────────
#
# After building, the store contains (among many other things):
#
#   /nix/store/<hash>-nix.conf
#     → the generated nix.conf with experimental-features, substituters, etc.
#
#   /nix/store/<hash>-home-manager-files-philip
#     → philip's dotfiles, including .zshrc with the aliases
#
#   /nix/store/<hash>-ripgrep-14.x/         (and fd, bat, eza, etc.)
#     → the actual package binaries

# ── 2.3 System activation ────────────────────────────────────────────────────
#
# Nix creates a new generation (a new system profile) pointing to these store paths.
# The activation script:
#
#   - Symlinks /etc/nix/nix.conf → /nix/store/<hash>-nix.conf
#   - Runs home-manager's activation for user philip:
#       - Links ~/.config/* to the store dotfiles
#       - Links ~/.local/state/nix/profiles/home-manager to the new profile
#       - Runs any activation scripts (like reloading daemons)
#   - Updates /run/current-system → new generation
#   - Reloads systemd services affected by changed config
#   - Runs the nix.gc timer setup (because we enabled automatic GC)

# ═══════════════════════════════════════════════════════════════════════════════
# WHAT ACTUALLY ENDS UP ON DISK
# ═══════════════════════════════════════════════════════════════════════════════

# Value A: /etc/nix/nix.conf
# ─────────────────────────────────────────────────────────────────────────────
# extra-experimental-features = nix-command flakes
# substituters = https://cache.nixos.org
# trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
# auto-optimise-store = true
#
# (This is a symlink to a /nix/store path — it's immutable.)

# Value B: ~/.zshrc (generated by home-manager programs.zsh)
# ─────────────────────────────────────────────────────────────────────────────
# ... (history settings, completion setup) ...
# alias ll='eza -la'
# alias la='eza -a'
# alias ls='eza'
# alias cat='bat'
# alias grep='rg'
# alias top='htop'
# ... (starship init, autosuggestions, syntax highlighting) ...
#
# (Also a symlink to /nix/store.)

# ═══════════════════════════════════════════════════════════════════════════════
# THE COMPLETE CHAIN — SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════
#
# flake.nix
#   └─ lib.mkNixosHost { hostModule = ./hosts/nixos-home; wsl = true; }
#         └─ nixosSystem { modules = [ common nixos home-manager host ] }
#               └─ modules merged + evaluated
#                     │
#                     ├─ phix.nix.enable = true            (hosts/nixos-home)
#                     │     └─ nix.settings.* set          (modules/common/nix.nix)
#                     │           └─ /etc/nix/nix.conf      (nixpkgs)
#                     │
#                     └─ phix.zsh.aliases = { ll = ... }   (users/phil-personal.nix)
#                           └─ programs.zsh.shellAliases    (modules/home/zsh.nix)
#                                 └─ ~/.zshrc               (home-manager)
#
# Every arrow is either: a module setting an option, or nixpkgs/home-manager
# translating an option into a real file. You wrote the phix.* → programs.*
# translations yourself. Everything else is handled by nixpkgs and home-manager.
