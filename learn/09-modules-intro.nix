# ── 09 · The NixOS Module System ──────────────────────────────────────────────
#
# The module system is the most important concept in NixOS configuration.
# It's what lets you split config across dozens of files, reuse it across
# machines, and have things like `phix.nix.enable = true` work.
#
# This file is ANNOTATED — open modules/common/nix.nix alongside it.
#
# ──────────────────────────────────────────────────────────────────────────────

# ── What is a module? ─────────────────────────────────────────────────────────
#
# A module is a function that takes a standard set of arguments and returns
# an attrset with specific keys.
#
# Minimal module shape:
#
#   { config, lib, pkgs, ... }:   ← standard args NixOS passes to every module
#   {
#     options = { ... };           ← OPTIONAL: declare new config options
#     config  = { ... };           ← set values for config options
#     imports = [ ... ];           ← OPTIONAL: pull in other modules
#   }
#
# A module doesn't need all three keys. Many modules only have config.
# Some only have imports (like modules/common/default.nix and modules/darwin/default.nix).

# ── The standard arguments ────────────────────────────────────────────────────
#
# Every module receives these from NixOS automatically:
#
#   config  — the FULLY MERGED config attrset (all modules combined)
#             This is how a module reads what other modules set.
#             cfg = config.phix.nix reads a value set somewhere else.
#
#   lib     — the nixpkgs library: mkIf, mkOption, types, etc.
#             You can't use lib.mkOption without this.
#
#   pkgs    — the nixpkgs package set for the current system.
#             pkgs.ripgrep, pkgs.zsh, pkgs.git, etc.
#
#   options — the full merged options schema (rarely needed directly)
#
#   ...     — ignores anything else NixOS passes (like specialArgs, etc.)
#
# See: modules/common/nix.nix:1
#   { config, lib, pkgs, ... }:

# ── How NixOS collects and merges modules ─────────────────────────────────────
#
# When you run `nixos-rebuild switch --flake .#nixos-home`, NixOS:
#
# 1. Starts with the modules list from lib.mkNixosHost (lib/default.nix:14-32)
# 2. Recursively expands `imports` from each module
# 3. Calls every module function with { config, lib, pkgs, ... }
# 4. Collects all `options` declarations into a merged schema
# 5. Collects all `config` values and deep-merges them
# 6. Resolves mkIf, mkDefault, mkMerge etc.
# 7. Validates every set value against its declared type
# 8. The result is your final system configuration
#
# This happens in one giant lazy evaluation pass. Because Nix is lazy, a module
# can read from `config` (the merged result) even while contributing to it —
# Nix resolves the dependencies automatically.

# ── Why split into multiple modules? ─────────────────────────────────────────
#
# You could write all your config in one giant file. It would work.
# But modules give you:
#
# REUSE        — modules/common/ applies to both nixos-home and darwin-work.
#                You don't copy-paste. Change it once, both machines update.
#                See: lib/default.nix:15 (nixos) and lib/default.nix:43 (darwin)
#                both include ../modules/common.
#
# ABSTRACTION  — modules/home/zsh.nix hides the details of programs.zsh
#                behind phix.zsh.*. You set phix.zsh.aliases, not the 15
#                different programs.zsh sub-options directly.
#
# VALIDATION   — declaring options with types means Nix catches mistakes at
#                evaluation time. Set phix.nix.gc.keepGenerations = "five"
#                and Nix errors immediately: expected int, got string.
#
# DEFAULTS     — options have defaults. You only need to set what differs.
#                phix.nix.gc.enable defaults to true, so you don't have to
#                set it unless you want to change it.

# ── A complete minimal example ────────────────────────────────────────────────
#
# Here's the smallest possible useful module to understand the pattern:
#
#   # my-module.nix
#   { config, lib, ... }:
#   let
#     cfg = config.my.thing;   ← alias for the config values this module controls
#   in
#   {
#     options.my.thing = {
#       enable = lib.mkEnableOption "my thing";   ← declares phix.my.thing.enable
#       name   = lib.mkOption {                   ← declares phix.my.thing.name
#         type    = lib.types.str;
#         default = "world";
#       };
#     };
#
#     config = lib.mkIf cfg.enable {
#       environment.etc."hello".text = "hello, ${cfg.name}!";
#                                       ↑ writes to a real NixOS option
#     };
#   }
#
# Then somewhere in your host config:
#
#   my.thing.enable = true;
#   my.thing.name   = "Philip";
#
# Result: /etc/hello contains "hello, Philip!"
#
# That's the whole pattern. phix.nix, phix.zsh, phix.git etc. all follow
# exactly this structure, just with more options and more complex implementations.
# See: modules/common/nix.nix for the real thing.

# ── specialArgs ───────────────────────────────────────────────────────────────
#
# Some things can't come from config (like inputs from flake.nix — they exist
# before modules are even loaded). These are passed via specialArgs.
#
# From lib/default.nix:12:
#   specialArgs = { inherit inputs; };
#
# This makes `inputs` available as an argument to every module. A module can
# then do:
#
#   { inputs, config, lib, ... }:
#   {
#     # use inputs.nixpkgs, inputs.home-manager, etc. directly
#   }
#
# The difference from config: specialArgs values are static pass-through.
# config values are the result of the module merge itself.
