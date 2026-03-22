# ── 04 · Functions ─────────────────────────────────────────────────────────────
#
# Nix is a functional language — functions are values, just like strings or
# numbers. You'll encounter them everywhere: every module is a function, every
# helper in lib/ is a function, pkgs.mkShell is a function.
#
# Run: nix eval --file learn/04-functions.nix
#
# ──────────────────────────────────────────────────────────────────────────────

{
  # ── Single-argument functions ─────────────────────────────────────────────────
  #
  # Syntax: arg: body
  # The colon separates the argument name from the expression it evaluates to.

  double   = x: x * 2;
  addThree = x: x + 3;
  greet    = name: "hello, ${name}!";

  # Calling a function — just put the argument after it, no parentheses needed
  result1 = (x: x * 2) 5;     # → 10
  result2 = (x: x + 3) 10;    # → 13

  # Assigning a function to a name, then calling it:
  doubleResult =
    let double = x: x * 2;
    in double 7;  # → 14

  # ── Multiple arguments — currying ─────────────────────────────────────────────
  #
  # Nix functions only take ONE argument. To take multiple, you return a function
  # that takes the next argument. This is called currying.

  add = a: b: a + b;
  # add is a function that takes a, returns a function that takes b, returns a+b

  addResult    = (a: b: a + b) 3 5;   # → 8   (call with 3, then call result with 5)
  addPartial   = (a: b: a + b) 3;     # → a function waiting for b
  addCompleted = ((a: b: a + b) 3) 5; # → 8   (same as above, explicit)

  # ── Named-argument functions (attrset destructuring) ──────────────────────────
  #
  # Instead of currying, most Nix code uses a SINGLE attrset argument and
  # destructures it. This is how every NixOS module is written.
  #
  # Syntax: { arg1, arg2 }: body

  greetFull = { first, last }: "hello, ${first} ${last}!";
  greetResult = greetFull { first = "Philip"; last = "A"; };
  # → "hello, Philip A!"

  # ── Default values in named args ─────────────────────────────────────────────

  withDefaults = { name, greeting ? "hello" }: "${greeting}, ${name}!";
  defaultUsed  = withDefaults { name = "Philip"; };           # → "hello, Philip!"
  defaultSkip  = withDefaults { name = "Philip"; greeting = "hey"; };  # → "hey, Philip!"

  # ── The ... (ellipsis) — ignore extra args ────────────────────────────────────
  #
  # { arg1, ... } means "take arg1, ignore everything else".
  # This is CRITICAL for NixOS modules. Every module receives a big attrset of
  # { config, lib, pkgs, options, ... } — most modules only use a few of these,
  # so they use ... to ignore the rest.
  #
  # See: modules/common/nix.nix:1
  #   { config, lib, pkgs, ... }:
  #
  # The ... means "I know there are other args like `options`, but I don't need them."
  # Without ..., Nix would error if the caller passed extra keys.

  ignoreExtra = { a, ... }: a * 2;
  extraResult = ignoreExtra { a = 5; b = 99; c = "ignored"; };  # → 10

  # ── The @ pattern — name the whole attrset too ───────────────────────────────
  #
  # { arg1, ... }@args — destructure AND give the whole set a name.
  # Lets you use arg1 directly AND pass the full set somewhere else.

  withAt = { name, ... }@all: { inherit name; fullSet = all; };
  atResult = withAt { name = "Philip"; extra = "yes"; };
  # → { name = "Philip"; fullSet = { name = "Philip"; extra = "yes"; }; }

  # ── Functions as values ───────────────────────────────────────────────────────
  #
  # Functions are just values. You can put them in attrsets, pass them around,
  # return them from other functions. This is how lib/ works.
  #
  # See: lib/default.nix — it's a function that takes { inputs } and returns
  # an attrset containing mkNixosHost and mkDarwinHost, which are themselves
  # functions.
  #
  #   { inputs }:
  #   {
  #     mkNixosHost = { system, hostModule, wsl ? false }: nixosSystem { ... };
  #     mkDarwinHost = { system, hostModule }: darwinSystem { ... };
  #   }
  #
  # Then in flake.nix:
  #   lib = import ./lib { inherit inputs; };  # call the outer function
  #   lib.mkNixosHost { system = ...; ... };   # call the inner function

  # ── if/then/else ─────────────────────────────────────────────────────────────
  #
  # Nix has no statements — if/then/else is an EXPRESSION, it always returns a value.

  ifResult  = if true then "yes" else "no";   # → "yes"
  ternary   = let x = 10; in if x > 5 then "big" else "small";  # → "big"

  # Used in lib/default.nix:28 to conditionally add WSL modules:
  #   ] ++ (if wsl then [ inputs.nixos-wsl.nixosModules.default ] else []) ++ [
}
