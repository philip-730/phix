# 02 · Attrsets

An attrset (attribute set) is Nix's core data structure — a set of key-value
pairs. Almost everything in a Nix config is an attrset nested inside other attrsets.

When you write:

```nix
nix.settings.substituters = [ "https://cache.nixos.org" ];
```

That's not special syntax — it's just shorthand for a deeply nested attrset:

```nix
{ nix = { settings = { substituters = [...]; }; }; }
```

## Defining attrsets

```nix
basic = { a = 1; b = 2; c = 3; };

nested = {
  outer = {
    inner = "deep value";
  };
};
```

Dot-notation shorthand — these two are identical:

```nix
longForm  = { nix = { settings = { auto-optimise-store = true; }; }; };
shortForm = { nix.settings.auto-optimise-store = true; };
```

## Accessing values

Use dot notation to access a key.

```nix
person  = { name = "Philip"; age = 30; };
theName = { name = "Philip"; age = 30; }.name;  # → "Philip"

# In practice use let to avoid repeating yourself:
accessed = let p = { name = "Philip"; age = 30; }; in p.name;  # → "Philip"
```

## Checking if a key exists

The `?` operator returns true if a key exists in an attrset.

```nix
hasName = { name = "Philip"; } ? name;  # → true
hasAge  = { name = "Philip"; } ? age;   # → false

# With a default fallback using or:
ageOrDefault  = { name = "Philip"; }.age or 0;          # → 0
nameOrDefault = { name = "Philip"; }.name or "unknown"; # → "Philip"
```

## Merging attrsets with //

The `//` operator merges two attrsets. Right side wins on conflicts.
This is a **shallow** merge — nested keys are replaced, not merged.

```nix
base     = { a = 1; b = 2; };
override = { b = 99; c = 3; };
merged   = base // override;  # → { a = 1; b = 99; c = 3; }
```

Shallow merge gotcha — nested attrsets are replaced entirely:

```nix
defaults = { nix = { gc.enable = true; settings.auto-optimise-store = true; }; };
patch    = { nix = { gc.enable = false; }; };
shallow  = defaults // patch;
# → { nix = { gc.enable = false; } }  ← settings is GONE!
```

For deep merging, use `lib.recursiveUpdate` (covered in 12-mkhelpers.md).

## Listing keys

```nix
keys = builtins.attrNames { a = 1; b = 2; c = 3; };  # → [ "a" "b" "c" ]
```

## Dynamic key names

Key names can be computed with `${ }`.

```nix
dynamicKey =
  let fieldName = "greeting"; in
  { ${fieldName} = "hello"; };  # → { greeting = "hello"; }
```

## Why this matters for phix

Every line of config you write is an attrset. When you write:

```nix
phix.nix.enable = true;  # in hosts/nixos-home/default.nix
```

That desugars to:

```nix
{ phix = { nix = { enable = true; }; }; }
```

NixOS collects this attrset from every module and deep-merges them all into
one giant attrset. That merged result is your system configuration.

The dot-notation shorthand is just syntax sugar for nested attrsets — it
doesn't change the data structure at all.
