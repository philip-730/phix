# ── 08 · Flakes ────────────────────────────────────────────────────────────────
#
# A flake is a standardised way to structure a Nix project. Before flakes,
# there was no standard entry point — everyone did things differently.
# Flakes give every project a flake.nix with defined inputs and outputs,
# and a flake.lock that pins every input to a specific commit.
#
# This file is ANNOTATED — open flake.nix alongside it.
# See: flake.nix
#
# ──────────────────────────────────────────────────────────────────────────────

# ── The two keys: inputs and outputs ─────────────────────────────────────────
#
# Every flake.nix is an attrset with two required keys:
#
#   {
#     inputs  = { ... };   ← external dependencies (other flakes)
#     outputs = { ... };   ← what this flake provides
#   }
#
# That's it at the top level. Everything else goes inside those.

# ── inputs ────────────────────────────────────────────────────────────────────
#
# Inputs are other flakes your config depends on. Each input is an attrset with
# at minimum a `url` key.
#
# From flake.nix:4-21:
#
#   inputs = {
#     nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
#
#     nix-darwin = {
#       url = "github:LnL7/nix-darwin/master";
#       inputs.nixpkgs.follows = "nixpkgs";  ← see below
#     };
#
#     home-manager = {
#       url = "github:nix-community/home-manager/master";
#       inputs.nixpkgs.follows = "nixpkgs";
#     };
#
#     nixos-wsl = {
#       url = "github:nix-community/NixOS-WSL/main";
#       inputs.nixpkgs.follows = "nixpkgs";
#     };
#   };
#
# Each input is fetched and locked to a specific commit in flake.lock.
# flake.lock is generated automatically and should be committed to git.
# It guarantees that everyone using this repo gets the exact same versions.

# ── inputs.X.follows ─────────────────────────────────────────────────────────
#
#   inputs.nixpkgs.follows = "nixpkgs";
#
# nix-darwin, home-manager, and nixos-wsl each have their OWN copy of nixpkgs
# as an input. Without `follows`, you'd end up with 4 slightly different versions
# of nixpkgs in your system — wasting space and potentially causing version mismatches.
#
# `follows = "nixpkgs"` says "use MY nixpkgs input instead of your own copy."
# All four inputs end up sharing a single nixpkgs version.

# ── outputs ───────────────────────────────────────────────────────────────────
#
# Outputs is a FUNCTION that takes the resolved inputs and returns an attrset
# describing what this flake provides.
#
# From flake.nix:23-56:
#
#   outputs = { self, nixpkgs, nix-darwin, home-manager, ... }@inputs:
#     let
#       lib = import ./lib { inherit inputs; };
#     in
#     {
#       nixosConfigurations = { ... };
#       darwinConfigurations = { ... };
#       devShells = { ... };
#     };
#
# The argument `{ self, nixpkgs, nix-darwin, ... }@inputs` destructures the
# inputs attrset. `self` is special — it refers to THIS flake itself.
# `@inputs` gives you the whole attrset as `inputs` for passing around.

# ── Standard output keys ──────────────────────────────────────────────────────
#
# Nix knows about these specific output keys and what to do with them:
#
#   nixosConfigurations.<hostname>    → built with `nixos-rebuild switch --flake .#hostname`
#   darwinConfigurations.<hostname>   → built with `darwin-rebuild switch --flake .#hostname`
#   devShells.<system>.default        → entered with `nix develop`
#   packages.<system>.<name>          → built with `nix build .#name`
#   apps.<system>.<name>              → run with `nix run .#name`
#
# phix uses nixosConfigurations, darwinConfigurations, and devShells.
# See: flake.nix:28-55

# ── nixosConfigurations ───────────────────────────────────────────────────────
#
# From flake.nix:28-33:
#
#   nixosConfigurations = {
#     nixos-home = lib.mkNixosHost {
#       system = "x86_64-linux";
#       hostModule = ./hosts/nixos-home;
#       wsl = true;
#     };
#   };
#
# The key `nixos-home` is the hostname. When you run:
#   sudo nixos-rebuild switch --flake .#nixos-home
#
# Nix looks up `nixosConfigurations.nixos-home` in this flake, builds it,
# and activates the result.

# ── devShells ─────────────────────────────────────────────────────────────────
#
# From flake.nix:44-55:
#
#   devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (system:
#     let pkgs = nixpkgs.legacyPackages.${system};
#     in {
#       default = pkgs.mkShell {
#         packages = [ pkgs.nil pkgs.nixfmt-rfc-style pkgs.statix ];
#       };
#     }
#   );
#
# `genAttrs` creates an attrset from a list of keys using a function.
# This creates devShells for both Linux and macOS from one definition.
#
# Running `nix develop` in this repo gives you nil (Nix LSP), a formatter,
# and statix (linter) — everything you need to work on the config.

# ── flake.lock ────────────────────────────────────────────────────────────────
#
# After running `nix flake update` (or the first time Nix evaluates the flake),
# Nix writes flake.lock pinning every input to an exact commit hash.
#
# Example entry (conceptual):
#   "nixpkgs": {
#     "locked": {
#       "rev": "abc123...",
#       "url": "github:NixOS/nixpkgs/abc123...",
#       "narHash": "sha256-..."
#     }
#   }
#
# Commit flake.lock to git. It's the difference between "it works on my machine"
# and "it works on every machine."
#
# To update all inputs to latest:   nix flake update
# To update one input:              nix flake update nixpkgs
