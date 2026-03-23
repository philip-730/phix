{ config, lib, pkgs, ... }:

let
  cfg = config.phix.wezterm;
in
{
  options.phix.wezterm = {
    enable = lib.mkEnableOption "WezTerm terminal emulator";

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

        ${cfg.extraConfig}

        return config
      '';
    };
  };
}
