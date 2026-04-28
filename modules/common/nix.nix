{ config, lib, pkgs, ... }:

let
  cfg = config.phix.nix;
  gcIntervalFromFrequency =
    if cfg.gc.frequency == "weekly" then
      { Weekday = 0; Hour = 3; Minute = 15; }
    else if cfg.gc.frequency == "daily" then
      { Hour = 3; Minute = 15; }
    else if cfg.gc.frequency == "monthly" then
      { Day = 1; Hour = 3; Minute = 15; }
    else
      { Weekday = 0; Hour = 3; Minute = 15; };
in
{
  options.phix.nix = {
    enable = lib.mkEnableOption "Nix daemon and settings configuration";

    gc = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable automatic garbage collection.";
      };
      frequency = lib.mkOption {
        type = lib.types.str;
        default = "weekly";
        description = "How often to run nix gc (systemd calendar format on NixOS, preset mapping on Darwin).";
      };
      keepGenerations = lib.mkOption {
        type = lib.types.int;
        default = 5;
        description = "Number of system generations to keep.";
      };
    };

    substituters = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "https://cache.nixos.org" ];
      description = "Binary caches to use.";
    };

    trustedPublicKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      description = "Trusted public keys for binary caches.";
    };
  };

  config = lib.mkIf cfg.enable {
    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        substituters = cfg.substituters;
        trusted-public-keys = cfg.trustedPublicKeys;
        auto-optimise-store = true;
      };

      gc = lib.mkIf cfg.gc.enable {
        automatic = true;
        options = "--delete-older-than ${toString cfg.gc.keepGenerations}d";
      } // (
        if pkgs.stdenv.isDarwin then
          { interval = gcIntervalFromFrequency; }
        else
          { dates = cfg.gc.frequency; }
      );
    };
  };
}
