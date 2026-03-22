# ── 10 · Declaring Options ─────────────────────────────────────────────────────
#
# The `options` block in a module is where you define the schema — what keys
# exist under your namespace, what types they accept, and what their defaults are.
#
# This is the "API" of your module. The `config` block is the implementation.
#
# This file is ANNOTATED — open modules/common/nix.nix and modules/home/zsh.nix
# alongside it.
#
# ──────────────────────────────────────────────────────────────────────────────

# ── lib.mkOption ──────────────────────────────────────────────────────────────
#
# lib.mkOption { type, default?, description?, example? }
#
# Declares a single option. The most important fields:
#
#   type        — what kind of value is allowed (enforced at eval time)
#   default     — value used if nobody sets this option
#   description — shown in `nixos-option` and documentation generators
#   example     — shown in docs, not enforced
#
# You don't need all of them. `type` is the most important.

# ── lib.mkEnableOption ────────────────────────────────────────────────────────
#
# Shorthand for a boolean enable flag that defaults to false.
#
#   enable = lib.mkEnableOption "description of what gets enabled";
#
# Equivalent to:
#   enable = lib.mkOption {
#     type    = lib.types.bool;
#     default = false;
#     description = "Whether to enable description of what gets enabled.";
#   };
#
# Used in every phix module:
#   modules/common/nix.nix:8      — phix.nix.enable
#   modules/home/zsh.nix:8        — phix.zsh.enable
#   modules/home/git.nix:8        — phix.git.enable
#   modules/home/packages.nix:8   — phix.packages.enable
#   modules/home/editor.nix:8     — phix.editor.enable

# ── Common types ──────────────────────────────────────────────────────────────
#
# All types live under lib.types.*

# lib.types.bool       → true or false
#   Used for: gc.enable, helix.enable, delta, showHiddenFiles, etc.
#   See: modules/common/nix.nix:12, modules/home/git.nix:44

# lib.types.str        → any string
#   Used for: gc.frequency, userName, userEmail, defaultBranch, initExtra, etc.
#   See: modules/common/nix.nix:18, modules/home/git.nix:10-15

# lib.types.int        → any integer
#   Used for: gc.keepGenerations, historySize, tileSize, keyRepeatRate
#   See: modules/common/nix.nix:21, modules/home/zsh.nix:29, modules/darwin/system-defaults.nix:18

# lib.types.listOf X   → a list where every element is of type X
#   Used for: substituters, trustedPublicKeys, extra (packages)
#   See: modules/common/nix.nix:28-36, modules/home/packages.nix:16
#
#   lib.types.listOf lib.types.str     → list of strings
#   lib.types.listOf lib.types.package → list of derivations

# lib.types.attrsOf X  → an attrset where every VALUE is of type X
#   Used for: aliases (attrsOf str), envVars (attrsOf str)
#   See: modules/home/zsh.nix:10, modules/home/git.nix:32
#
#   lib.types.attrsOf lib.types.str  → { ll = "eza -la"; cat = "bat"; }

# lib.types.nullOr X   → either null or a value of type X
#   Used for: signingKey — null means "no signing key configured"
#   See: modules/home/git.nix:21
#
#   The null case lets you distinguish "not set" from any real value.
#   In the config block, you can check: lib.mkIf (cfg.signingKey != null) { ... }
#   See: modules/home/git.nix:64

# lib.types.enum [ ... ] → one of a fixed set of string values
#   Used for: editor.default ("hx", "vim", "nano", "emacs")
#             finder.defaultViewStyle ("icnv", "clmv", "Nlsv", "glyv")
#   See: modules/home/editor.nix:12, modules/darwin/system-defaults.nix:40
#
#   Nix errors at eval time if you set a value not in the list.

# lib.types.package    → a derivation (a Nix package)
#   Used for: the elements of the extra list in phix.packages
#   See: modules/home/packages.nix:16
#
#   lib.types.listOf lib.types.package means you pass [ pkgs.ripgrep pkgs.fd ]

# lib.types.lines      → a multi-line string (newlines are merged, not overwritten)
#   Used for: initExtra in zsh — multiple modules can append lines
#   See: modules/home/zsh.nix:17

# lib.types.attrs      → any attrset (no type constraint on values)
#   Used for: starship.settings, extraConfig — open-ended config blobs
#   See: modules/home/zsh.nix:42, modules/home/git.nix:51
#   Use when the value structure isn't known ahead of time.

# ── Nested options ────────────────────────────────────────────────────────────
#
# Options can be nested just like regular attrsets. You declare nested keys
# simply by nesting in the options block:
#
#   options.phix.nix = {
#     enable = lib.mkEnableOption "...";
#     gc = {                              ← nested group (not itself an option)
#       enable    = lib.mkOption { ... };
#       frequency = lib.mkOption { ... };
#     };
#   };
#
# This creates phix.nix.gc.enable and phix.nix.gc.frequency as separate options.
# The `gc` attrset itself is not an option — it's just namespacing.
# See: modules/common/nix.nix:10-26

# ── What happens when you set a wrong type ───────────────────────────────────
#
# Options are type-checked during evaluation. If you set:
#
#   phix.nix.gc.keepGenerations = "five";  ← string, but type is int
#
# Nix will error immediately during `nixos-rebuild` evaluation, before it tries
# to build anything:
#
#   error: The option `phix.nix.gc.keepGenerations' has unexpected type `string'.
#          Expected `integer'.
#
# This is one of the biggest advantages over raw Bash or YAML configs —
# mistakes are caught early with a clear error pointing at the option.

# ── Options without defaults ──────────────────────────────────────────────────
#
# If an option has no `default` and nobody sets it, Nix errors if the config
# block tries to use it.
#
# In modules/home/git.nix, userName and userEmail have no default:
#   See: modules/home/git.nix:10-15
#
# That's intentional — these MUST be set per-user. If you enable phix.git but
# forget to set userName, Nix errors during evaluation rather than silently
# producing a broken git config.
