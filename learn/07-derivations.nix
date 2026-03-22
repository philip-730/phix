# ── 07 · Derivations and the Nix Store ────────────────────────────────────────
#
# A derivation is a recipe for building something. It describes:
#   - what inputs are needed (other packages, source code, scripts)
#   - what commands to run to produce the output
#   - the expected output path in the Nix store
#
# This is the foundation everything else in Nix is built on — packages, system
# configs, dotfiles, even the NixOS activation scripts.
#
# This file is ANNOTATED — derivations require nixpkgs to evaluate.
#
# ──────────────────────────────────────────────────────────────────────────────

# ── The Nix store ─────────────────────────────────────────────────────────────
#
# Everything Nix builds goes into /nix/store/. Each path looks like:
#
#   /nix/store/<hash>-<name>-<version>/
#
# Example:
#   /nix/store/yw8g0gfhbgp7f4s9pnbr6gj4vz1r9qlh-ripgrep-14.1.0/
#   /nix/store/yw8g0gfhbgp7f4s9pnbr6gj4vz1r9qlh-ripgrep-14.1.0/bin/rg
#
# The hash is computed from ALL inputs to the build — the source code, compiler
# version, build flags, every dependency. If anything changes, the hash changes,
# and a NEW path is created. The old one is untouched.
#
# This is what makes Nix reproducible: the same inputs always produce the same
# output path. Two machines with the same hash have the exact same binary.

# ── What a derivation looks like (simplified) ────────────────────────────────
#
# Under the hood, all packages in nixpkgs are derivations. Here's a sketch:
#
#   derivation {
#     name    = "ripgrep-14.1.0";
#     system  = "x86_64-linux";
#     builder = /bin/sh;           # script that does the build
#     src     = <the ripgrep source tarball, also a store path>;
#     ...
#   }
#
# In practice you never write `derivation {}` directly. You use helpers like
# `pkgs.stdenv.mkDerivation`, `pkgs.buildRustPackage`, etc. that fill in the
# boilerplate.
#
# When you reference `pkgs.ripgrep` in your config, you're referencing this
# derivation. Nix doesn't build it immediately — it builds a plan first
# (evaluation), then builds (realisation) only what's needed.

# ── Packages in phix ──────────────────────────────────────────────────────────
#
# In modules/home/packages.nix:24-40:
#
#   home.packages = lib.optionals cfg.core [
#     pkgs.ripgrep   ← a derivation in nixpkgs
#     pkgs.fd
#     pkgs.bat
#     ...
#   ] ++ cfg.extra;
#
# `pkgs.ripgrep` is just an attrset key in nixpkgs — it evaluates to the
# ripgrep derivation. Putting it in home.packages tells home-manager "ensure
# this store path is built and linked into the user's profile."

# ── Evaluation vs Realisation ─────────────────────────────────────────────────
#
# Nix has two distinct phases:
#
# 1. EVALUATION  — Nix reads all your .nix files, evaluates expressions,
#                  resolves all modules, and builds a complete description of
#                  what the system should look like. Pure computation, no I/O.
#                  Fast. This is what `nix eval` does.
#
# 2. REALISATION — Nix takes that description and actually builds things:
#                  downloads sources, compiles, creates store paths, writes
#                  config files. Slow. This is what `nixos-rebuild switch` does.
#
# If a package is already in the store (same hash), realisation is instant —
# Nix just reuses it. This is also why binary caches exist: someone else already
# realised the derivation and uploaded it to cache.nixos.org.

# ── Binary caches ────────────────────────────────────────────────────────────
#
# Building from source is slow. Binary caches let you download pre-built store
# paths instead.
#
# When Nix needs to realise a derivation, it first checks the configured caches:
# "does anyone have a store path with this exact hash already built?"
# If yes, download it. If no, build from source.
#
# In phix, you configure this with phix.nix.substituters and trustedPublicKeys:
# See: modules/common/nix.nix:28-38
#
#   substituters = [ "https://cache.nixos.org" ];
#   trustedPublicKeys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
#
# The public key ensures you only trust signed binaries from that cache — you're
# not just downloading arbitrary binaries from the internet.

# ── Garbage collection ───────────────────────────────────────────────────────
#
# The store only grows — Nix never deletes store paths on its own. Over time you
# accumulate gigabytes of old packages from previous generations.
#
# `nix-collect-garbage` deletes store paths that are no longer reachable from
# any active generation or GC root.
#
# In phix this is automated with phix.nix.gc:
# See: modules/common/nix.nix:50-53
#
#   nix.gc = lib.mkIf cfg.gc.enable {
#     automatic = true;
#     options = "--delete-older-than +${toString cfg.gc.keepGenerations}";
#   };
#
# This creates a systemd timer that runs nix-collect-garbage on a schedule,
# keeping only the last N generations.

# ── Generations ──────────────────────────────────────────────────────────────
#
# Every time you run `nixos-rebuild switch`, Nix creates a new GENERATION —
# a new system profile pointing to a new set of store paths. The old generation
# still exists in the store.
#
# You can list generations:
#   nix-env --list-generations
#   sudo nix-env -p /nix/var/nix/profiles/system --list-generations
#
# And roll back:
#   sudo nixos-rebuild switch --rollback
#
# Generations are why GC needs to know about keepGenerations — you want to keep
# a few old ones so you can roll back if the new config breaks something.

# ── store optimisation ───────────────────────────────────────────────────────
#
# In phix, auto-optimise-store = true in modules/common/nix.nix:47.
#
# This deduplicates identical files in the store using hard links. If two
# packages contain the same file (common with shared libraries), they share
# one copy on disk instead of two.
