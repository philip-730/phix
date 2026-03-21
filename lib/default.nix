{ inputs }:

let
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (inputs.nix-darwin.lib) darwinSystem;
in
rec {
  # Build a NixOS system configuration.
  # Args: { system, hostModule }
  mkNixosHost = { system, hostModule }:
    nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        # All common + NixOS modules
        ../modules/common
        ../modules/nixos

        # home-manager as a NixOS module
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [ ../modules/home ];
        }

        # Host-specific config
        hostModule
      ];
    };

  # Build a nix-darwin system configuration.
  # Args: { system, hostModule }
  mkDarwinHost = { system, hostModule }:
    darwinSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        # All common + Darwin modules
        ../modules/common
        ../modules/darwin

        # home-manager as a Darwin module
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [ ../modules/home ];
        }

        # Host-specific config
        hostModule
      ];
    };
}
