{ config, lib, pkgs, ... }:

let
  cfg = config.phix.desktop;
in
{
  options.phix.desktop = {
    enable = lib.mkEnableOption "desktop environment configuration";

    compositor = lib.mkOption {
      type = lib.types.enum [ "none" "hyprland" "gnome" "plasma" ];
      default = "none";
      description = "Desktop compositor / environment to configure.";
    };

    xserver = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable X11 display server (required for non-Wayland compositors).";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf (cfg.compositor == "hyprland") {
      programs.hyprland.enable = true;
    })
    (lib.mkIf (cfg.compositor == "gnome") {
      services.xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };
    })
    (lib.mkIf (cfg.compositor == "plasma") {
      services.xserver = {
        enable = true;
        displayManager.sddm.enable = true;
        desktopManager.plasma5.enable = true;
      };
    })
    (lib.mkIf cfg.xserver {
      services.xserver.enable = true;
    })
  ]);
}
