# 05 · let, inherit, with, rec

These are the main ways Nix lets you name things, avoid repetition, and build
up values from other values. You'll see all of these in phix.

## let ... in

`let` creates local bindings (named variables) for use in the expression after `in`.
It's NOT a statement — the whole thing is a single expression.

Syntax: `let name = value; ... in expression`

```nix
simple = let x = 10; in x * 2;  # → 20

multiple = let
  a = 5;
  b = 3;
in a + b;  # → 8
```

`let` bindings can reference each other:

```nix
chained = let
  base    = 10;
  doubled = base * 2;
  msg     = "value is ${toString doubled}";
in msg;  # → "value is 20"
```

Deeply nested — very common in module files:

```nix
withNested = let
  cfg  = { gc.enable = true; gc.keepGenerations = 5; };
  keep = cfg.gc.keepGenerations;
in "--delete-older-than +${toString keep}";
# → "--delete-older-than +5"
```

This exact pattern is in `modules/common/nix.nix`:
```nix
let cfg = config.phix.nix; in
...
options = "--delete-older-than +${toString cfg.gc.keepGenerations}";
```

## inherit

`inherit` is shorthand for "copy a name from the current scope into an attrset".
It reduces repetition.

```
inherit x;          is the same as  x = x;
inherit (src) x y;  is the same as  x = src.x;  y = src.y;
```

```nix
withInherit =
  let name = "Philip"; age = 30;
  in { inherit name age; };
# → { name = "Philip"; age = 30; }
# Without inherit: { name = name; age = age; } — same thing, more noise.
```

Inherit from a source attrset:

```nix
inheritFrom =
  let person = { name = "Philip"; age = 30; city = "NY"; };
  in { inherit (person) name age; };  # only pick name and age
# → { name = "Philip"; age = 30; }
```

Common in `flake.nix` and lib files:

```nix
let
  inherit (inputs.nixpkgs.lib) nixosSystem;    # same as: nixosSystem = inputs.nixpkgs.lib.nixosSystem;
  inherit (inputs.nix-darwin.lib) darwinSystem;
in ...
```

See: `lib/default.nix:4-5`

Also in `specialArgs` — passing inputs down to all modules:
```nix
specialArgs = { inherit inputs; };  # same as: { inputs = inputs; }
```

## with

`with attrset; expression` brings all keys of the attrset into scope.
Use sparingly — it makes it hard to tell where names come from.
Most common use: `with pkgs; [ ripgrep fd bat ]` in package lists.

```nix
withExample =
  with { a = 1; b = 2; c = 3; };
  a + b + c;  # → 6
```

Without `with` you'd have to write `{ a = 1; b = 2; c = 3; }.a + ...` every time.
That's why `with pkgs;` is useful for long package lists.

## rec — self-referencing attrsets

Normally attrsets can't reference their own keys. `rec` enables that.

```nix
selfRef = rec {
  base    = 10;
  doubled = base * 2;  # can reference `base` because it's rec
  msg     = "base=${toString base} doubled=${toString doubled}";
};
# → { base = 10; doubled = 20; msg = "base=10 doubled=20" }
```

`rec` is less common in configs but you'll see it in lib files.

## toString

Nix strings don't auto-coerce numbers. You need `toString` to embed them.
This is why `modules/common/nix.nix` uses:

```nix
options = "--delete-older-than +${toString cfg.gc.keepGenerations}";
```

Without `toString`, Nix would error when trying to interpolate an int.

```nix
numToStr = toString 42;           # → "42"
intInStr = "value: ${toString 5}"; # → "value: 5"
```
