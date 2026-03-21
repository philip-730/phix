{ config, lib, ... }:

let
  cfg = config.phix.zsh;
in
{
  options.phix.zsh = {
    enable = lib.mkEnableOption "zsh configuration";

    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Shell aliases to define.";
      example = { ll = "ls -la"; gs = "git status"; };
    };

    initExtra = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra commands to add to .zshrc.";
    };

    envVars = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Environment variables to export in the shell.";
    };

    historySize = lib.mkOption {
      type = lib.types.int;
      default = 10000;
      description = "Number of history entries to keep.";
    };

    starship = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable starship prompt.";
      };

      settings = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Starship configuration (see starship.rs/config).";
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      programs.zsh = {
        enable = true;
        shellAliases = cfg.aliases;
        initExtra = cfg.initExtra;
        history = {
          size = cfg.historySize;
          save = cfg.historySize;
          ignoreDups = true;
          share = true;
        };
        sessionVariables = cfg.envVars;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        enableCompletion = true;
      };
    }
    (lib.mkIf cfg.starship.enable {
      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        settings = cfg.starship.settings;
      };
    })
  ]);
}
