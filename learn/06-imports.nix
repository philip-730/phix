# ── 06 · import and default.nix ────────────────────────────────────────────────
#
# `import` is how Nix loads other files. It evaluates the file at the given path
# and returns whatever that file contains — a function, an attrset, a string,
# anything.
#
# This file is ANNOTATED (not evaluatable) because import with relative paths
# only makes sense in context. Read the comments and look at the real files.
#
# ──────────────────────────────────────────────────────────────────────────────

# ── What import does ──────────────────────────────────────────────────────────
#
# import <path>  evaluates the file and returns its result.
#
# If the file contains a function, import returns that function.
# You then call it with the arguments it expects.
#
# Example from flake.nix:25:
#
#   lib = import ./lib { inherit inputs; };
#
# Step 1: import ./lib        → loads lib/default.nix (see below), returns the function
# Step 2: calling it with { inherit inputs; } → returns { mkNixosHost = ...; mkDarwinHost = ...; }
#
# lib/default.nix starts with:
#   { inputs }:           ← it's a function taking one named arg
#   let ... in
#   rec {
#     mkNixosHost = ...;  ← returns an attrset of helpers
#     mkDarwinHost = ...;
#   }
#
# So `lib` ends up being that attrset, and you can call lib.mkNixosHost { ... }.

# ── default.nix — the directory index ────────────────────────────────────────
#
# When you `import` a DIRECTORY (not a file), Nix automatically loads the
# `default.nix` inside that directory.
#
# So these are identical:
#   import ./lib
#   import ./lib/default.nix
#
# Same for:
#   import ./modules/common
#   import ./modules/common/default.nix
#
# This is exactly like index.js in Node or __init__.py in Python.
# It lets you point at a folder and let the folder decide what to expose.
#
# See: modules/common/default.nix — it uses this to import sub-files:
#
#   { ... }: {
#     imports = [
#       ./nix.nix    ← loads modules/common/nix.nix
#     ];
#   }
#
# And lib/default.nix is the entry point for all helper functions.

# ── imports vs import ────────────────────────────────────────────────────────
#
# These look similar but are completely different:
#
# `import`  (lowercase, no s) — Nix builtin, loads a file, returns its value.
#
# `imports` (with s) — a special key inside a NixOS MODULE. It's a list of
#            other modules to include. NixOS processes this list and merges
#            those modules in along with the current one.
#
# Example from modules/common/default.nix:
#
#   { ... }: {
#     imports = [ ./nix.nix ];   ← tell NixOS: also load nix.nix as a module
#   }
#
# NixOS sees imports = [...], loads each file, and merges them all together.
# This is NOT the same as manually calling import — NixOS handles the merging.

# ── Importing a path — getting a derivation ──────────────────────────────────
#
# When NixOS sees a path in a modules list, it calls `import` on it.
# The file is expected to be a module (a function returning { options, config, imports }).
#
# In lib/default.nix:
#   modules = [
#     ../modules/common    ← NixOS imports this, expects a module function
#     ../modules/nixos
#     hostModule           ← a variable holding a path, also imported as a module
#   ]
#
# See: lib/default.nix:14-32

# ── Importing and calling ─────────────────────────────────────────────────────
#
# In hosts/nixos-home/default.nix:24:
#
#   home-manager.users.philip = import ../../users/phil-personal.nix;
#
# This imports phil-personal.nix (a module function) and passes it as the value.
# home-manager then calls it with the right args ({ pkgs, ... }) when it builds
# that user's config.
#
# phil-personal.nix starts with:
#   { pkgs, ... }: {
#     home.stateVersion = "24.11";
#     phix.git.enable = true;
#     ...
#   }
#
# See: users/phil-personal.nix and users/phil-work.nix

# ── Summary ──────────────────────────────────────────────────────────────────
#
# import path         → evaluate file, return result (could be anything)
# import dir          → evaluate dir/default.nix, return result
# imports = [ ... ]   → NixOS module key, merge listed modules into this one
#
# The chain in phix:
#
#   flake.nix
#     import ./lib        → lib/default.nix (returns { mkNixosHost, mkDarwinHost })
#     lib.mkNixosHost { hostModule = ./hosts/nixos-home; ... }
#       nixosSystem {
#         modules = [
#           ../modules/common   → modules/common/default.nix
#             imports = [ ./nix.nix ]  → modules/common/nix.nix
#           ../modules/nixos    → modules/nixos/default.nix (empty for now)
#           hostModule          → hosts/nixos-home/default.nix
#         ]
#       }
