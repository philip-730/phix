# ── 12 · mk* Helpers: mkDefault, mkForce, mkMerge ────────────────────────────
#
# The module system uses special "priority" values to resolve conflicts when
# multiple modules set the same option. These helpers let you control priority.
#
# Most of the time you don't need these — the default merge just works.
# But understanding them explains behaviour you'll see in nixpkgs and phix.
#
# This file is ANNOTATED — open modules/home/zsh.nix and modules/home/editor.nix.
#
# ──────────────────────────────────────────────────────────────────────────────

# ── The conflict problem ──────────────────────────────────────────────────────
#
# What happens when two modules set the same option?
#
# Most option types (lists, attrsets with attrsOf) MERGE both values.
# But scalar options (bool, str, int) can only have ONE value.
#
# If two modules set the same scalar option without any priority marker,
# Nix errors: "The option X has conflicting definition values."
#
# The mk* helpers let modules communicate intent:
# "this is a default, feel free to override"
# "this is forced, don't override me"

# ── Priority levels ───────────────────────────────────────────────────────────
#
# Nix assigns numeric priorities to config values:
#
#   mkForce    → priority 50  (highest, overrides everything)
#   normal     → priority 100 (default, no helper)
#   mkDefault  → priority 1000 (lower, easily overridden)
#
# When two definitions of the same option exist, the one with LOWER priority
# number wins. If they have the same priority, it's a conflict error.

# ── lib.mkDefault ────────────────────────────────────────────────────────────
#
# lib.mkDefault value
#
# Marks a value as "a default — override me if you want."
# Used by modules to set sensible defaults that individual hosts can override.
#
# Example:
#
#   # In some shared module:
#   time.timeZone = lib.mkDefault "UTC";
#
#   # In your host file (normal priority):
#   time.timeZone = "America/New_York";    ← wins because 100 < 1000
#
# Without mkDefault on the shared module value, you'd get a conflict error.
# With it, your host's value silently wins.
#
# You don't currently use mkDefault in phix, but nixpkgs uses it extensively
# so that you can override its defaults in your own configs.

# ── lib.mkForce ───────────────────────────────────────────────────────────────
#
# lib.mkForce value
#
# The opposite of mkDefault — forces a value even over other modules' normal values.
# Use sparingly. It's for "this must always be this value, no exceptions."
#
# Example: security modules might use mkForce to prevent you from accidentally
# disabling a required security setting.
#
# If two mkForce values conflict, Nix still errors. mkForce isn't "always wins"
# — it's "higher priority than normal". Two mkForce values at the same option
# are still a conflict.

# ── lib.mkMerge ───────────────────────────────────────────────────────────────
#
# lib.mkMerge [ config1 config2 config3 ... ]
#
# Explicitly merge a list of config attrsets into one. Useful when a single
# config block needs to produce multiple conditional sections.
#
# Without mkMerge you'd need nested mkIf with repeated structure.
# With mkMerge you can cleanly separate independent conditional sections.
#
# From modules/home/zsh.nix:50-75:
#
#   config = lib.mkIf cfg.enable (lib.mkMerge [
#     {
#       programs.zsh = { ... };   ← always included when zsh is enabled
#     }
#     (lib.mkIf cfg.starship.enable {
#       programs.starship = { ... };   ← only if starship is also enabled
#     })
#   ]);
#
# Without mkMerge this would need to be two separate config blocks or
# a deeply nested if/then/else. mkMerge keeps it flat and readable.
#
# Also in modules/home/editor.nix:25-37:
#
#   config = lib.mkIf cfg.enable (lib.mkMerge [
#     {
#       home.sessionVariables = { EDITOR = cfg.default; VISUAL = cfg.default; };
#     }
#     (lib.mkIf cfg.helix.enable {
#       programs.helix.enable = true;
#     })
#   ]);

# ── lib.recursiveUpdate ───────────────────────────────────────────────────────
#
# lib.recursiveUpdate base override
#
# Deep-merge two attrsets. Unlike // (which replaces nested attrsets entirely),
# recursiveUpdate merges at every level.
#
#   base     = { a = { x = 1; y = 2; }; b = 3; };
#   override = { a = { y = 99; z = 0; }; };
#
#   // result:              { a = { y = 99; z = 0; }; b = 3; }  ← x is GONE
#   recursiveUpdate result: { a = { x = 1; y = 99; z = 0; }; b = 3; }  ← x preserved
#
# Used in modules/home/git.nix:78-84 to merge default git config with user's
# extraConfig, ensuring the defaults aren't lost if the user provides extra keys:
#
#   extraConfig = lib.recursiveUpdate {
#     init.defaultBranch = cfg.defaultBranch;
#     pull.rebase = true;
#     push.autoSetupRemote = true;
#     merge.conflictstyle = "diff3";
#     diff.colorMoved = "default";
#   } cfg.extraConfig;
#
# If you set phix.git.extraConfig = { push.autoSetupRemote = false; },
# only that key is overridden — the rest of the defaults survive.

# ── lib.optionals ────────────────────────────────────────────────────────────
#
# lib.optionals condition list
#   → list  if condition is true
#   → []    if condition is false
#
# Used extensively for conditional package lists:
# See: modules/home/packages.nix:24
#
#   home.packages = lib.optionals cfg.core [
#     pkgs.ripgrep pkgs.fd ...
#   ] ++ cfg.extra;
#
# If cfg.core is false, the big list is replaced with [] and only cfg.extra
# is installed. Cleaner than if/then/else in a list context.

# ── lib.mkIf (cfg.x != null) pattern ─────────────────────────────────────────
#
# When an option has type nullOr X and default null, the standard pattern is:
#
#   lib.mkIf (cfg.signingKey != null) {
#     signing.key = cfg.signingKey;
#     signing.signByDefault = true;
#   }
#
# This only enables commit signing if a key was actually provided.
# See: modules/home/git.nix:64-67
