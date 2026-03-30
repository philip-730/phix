{ config, lib, pkgs, ... }:

let
  cfg = config.phix.wezterm;
in
{
  options.phix.wezterm = {
    enable = lib.mkEnableOption "WezTerm terminal emulator";

    font = lib.mkOption {
      type = lib.types.str;
      default = "JetBrainsMono Nerd Font";
      description = "Font family to use.";
    };

    fontSize = lib.mkOption {
      type = lib.types.float;
      default = 13.0;
      description = "Font size in points.";
    };

    opacity = lib.mkOption {
      type = lib.types.float;
      default = 1.0;
      description = "Window background opacity (0.0–1.0).";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra Lua config appended to the WezTerm configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.enable = true;

    programs.wezterm = {
      enable = true;
      extraConfig = ''
        local config = wezterm.config_builder()

        config.font = wezterm.font("${cfg.font}")
        config.font_size = ${toString cfg.fontSize}
        config.window_background_opacity = ${toString cfg.opacity}
        config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
        config.scrollback_lines = 10000
        config.audible_bell = "Disabled"
        config.window_decorations = "RESIZE"
        config.inactive_pane_hsb = { brightness = 0.7, saturation = 0.9, hue = 1.0 }

        ${cfg.extraConfig}

        return config
      '';
    };

    xdg.desktopEntries.wezterm = {
      name = "WezTerm";
      exec = "wezterm start";
      icon = "wezterm";
      comment = "WezTerm terminal emulator";
      categories = [ "System" "TerminalEmulator" ];
    };
  };
}
