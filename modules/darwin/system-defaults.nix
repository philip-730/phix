{ config, lib, ... }:

let
  cfg = config.phix.systemDefaults;
in
{
  options.phix.systemDefaults = {
    enable = lib.mkEnableOption "macOS system defaults configuration";

    dock = {
      autohide = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Automatically hide and show the Dock.";
      };
      largeSize = lib.mkOption {
        type = lib.types.int;
        default = 36;
        description = "Dock icon size when magnified.";
      };
      tileSize = lib.mkOption {
        type = lib.types.int;
        default = 48;
        description = "Dock icon size.";
      };
      showRecentApps = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Show recent apps in the Dock.";
      };
    };

    finder = {
      showHiddenFiles = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show hidden files in Finder.";
      };
      showPathBar = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show the path bar in Finder.";
      };
      defaultViewStyle = lib.mkOption {
        type = lib.types.enum [ "icnv" "clmv" "Nlsv" "glyv" ];
        default = "clmv";
        description = "Default Finder view style (icnv=icon, clmv=column, Nlsv=list, glyv=gallery).";
      };
    };

    keyboard = {
      keyRepeatRate = lib.mkOption {
        type = lib.types.int;
        default = 2;
        description = "Key repeat rate (lower = faster).";
      };
      initialKeyRepeatDelay = lib.mkOption {
        type = lib.types.int;
        default = 15;
        description = "Initial key repeat delay (lower = shorter delay).";
      };
      automaticPeriodSubstitution = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether macOS auto-converts double-space to period.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    system.defaults = {
      dock = {
        autohide = cfg.dock.autohide;
        largesize = cfg.dock.largeSize;
        tilesize = cfg.dock.tileSize;
        show-recents = cfg.dock.showRecentApps;
      };
      finder = {
        AppleShowAllFiles = cfg.finder.showHiddenFiles;
        ShowPathbar = cfg.finder.showPathBar;
        FXPreferredViewStyle = cfg.finder.defaultViewStyle;
      };
      NSGlobalDomain = {
        KeyRepeat = cfg.keyboard.keyRepeatRate;
        InitialKeyRepeat = cfg.keyboard.initialKeyRepeatDelay;
        NSAutomaticPeriodSubstitutionEnabled = cfg.keyboard.automaticPeriodSubstitution;
      };
    };
  };
}
