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

    colorScheme = lib.mkOption {
      type = lib.types.str;
      default = "Tokyo Night";
      description = "WezTerm color scheme name.";
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
    programs.wezterm = {
      enable = true;
      extraConfig = ''
        local config = wezterm.config_builder()

        config.enable_tab_bar = false
        config.font = wezterm.font("${cfg.font}")
        config.font_size = ${toString cfg.fontSize}
        config.color_scheme = "${cfg.colorScheme}"
        config.window_background_opacity = ${toString cfg.opacity}
        config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
        config.cursor_blink_rate = 0
        config.scrollback_lines = 10000
        config.audible_bell = "Disabled"

        ${cfg.extraConfig}

        return config
      '';
    };
  };
}
