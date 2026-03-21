{ config, lib, ... }:

let
  cfg = config.phix.homebrew;
in
{
  options.phix.homebrew = {
    enable = lib.mkEnableOption "Homebrew integration";

    casks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Homebrew casks to install (GUI apps not available in nixpkgs).";
    };

    brews = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Homebrew formulae to install.";
    };

    masApps = lib.mkOption {
      type = lib.types.attrsOf lib.types.int;
      default = {};
      description = "Mac App Store apps to install via mas, as { name = id; }.";
    };

    onActivation = {
      cleanup = lib.mkOption {
        type = lib.types.enum [ "none" "uninstall" "zap" ];
        default = "uninstall";
        description = "What to do with packages no longer declared on activation.";
      };
      autoUpdate = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Auto-update Homebrew on activation.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      casks = cfg.casks;
      brews = cfg.brews;
      masApps = cfg.masApps;
      onActivation = {
        cleanup = cfg.onActivation.cleanup;
        autoUpdate = cfg.onActivation.autoUpdate;
      };
    };
  };
}
