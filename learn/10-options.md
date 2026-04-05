# 10 · Declaring Options

The `options` block in a module is where you define the schema — what keys
exist under your namespace, what types they accept, and what their defaults are.

This is the "API" of your module. The `config` block is the implementation.

Open `modules/common/nix.nix` and `modules/home/zsh.nix` alongside this.

## lib.mkOption

```nix
lib.mkOption { type, default?, description?, example? }
```

Declares a single option. The most important fields:

- **`type`** — what kind of value is allowed (enforced at eval time)
- **`default`** — value used if nobody sets this option
- **`description`** — shown in `nixos-option` and documentation generators
- **`example`** — shown in docs, not enforced

## lib.mkEnableOption

Shorthand for a boolean enable flag that defaults to false.

```nix
enable = lib.mkEnableOption "description of what gets enabled";
```

Equivalent to:
```nix
enable = lib.mkOption {
  type    = lib.types.bool;
  default = false;
  description = "Whether to enable description of what gets enabled.";
};
```

Used in every phix module:
- `modules/common/nix.nix` — `phix.nix.enable`
- `modules/home/zsh.nix` — `phix.zsh.enable`
- `modules/home/git.nix` — `phix.git.enable`
- `modules/home/packages.nix` — `phix.packages.enable`
- `modules/home/editor.nix` — `phix.editor.enable`

## Common types

All types live under `lib.types.*`.

**`lib.types.bool`** → true or false
Used for: `gc.enable`, `helix.enable`, `showHiddenFiles`, etc.

**`lib.types.str`** → any string
Used for: `gc.frequency`, `initExtra`, etc.

**`lib.types.int`** → any integer
Used for: `gc.keepGenerations`, `historySize`, `tileSize`, `keyRepeatRate`

**`lib.types.listOf X`** → a list where every element is of type X

```nix
lib.types.listOf lib.types.str      # list of strings
lib.types.listOf lib.types.package  # list of derivations
```

Used for: `substituters`, `trustedPublicKeys`, `extra` (packages)

**`lib.types.attrsOf X`** → an attrset where every value is of type X

```nix
lib.types.attrsOf lib.types.str  # { ll = "eza -la"; cat = "bat"; }
```

Used for: `aliases`, `envVars`

**`lib.types.nullOr X`** → either null or a value of type X

Used for: `signingKey` — null means "no signing key configured".
In the config block, you check: `lib.mkIf (cfg.signingKey != null) { ... }`

**`lib.types.enum [ ... ]`** → one of a fixed set of string values

```nix
type = lib.types.enum [ "hx" "vim" "nano" "emacs" ];
```

Nix errors at eval time if you set a value not in the list.
Used for: `editor.default`, `finder.defaultViewStyle`

**`lib.types.package`** → a derivation (a Nix package)

```nix
lib.types.listOf lib.types.package  # means you pass [ pkgs.ripgrep pkgs.fd ]
```

**`lib.types.lines`** → a multi-line string (newlines are merged, not overwritten)

Used for: `initExtra` in zsh — multiple modules can append lines.

**`lib.types.attrs`** → any attrset (no type constraint on values)

Used for: `starship.settings`, open-ended config blobs where the structure
isn't known ahead of time.

## Nested options

Options can be nested just like regular attrsets:

```nix
options.phix.nix = {
  enable = lib.mkEnableOption "...";
  gc = {                              # nested group (not itself an option)
    enable    = lib.mkOption { ... };
    frequency = lib.mkOption { ... };
  };
};
```

This creates `phix.nix.gc.enable` and `phix.nix.gc.frequency` as separate options.
The `gc` attrset itself is not an option — it's just namespacing.
See: `modules/common/nix.nix`.

## What happens when you set a wrong type

If you set:

```nix
phix.nix.gc.keepGenerations = "five";  # string, but type is int
```

Nix will error immediately during `nixos-rebuild` evaluation:

```
error: The option `phix.nix.gc.keepGenerations' has unexpected type `string'.
       Expected `integer'.
```

Mistakes are caught early with a clear error pointing at the option.

## Options without defaults

If an option has no `default` and nobody sets it, Nix errors if the config
block tries to use it.

That's intentional for things like `userName` and `userEmail` in git — these
MUST be set per-user. If you enable `phix.git` but forget to set `userName`,
Nix errors during evaluation rather than silently producing a broken git config.
