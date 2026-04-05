# 03 · Lists

Lists are ordered sequences of values. They show up constantly in Nix configs:
packages to install, binary caches, enabled features, file paths, etc.

## Defining lists

Square brackets, space-separated (NO commas).

```nix
numbers = [ 1 2 3 4 5 ];
strings = [ "a" "b" "c" ];
mixed   = [ 1 "two" true null ];  # lists can hold any type
```

From phix — this is how substituters are defined. See: `modules/common/nix.nix`.

```nix
substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
```

## Concatenating lists with ++

```nix
base  = [ 1 2 3 ];
extra = [ 4 5 6 ];
both  = base ++ extra;  # → [ 1 2 3 4 5 6 ]
```

This pattern is everywhere in phix. See: `modules/home/packages.nix`.

```nix
home.packages = lib.optionals cfg.core [ pkgs.ripgrep pkgs.fd ... ]
                ++ cfg.extra;
```

`optionals` returns the list if the condition is true, `[]` otherwise.
Then `++` appends whatever extra packages the user added.

## Useful builtins

```nix
len   = builtins.length [ "a" "b" "c" ];        # → 3
first = builtins.elemAt [ "a" "b" "c" ] 0;      # → "a"
third = builtins.elemAt [ "a" "b" "c" ] 2;      # → "c"
hasB  = builtins.elem "b" [ "a" "b" "c" ];      # → true
hasZ  = builtins.elem "z" [ "a" "b" "c" ];      # → false
head  = builtins.head [ 10 20 30 ];              # → 10
tail  = builtins.tail [ 10 20 30 ];              # → [ 20 30 ]
```

## map — transform every element

`map` takes a function and a list, applies the function to each element.

```nix
doubled = map (x: x * 2) [ 1 2 3 4 ];
# → [ 2 4 6 8 ]

upcased = map (s: "pkg-${s}") [ "git" "vim" "zsh" ];
# → [ "pkg-git" "pkg-vim" "pkg-zsh" ]
```

## filter — keep elements that match a condition

```nix
evens = builtins.filter (x: builtins.mod x 2 == 0) [ 1 2 3 4 5 6 ];
# → [ 2 4 6 ]
```

## lib.optionals — conditional list

```
lib.optionals condition list
  → list  if condition is true
  → []    if condition is false
```

You'll see this constantly in phix:

```nix
someList = lib.optionals enableThing [ "thing-a" "thing-b" ]
           ++ lib.optionals enableOther [ "other-a" ]
           ++ extraItems;
```

Lets you conditionally include groups of items without lots of if/else.
See: `modules/home/packages.nix` and `lib/default.nix` (WSL modules).

## Lists containing attrsets

Lists can contain attrsets — this is how NixOS modules are passed around.
See: `lib/default.nix` — the modules list is a list of paths and attrsets:

```nix
modules = [
  ../modules/common          # a path (Nix loads the file)
  ../modules/nixos           # a path
  { home-manager.useGlobalPkgs = true; }  # an inline attrset
  hostModule                 # a variable holding a path
];
```

NixOS accepts any of these as a "module" — path, attrset, or function.

## builtins.concatLists — flatten one level

```nix
flat = builtins.concatLists [ [ 1 2 ] [ 3 4 ] [ 5 ] ];  # → [ 1 2 3 4 5 ]
```
