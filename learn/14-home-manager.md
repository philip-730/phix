# 14 · home-manager

home-manager manages per-user configuration — dotfiles, user packages, shell
setup, editor config, etc. It's a separate project from NixOS but integrates
with it as a module.

- **NixOS** manages the system (kernel, services, /etc, system packages)
- **home-manager** manages the user (~/, user packages, dotfiles)

Open `lib/default.nix`, `modules/home/default.nix`, and `users/phil-personal.nix` alongside this.

## Two modes of home-manager

**Standalone** — home-manager runs independently, separate from NixOS.
You manage it yourself: `home-manager switch`. Used when you're on non-NixOS
(Arch, macOS without nix-darwin, etc.) or want user config completely separate
from system config.

**As a NixOS module** — home-manager is imported as a NixOS module and runs
as part of `nixos-rebuild`. Both system and user configs are built and activated
together. This is what phix does.

phix uses mode 2: `home-manager.nixosModules.home-manager` (for NixOS) and
`home-manager.darwinModules.home-manager` (for nix-darwin).
See: `lib/default.nix`.

## How home-manager is wired in

From `lib/default.nix` (NixOS path):

```nix
inputs.home-manager.nixosModules.home-manager
{
  home-manager = {
    useGlobalPkgs    = true;
    useUserPackages  = true;
    sharedModules    = [ ../modules/home ];
  };
}
```

This adds home-manager to NixOS as a module, then configures it.

## useGlobalPkgs

```nix
home-manager.useGlobalPkgs = true;
```

Makes home-manager use the same nixpkgs instance as NixOS.
Without this, home-manager brings its own copy of nixpkgs (a potential
version mismatch, and definitely a waste of evaluation time).
With it: one nixpkgs, consistent package versions everywhere.

## useUserPackages

```nix
home-manager.useUserPackages = true;
```

Installs user packages into the NixOS user profile instead of a separate
home-manager profile. This means `nix-env -q` and the system see the same
packages. Without it, user packages are in a separate profile that might not
be on PATH without extra config.

## sharedModules

```nix
home-manager.sharedModules = [ ../modules/home ];
```

Injects `modules/home/default.nix` into every user's home-manager config.
This is how `phix.zsh.*`, `phix.git.*`, `phix.packages.*`, `phix.editor.*` become
available to all users without repeating the imports in every user file.

`modules/home/default.nix` just imports the sub-modules:
```nix
{ ... }: {
  imports = [ ./zsh.nix ./git.nix ./packages.nix ./editor.nix ];
}
```

Users just set the options. See: `modules/home/default.nix`.

## Per-user config

Each user's config is assigned via:

```nix
home-manager.users.<username> = <module>;
```

From `hosts/mactan/default.nix`:

```nix
home-manager.users.philip = {
  imports = [ ../../users/phil-personal.nix ];
  ...
};
```

home-manager evaluates `phil-personal.nix` with the standard module args
(`{ pkgs, ... }`) plus the `sharedModules`, producing philip's home configuration.

## What home-manager options look like

Inside a user module (like `phil-personal.nix`), you can set:

```nix
programs.zsh.*          # configure zsh (home-manager option)
programs.git.*          # configure git
programs.helix.*        # configure helix editor
home.packages = [ ... ] # user packages
home.sessionVariables   # environment variables
home.stateVersion       # tracks home-manager migration compatibility
```

These are home-manager's own options (like `nix.settings.*` is NixOS's own options).
Your `phix.*` modules translate from `phix.zsh.*` → `programs.zsh.*`, etc.

Full option list: https://nix-community.github.io/home-manager/options.xhtml

## home.stateVersion

Both user files set:
```nix
home.stateVersion = "24.11";
```

This is NOT the version of home-manager to use. It's the version when you
first set up this user's config. home-manager uses it to handle migrations.

Set it once when you create the config. Don't update it unless you're
intentionally doing a migration. Just leave it.

## The module layering

For `mactan` / user `philip`, modules are evaluated in this order of layers:

```
NixOS layer:
  modules/common/nix.nix        (defines + implements phix.nix.*)
  hosts/mactan/default.nix      (sets networking, users, services, etc.)

home-manager layer (for user philip):
  modules/home/zsh.nix          (defines + implements phix.zsh.*)
  modules/home/git.nix          (defines + implements phix.git.*)
  modules/home/packages.nix     (defines + implements phix.packages.*)
  modules/home/editor.nix       (defines + implements phix.editor.*)
  modules/home/desktop.nix      (defines + implements phix.desktop.*)
  users/phil-personal.nix       (sets phix.zsh, phix.git, phix.packages, phix.editor)
```

The NixOS layer and home-manager layer are separate module evaluation contexts.
They share nixpkgs (via `useGlobalPkgs`) but have their own option namespaces.
`phix.nix.*` lives in the NixOS context. `phix.zsh.*` lives in the home context.
