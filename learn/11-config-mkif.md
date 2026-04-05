# 11 · The config Block and mkIf

The `config` block is where a module actually does things — sets real NixOS
options, installs packages, writes config files.

The `options` block (lesson 10) declared the schema.
The `config` block implements it.

Open `modules/common/nix.nix` alongside this.

## The cfg alias

Every phix module starts with:

```nix
let cfg = config.phix.nix; in   # (or phix.zsh, phix.git, etc.)
```

`config` is the fully merged attrset from all modules. By the time the config
block is evaluated, it already contains every value set by every module —
including the values you set in your host file.

`config.phix.nix` is the value at that path in the merged attrset.
`cfg` is just a shorter alias. These are identical:

```nix
cfg.enable
config.phix.nix.enable
```

This isn't a special pattern — it's just a `let` binding. The name `cfg` is
a convention, not a keyword.

## lib.mkIf

```nix
lib.mkIf condition value
```

A conditional wrapper. When NixOS merges all module configs:
- condition is true → value enters the merged config
- condition is false → produces a no-op sentinel, nothing enters the config

This is how `enable` flags work:

```nix
config = lib.mkIf cfg.enable {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store   = true;
  ...
};
```

If `cfg.enable` is false (the default from `mkEnableOption`), that entire block
is a no-op. None of those `nix.settings` values enter the final config.

If `cfg.enable` is true (set in your host file), all those values are merged
into the final config.

## Nested mkIf

`mkIf` can be nested. The outer `mkIf` gates the whole block, inner ones
gate sub-sections:

```nix
config = lib.mkIf cfg.enable {
  nix.settings = { ... };        # always included when enable = true

  nix.gc = lib.mkIf cfg.gc.enable {   # only included if gc.enable is ALSO true
    automatic = true;
    options   = "...";
  };
};
```

The full condition for `nix.gc.automatic` to be set:
`cfg.enable == true` AND `cfg.gc.enable == true`

Since `cfg.gc.enable` defaults to true, garbage collection is on by default
when `phix.nix.enable = true`.

## How config values are read and written

In the config block you do two things:

**Read** from `config.phix.*` (your own options, set by users):
```nix
cfg.substituters
cfg.gc.keepGenerations
cfg.gc.enable
```

**Write** to real NixOS/home-manager options:
```nix
nix.settings.substituters = cfg.substituters;
nix.gc.automatic           = true;
programs.zsh.shellAliases  = cfg.aliases;
```

The real options you write to (`nix.settings.*`, `programs.zsh.*`, etc.) are
declared by nixpkgs and home-manager — they know how to turn those attrset
values into actual config files on disk.

You don't have to know HOW they do that. You just have to know WHAT keys exist.
The NixOS options search at `search.nixos.org/options` lists everything.

## config without options

Not every module needs an options block. Host files are pure config:

```nix
# hosts/nixos-home/default.nix
{ pkgs, ... }: {
  networking.hostName = "nixos-home";
  phix.nix.enable    = true;        # sets an option declared elsewhere
  users.users.philip = { ... };     # sets a nixpkgs option
}
```

No options declared here — just setting values. This is valid.

## The config / options split is enforced

You can ONLY set an option that has been declared somewhere. If you try to set
an option that doesn't exist:

```nix
phix.doesNotExist = true;
```

Nix errors: `"The option 'phix.doesNotExist' does not exist."`

No silent typos — if you misspell `phix.nix.gc.enble`, Nix tells you immediately.

## lib.mkIf vs if/then/else

Both work. The difference is that `mkIf` produces a special value the module
system understands, which plays better with `mkMerge`, priority overrides, etc.

For simple cases they're interchangeable. For complex module composition,
`mkIf` is the correct tool.

`if/then/else` IS used in `lib/default.nix` for the WSL modules list —
that's a plain list, not a config block, so `if/then/else` is fine there:

```nix
] ++ (if wsl then [ inputs.nixos-wsl.nixosModules.default ] else []) ++ [
```
