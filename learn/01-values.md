# 01 · Values

Nix is a pure, lazy, functional language. Everything evaluates to a value.
There are no statements — only expressions that produce a result.

You can experiment with values using `nix eval`:

```
nix eval --expr '1 + 1'                    # → 2
nix eval --expr '"hello" + " world"'       # → "hello world"
```

## Strings

Double-quoted strings are standard.

```nix
basicString = "hello nix";
```

String interpolation: embed any expression with `${ }`.

```nix
name = "Philip";
greeting = "hello, ${"Philip"}";                      # → "hello, Philip"
greetingWithVar = let n = "Philip"; in "hello, ${n}"; # same thing
```

Multiline strings use `''` (two single-quotes). Leading whitespace is stripped
based on the least-indented line — so indentation in the file doesn't matter.

```nix
multiline = ''
  line one
  line two
  line three
'';
# → "line one\nline two\nline three\n"
```

## Paths

Paths are a distinct type — no quotes, must contain a `/`.
Relative paths are resolved relative to the file they appear in.

```nix
thisDir  = ./.;           # the directory this file lives in
flakeNix = ../flake.nix;  # relative to this file → phix/flake.nix
```

## Numbers

```nix
anInt    = 42;
negative = -7;
aFloat   = 3.14;
sum      = 1 + 2;    # → 3
product  = 6 * 7;    # → 42
quotient = 10 / 2;   # → 5 (integer division)
```

## Booleans

```nix
yes = true;
no  = false;
and = true && false;  # → false
or  = true || false;  # → true
not = !true;          # → false
eq  = 1 == 1;         # → true
neq = 1 != 2;         # → true
gt  = 5 > 3;          # → true
```

## Null

`null` means "no value". Used in options to represent "not set".
See: `modules/home/git.nix` — `signingKey` defaults to null (no signing key).

```nix
nothing = null;
isNull  = null == null;  # → true
```

## Type checking

`builtins.typeOf` tells you what type a value is. Useful when learning.

```nix
typeOfString = builtins.typeOf "hello";  # → "string"
typeOfInt    = builtins.typeOf 42;       # → "int"
typeOfBool   = builtins.typeOf true;     # → "bool"
typeOfNull   = builtins.typeOf null;     # → "null"
typeOfPath   = builtins.typeOf ./.;      # → "path"
```
