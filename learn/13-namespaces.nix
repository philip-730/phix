# ── 13 · Custom Namespaces — How phix.* Works ─────────────────────────────────
#
# `phix` is not a special keyword. It's just a string you chose as the root
# of your option namespace. You could have used `my`, `phil`, `config`, anything.
#
# This lesson traces exactly how phix.zsh.aliases goes from a value in
# users/phil-personal.nix to actual shell aliases in ~/.zshrc.
#
# Files to have open:
#   users/phil-personal.nix
#   modules/home/zsh.nix
#
# ──────────────────────────────────────────────────────────────────────────────

# ── Step 1: someone sets a phix option ───────────────────────────────────────
#
# From users/phil-personal.nix:12-20:
#
#   phix.zsh = {
#     enable = true;
#     aliases = {
#       ll = "eza -la";
#       la = "eza -a";
#       ls = "eza";
#       cat = "bat";
#       grep = "rg";
#       top = "htop";
#     };
#   };
#
# This is just setting keys in an attrset. At this point it's data — nothing
# happens yet. NixOS collects this from the module and adds it to the big
# merged config attrset.

# ── Step 2: the options block registers the namespace ─────────────────────────
#
# From modules/home/zsh.nix:7-48:
#
#   options.phix.zsh = {
#     enable  = lib.mkEnableOption "zsh configuration";
#     aliases = lib.mkOption {
#       type    = lib.types.attrsOf lib.types.str;
#       default = {};
#       ...
#     };
#     initExtra   = lib.mkOption { ... };
#     envVars     = lib.mkOption { ... };
#     historySize = lib.mkOption { type = lib.types.int; default = 10000; ... };
#     starship    = { enable = ...; settings = ...; };
#   };
#
# This tells NixOS: "phix.zsh.* are valid options with these types and defaults."
# Without this declaration, setting phix.zsh.enable would be an error.
#
# `phix` as the first key is your choice. Nothing in NixOS required it.
# You could have declared `options.myapp.shell.aliases` and set
# `myapp.shell.aliases = { ll = "eza -la"; }` instead.

# ── Step 3: NixOS merges and validates ───────────────────────────────────────
#
# NixOS sees both the options declaration (from zsh.nix) and the value
# (from phil-personal.nix). It:
#
# 1. Checks that phix.zsh.enable is a bool — it is (true)
# 2. Checks that phix.zsh.aliases is attrsOf str — it is ({ ll = "eza -la"; ... })
# 3. Applies defaults for any options not set (historySize = 10000, etc.)
# 4. The merged config now contains:
#
#    config.phix.zsh = {
#      enable      = true;
#      aliases     = { ll = "eza -la"; la = "eza -a"; ls = "eza"; cat = "bat"; grep = "rg"; top = "htop"; };
#      initExtra   = "";           ← default
#      envVars     = {};           ← default
#      historySize = 10000;        ← default
#      starship.enable   = true;   ← default
#      starship.settings = {};     ← default
#    };

# ── Step 4: the config block translates to real options ───────────────────────
#
# From modules/home/zsh.nix:50-75:
#
#   config = lib.mkIf cfg.enable (lib.mkMerge [
#     {
#       programs.zsh = {
#         enable       = true;
#         shellAliases = cfg.aliases;       ← { ll = "eza -la"; ... }
#         initExtra    = cfg.initExtra;     ← ""
#         history = {
#           size      = cfg.historySize;    ← 10000
#           save      = cfg.historySize;
#           ignoreDups = true;
#           share      = true;
#         };
#         sessionVariables = cfg.envVars;   ← {}
#         autosuggestion.enable      = true;
#         syntaxHighlighting.enable  = true;
#         enableCompletion           = true;
#       };
#     }
#     (lib.mkIf cfg.starship.enable {       ← true (default)
#       programs.starship = {
#         enable              = true;
#         enableZshIntegration = true;
#         settings            = cfg.starship.settings;  ← {}
#       };
#     })
#   ]);
#
# cfg.enable is true, so this whole block enters the merged config.
# `programs.zsh.*` and `programs.starship.*` are home-manager options.
# home-manager knows how to turn those into ~/.zshrc and ~/.config/starship.toml.

# ── The full chain for phix.zsh.aliases ──────────────────────────────────────
#
#  users/phil-personal.nix        sets  phix.zsh.aliases = { ll = "eza -la"; ... }
#       ↓ merged into config
#  modules/home/zsh.nix           reads cfg.aliases
#       ↓ writes to
#  programs.zsh.shellAliases      = { ll = "eza -la"; ... }   (home-manager option)
#       ↓ home-manager translates
#  ~/.zshrc                       alias ll='eza -la'
#
# Your module is the MIDDLE layer. You defined both sides of the translation.

# ── Why add a phix.* layer at all? ───────────────────────────────────────────
#
# You could skip phix.* entirely and write directly to programs.zsh.shellAliases
# in your user files. It would work. But then:
#
# - Both phil-personal.nix and phil-work.nix would need to duplicate all the
#   programs.zsh sub-options (autosuggestion, syntaxHighlighting, history, etc.)
#
# - Changing the default history size would require editing every user file
#
# - No type checking on your values (programs.zsh.shellAliases IS typed by
#   home-manager, but your own grouping of options wouldn't be)
#
# The phix.* layer means:
# - Users set a clean, minimal set of options
# - The module handles the boilerplate once
# - Defaults live in one place
# - Both machines get the same zsh setup from the same module

# ── Checking what's in a namespace ───────────────────────────────────────────
#
# Once your system is built, you can inspect options:
#
#   nixos-option phix.zsh.aliases       ← shows current value + declaration location
#   nixos-option phix.nix.gc            ← shows all gc sub-options
#
# Or from the command line during development:
#
#   nix eval .#nixosConfigurations.nixos-home.config.phix.zsh.aliases
#   → { cat = "bat"; grep = "rg"; la = "eza -a"; ll = "eza -la"; ls = "eza"; top = "htop"; }
