# 09 · The NixOS Module System

The module system is the most important concept in NixOS configuration.
It's what lets you split config across dozens of files, reuse it across
machines, and have things like `phix.nix.enable = true` work.

Open `modules/common/nix.nix` alongside this.

## What is a module?

A module is a function that takes a standard set of arguments and returns
an attrset with specific keys.

```nix
{ config, lib, pkgs, ... }:   # standard args NixOS passes to every module
{
  options = { ... };           # OPTIONAL: declare new config options
  config  = { ... };           # set values for config options
  imports = [ ... ];           # OPTIONAL: pull in other modules
}
```

A module doesn't need all three keys. Many modules only have `config`.
Some only have `imports` (like `modules/common/default.nix`).

## The standard arguments

Every module receives these from NixOS automatically:

- **`config`** — the fully merged config attrset (all modules combined). This is how a module reads what other modules set. `cfg = config.phix.nix` reads a value set somewhere else.
- **`lib`** — the nixpkgs library: `mkIf`, `mkOption`, `types`, etc.
- **`pkgs`** — the nixpkgs package set for the current system. `pkgs.ripgrep`, `pkgs.zsh`, `pkgs.git`, etc.
- **`options`** — the full merged options schema (rarely needed directly)
- **`...`** — ignores anything else NixOS passes (like `specialArgs`, etc.)

See: `modules/common/nix.nix`:
```nix
{ config, lib, pkgs, ... }:
```

## How NixOS collects and merges modules

When you run `nixos-rebuild switch --flake .#nixos-home`, NixOS:

1. Starts with the modules list from `lib.mkNixosHost` (`lib/default.nix`)
2. Recursively expands `imports` from each module
3. Calls every module function with `{ config, lib, pkgs, ... }`
4. Collects all `options` declarations into a merged schema
5. Collects all `config` values and deep-merges them
6. Resolves `mkIf`, `mkDefault`, `mkMerge` etc.
7. Validates every set value against its declared type
8. The result is your final system configuration

This happens in one giant lazy evaluation pass. Because Nix is lazy, a module
can read from `config` (the merged result) even while contributing to it —
Nix resolves the dependencies automatically.

## Why split into multiple modules?

You could write all your config in one giant file. It would work.
But modules give you:

**Reuse** — `modules/common/` applies to both `nixos-home` and `darwin-work`.
You don't copy-paste. Change it once, both machines update.

**Abstraction** — `modules/home/zsh.nix` hides the details of `programs.zsh`
behind `phix.zsh.*`. You set `phix.zsh.aliases`, not the 15 different
`programs.zsh` sub-options directly.

**Validation** — declaring options with types means Nix catches mistakes at
evaluation time. Set `phix.nix.gc.keepGenerations = "five"` and Nix errors
immediately: expected int, got string.

**Defaults** — options have defaults. You only need to set what differs.
`phix.nix.gc.enable` defaults to true, so you don't have to set it unless
you want to change it.

## A complete minimal example

```nix
# my-module.nix
{ config, lib, ... }:
let
  cfg = config.my.thing;
in
{
  options.my.thing = {
    enable = lib.mkEnableOption "my thing";
    name   = lib.mkOption {
      type    = lib.types.str;
      default = "world";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."hello".text = "hello, ${cfg.name}!";
  };
}
```

Then somewhere in your host config:

```nix
my.thing.enable = true;
my.thing.name   = "Philip";
```

Result: `/etc/hello` contains `"hello, Philip!"`

That's the whole pattern. `phix.nix`, `phix.zsh`, `phix.git` etc. all follow
exactly this structure.

## specialArgs

Some things can't come from `config` (like inputs from `flake.nix` — they exist
before modules are even loaded). These are passed via `specialArgs`.

From `lib/default.nix`:
```nix
specialArgs = { inherit inputs; };
```

This makes `inputs` available as an argument to every module:

```nix
{ inputs, config, lib, ... }:
{
  # use inputs.nixpkgs, inputs.home-manager, etc. directly
}
```

The difference from `config`: `specialArgs` values are static pass-through.
`config` values are the result of the module merge itself.
