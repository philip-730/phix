{ config, lib, pkgs, ... }:

let
  cfg = config.phix.desktop;
in
{
  options.phix.desktop = {
    enable = lib.mkEnableOption "desktop environment (Hyprland, Waybar, wofi, yazi)";

    launcher = lib.mkOption {
      type = lib.types.enum [ "wofi" "rofi" ];
      default = "wofi";
      description = "Application launcher to use.";
    };

    wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to wallpaper image.";
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        "$mod" = "SUPER";

        monitor = [ ",preferred,auto,1" ];

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
        };

        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 3;
            passes = 1;
          };
        };

        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        bind = [
          "$mod, Return, exec, wezterm"
          "$mod, Q, killactive"
          "$mod, F, fullscreen"
          "$mod, Space, togglefloating"
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
        ] ++ lib.optionals (cfg.launcher == "wofi") [
          "$mod, D, exec, wofi --show drun"
        ] ++ lib.optionals (cfg.launcher == "rofi") [
          "$mod, D, exec, rofi -show drun"
        ];

        bindel = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ];

        exec-once = [ "waybar" ];
      };
    };

    programs.waybar = {
      enable = true;
      settings = [{
        layer = "top";
        position = "top";
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "battery" "network" "tray" ];
        clock.format = "{:%a %b %d  %H:%M}";
        battery = {
          format = "{capacity}% {icon}";
          format-icons = [ "" "" "" "" "" ];
        };
        network = {
          format-wifi = "{essid} ";
          format-ethernet = "eth ";
          format-disconnected = "disconnected";
        };
        pulseaudio.format = "{volume}% {icon}";
      }];
    };

    programs.yazi.enable = true;

    home.packages = lib.optionals (cfg.launcher == "wofi") [ pkgs.wofi ]
      ++ lib.optionals (cfg.launcher == "rofi") [ pkgs.rofi-wayland ]
      ++ [
        pkgs.brightnessctl
        pkgs.swww           # wallpaper daemon
        pkgs.mako           # notifications
        pkgs.grim           # screenshots
        pkgs.slurp          # region select for screenshots
        pkgs.wl-clipboard   # clipboard
      ];
  };
}
