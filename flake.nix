{
  description = "phix - Phil's Nix configs and toolset";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }@inputs:
    let
      lib = import ./lib { inherit inputs; };
    in
    {
      nixosConfigurations = {
        nixos-home = lib.mkNixosHost {
          system = "x86_64-linux";
          hostModule = ./hosts/nixos-home;
          wsl = true;
        };

        mactan = lib.mkNixosHost {
          system = "x86_64-linux";
          hostModule = ./hosts/mactan;
        };
      };

      darwinConfigurations = {
        darwin-work = lib.mkDarwinHost {
          system = "aarch64-darwin";
          hostModule = ./hosts/darwin-work;
        };
      };

      # Dev shell for working on configs: nil (LSP), formatter, linter
      devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = [
              pkgs.nil
              pkgs.nixfmt
              pkgs.statix
              pkgs.deadnix
            ];
          };
        }
      );
    };
}
