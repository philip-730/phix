# ── 01 · Values ────────────────────────────────────────────────────────────────
#
# Nix is a pure, lazy, functional language. Everything evaluates to a value.
# There are no statements — only expressions that produce a result.
#
# HOW TO USE THIS FILE
# This file is a valid Nix expression (an attrset of examples).
# You can evaluate it directly:
#
#   nix eval --file learn/01-values.nix
#
# That prints all the keys and their computed values. Try changing a value and
# re-running to see the result.
#
# ── What is nix eval? ──────────────────────────────────────────────────────────
#
# `nix eval` takes a Nix expression and prints what it evaluates to.
# It's the fastest way to experiment with the language without building anything.
#
#   nix eval --expr '1 + 1'          # → 2
#   nix eval --expr '"hello" + " world"'  # → "hello world"
#   nix eval --file learn/01-values.nix  # evaluates this whole file
#
# ──────────────────────────────────────────────────────────────────────────────

{
  # ── Strings ──────────────────────────────────────────────────────────────────

  # Double-quoted strings. Standard.
  basicString = "hello nix";

  # String interpolation: embed any expression with ${ }
  name = "Philip";
  greeting = "hello, ${"Philip"}";           # → "hello, Philip"
  greetingWithVar = let n = "Philip"; in "hello, ${n}";  # same thing

  # Multiline strings use '' (two single-quotes). Leading whitespace is stripped
  # based on the least-indented line — so indentation in the file doesn't matter.
  multiline = ''
    line one
    line two
    line three
  '';
  # → "line one\nline two\nline three\n"

  # Paths are a distinct type — no quotes, must contain a /
  # Relative paths are resolved relative to the file they appear in.
  thisDir  = ./.;       # the directory this file lives in
  flakeNix = ../flake.nix;  # relative to this file → phix/flake.nix

  # ── Numbers ──────────────────────────────────────────────────────────────────

  anInt    = 42;
  negative = -7;
  aFloat   = 3.14;
  sum      = 1 + 2;       # → 3
  product  = 6 * 7;       # → 42
  quotient = 10 / 2;      # → 5 (integer division)

  # ── Booleans ─────────────────────────────────────────────────────────────────

  yes  = true;
  no   = false;
  and  = true && false;   # → false
  or   = true || false;   # → true
  not  = !true;           # → false
  eq   = 1 == 1;          # → true
  neq  = 1 != 2;          # → true
  gt   = 5 > 3;           # → true

  # ── Null ─────────────────────────────────────────────────────────────────────

  # null means "no value". Used in options to represent "not set".
  # See: modules/home/git.nix — signingKey defaults to null (no signing key).
  nothing = null;
  isNull  = null == null;  # → true

  # ── Type checking ─────────────────────────────────────────────────────────────
  #
  # builtins.typeOf tells you what type a value is.
  # You won't use this much in config, but it helps when learning.

  typeOfString = builtins.typeOf "hello";  # → "string"
  typeOfInt    = builtins.typeOf 42;       # → "int"
  typeOfBool   = builtins.typeOf true;     # → "bool"
  typeOfNull   = builtins.typeOf null;     # → "null"
  typeOfPath   = builtins.typeOf ./.;      # → "path"
}
