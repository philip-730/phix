{ config, lib, pkgs, ... }:

let
  cfg = config.phix.editor;
in
{
  options.phix.editor = {
    enable = lib.mkEnableOption "editor configuration";

    default = lib.mkOption {
      type = lib.types.enum [ "nvim" "vim" "nano" "emacs" ];
      default = "nvim";
      description = "Default editor (sets EDITOR and VISUAL env vars).";
    };

    neovim = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install and configure neovim.";
      };
      defaultEditor = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Set neovim as the default editor.";
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.sessionVariables = {
        EDITOR = cfg.default;
        VISUAL = cfg.default;
      };
    }
    (lib.mkIf cfg.neovim.enable {
      programs.neovim = {
        enable = true;
        defaultEditor = cfg.neovim.defaultEditor;
        viAlias = true;
        vimAlias = true;
      };
    })
  ]);
}
