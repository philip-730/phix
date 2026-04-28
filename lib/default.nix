{ inputs }:

let
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (inputs.nix-darwin.lib) darwinSystem;
in
{
  # Build a NixOS system configuration.
  # Args: { system, hostModule, wsl? }
  mkNixosHost =
    {
      system,
      hostModule,
      wsl ? false,
    }:
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
          nixpkgs.config.allowUnfree = true;
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "bak";
            sharedModules = [
              ../modules/home
              inputs.catppuccin.homeManagerModules.catppuccin
            ];
          };
        }

        # WSL support
      ]
      ++ (if wsl then [ inputs.nixos-wsl.nixosModules.default ] else [ ])
      ++ [

        # Host-specific config
        hostModule
      ];
    };

  # Build a nix-darwin system configuration.
  # Args: { system, hostModule }
  mkDarwinHost =
    { system, hostModule }:
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
          nixpkgs.config.allowUnfree = true;
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "bak";
            sharedModules = [
              ../modules/home
              inputs.catppuccin.homeManagerModules.catppuccin
            ];
          };
        }

        # Host-specific config
        hostModule
      ];
    };
}
