{ config, lib, pkgs, ... }:

let
  cfg = config.phix.packages;
in
{
  options.phix.packages = {
    enable = lib.mkEnableOption "user package management";

    core = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install a curated set of core CLI tools (ripgrep, fd, bat, eza, jq, etc.).";
    };

    extra = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional packages to install for this user.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.bat.enable = lib.mkIf cfg.core true;
    programs.eza.enable = lib.mkIf cfg.core true;

    home.packages = lib.optionals cfg.core [
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.ripgrep
      pkgs.fd
      pkgs.jq
      pkgs.yq-go
      pkgs.curl
      pkgs.wget
      pkgs.htop
      pkgs.tree
      pkgs.unzip
      pkgs.zip
      pkgs.gh # GitHub CLI
      pkgs.just # command runner
      pkgs.hyperfine # benchmarking
      pkgs.fastfetch
      pkgs.nil
      pkgs.nixfmt
      pkgs.ruff
      pkgs.pyright
      pkgs.terraform-ls
      pkgs.vscode-langservers-extracted
      pkgs.typescript-language-server
    ] ++ cfg.extra;
  };
}
