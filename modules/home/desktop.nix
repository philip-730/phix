{ config, lib, pkgs, ... }:

let
  cfg = config.phix.desktop;
in
{
  options.phix.desktop = {
    enable = lib.mkEnableOption "desktop environment (Hyprland, Waybar, wofi, yazi)";

    launcher = lib.mkOption {
      type = lib.types.enum [ "wofi" "rofi" ]; # rofi includes wayland support
      default = "wofi";
      description = "Application launcher to use.";
    };

    wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to wallpaper image (e.g. ~/wallpapers/wall.png).";
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
          "col.active_border" = "$accent";
          "col.inactive_border" = "$surface1";
        };

        decoration = {
          rounding = 10;
          # blur = {
          #   enabled = true;
          #   size = 3;
          #   passes = 1;
          # };
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
          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, L, movewindow, r"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, J, movewindow, d"
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"
          "$mod, S, exec, grim -g \"$(slurp)\" ~/Pictures/screenshots/$(date +%Y%m%d_%H%M%S).png"
          "$mod SHIFT, F, exec, grim ~/Pictures/screenshots/$(date +%Y%m%d_%H%M%S).png"
        ] ++ lib.optionals (cfg.launcher == "wofi") [
          "$mod, D, exec, wofi --show drun"
        ] ++ lib.optionals (cfg.launcher == "rofi") [
          "$mod, D, exec, rofi -show drun -show-icons"
        ];

        binde = [
          "$mod ALT, H, resizeactive, -20 0"
          "$mod ALT, L, resizeactive, 20 0"
          "$mod ALT, K, resizeactive, 0 -20"
          "$mod ALT, J, resizeactive, 0 20"
        ];

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        bindel = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
          ", XF86KbdBrightnessUp, exec, asusctl led next"
          ", XF86KbdBrightnessDown, exec, asusctl led prev"
        ];

        exec-once = [ "waybar" "swww-daemon" "hypridle" ]
          ++ lib.optional (cfg.wallpaper != null)
               "swww img ${toString cfg.wallpaper}"
          ++ lib.optional (cfg.wallpaper == null)
               "swww img ~/wallpapers/wall2.png";
      };
    };

    programs.waybar = {
      enable = true;
      settings = [{
        layer = "top";
        position = "top";
        spacing = 4;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "bluetooth" "battery" "network" "tray" ];

        "hyprland/workspaces" = {
          format = "{id}";
          on-click = "activate";
        };

        clock = {
          format = "󰃰 {:%a %b %d  %H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        battery = {
          states = { warning = 30; critical = 15; };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        };

        network = {
          format-wifi = "󰖩 {essid}";
          format-ethernet = "󰈀 eth";
          format-disconnected = "󰖪 disconnected";
          tooltip-format-wifi = "{signalStrength}% {frequency}MHz";
          on-click = "nm-connection-editor";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰖁 muted";
          format-icons = { default = [ "󰕿" "󰖀" "󰕾" ]; };
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };

        bluetooth = {
          format = "󰂯 {status}";
          format-connected = "󰂱 {device_alias}";
          format-connected-battery = "󰂱 {device_alias} {device_battery_percentage}%";
          on-click = "blueman-manager";
        };

        tray.spacing = 8;
      }];

      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: "JetBrainsMono Nerd Font", monospace;
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background: @base;
          color: @text;
          border-bottom: 2px solid @surface0;
        }

        #workspaces button {
          padding: 0 10px;
          color: @overlay0;
          background: transparent;
          border-radius: 6px;
          margin: 4px 2px;
        }

        #workspaces button.active {
          color: @base;
          background: @mauve;
        }

        #workspaces button:hover {
          color: @text;
          background: @surface0;
        }

        #workspaces,
        #clock,
        #battery,
        #network,
        #pulseaudio,
        #bluetooth,
        #tray {
          padding: 0 12px;
        }

        #clock            { color: @blue; }
        #battery          { color: @green; }
        #battery.warning  { color: @yellow; }
        #battery.critical { color: @red; }
        #network          { color: @sky; }
        #pulseaudio       { color: @pink; }
        #pulseaudio.muted { color: @overlay0; }
        #bluetooth        { color: @blue; }
        #bluetooth.connected { color: @green; }
        #tray             { color: @text; }
      '';
    };

    gtk = {
      enable = true;
      gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
    };

    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

    programs.yazi = {
      enable = true;
      keymap = {
        manager.prepend_keymap = [
          { on = [ "D" ]; run = ""; }
        ];
      };
    };

    programs.rofi = lib.mkIf (cfg.launcher == "rofi") {
      enable = true;
      package = pkgs.rofi;
    };

    programs.hyprlock = {
      enable = true;
      settings = {
        background = [{
          monitor = "";
          path = if cfg.wallpaper != null then toString cfg.wallpaper else "~/wallpapers/wall2.png";
          blur_passes = 3;
          blur_size = 7;
          brightness = 0.6;
        }];
      };
    };
    programs.btop.enable = true;

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "hyprlock";
          before_sleep_cmd = "hyprlock";
        };
        listener = [
          { timeout = 300; on-timeout = "hyprlock"; }
          { timeout = 600; on-timeout = "hyprctl dispatch dpms off"; on-resume = "hyprctl dispatch dpms on"; }
          { timeout = 900; on-timeout = "systemctl suspend"; }
        ];
      };
    };

    home.packages = lib.optionals (cfg.launcher == "wofi") [ pkgs.wofi ]
      ++ [
        pkgs.brightnessctl
        pkgs.swww           # wallpaper daemon
        pkgs.mako           # notifications
        pkgs.grim           # screenshots
        pkgs.slurp          # region select for screenshots
        pkgs.wl-clipboard   # clipboard
        pkgs.blueman        # bluetooth manager
        pkgs.networkmanagerapplet # wifi manager (tray)
      ];
  };
}
