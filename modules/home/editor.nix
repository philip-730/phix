{ config, lib, pkgs, ... }:

let
  cfg = config.phix.editor;
in
{
  options.phix.editor = {
    enable = lib.mkEnableOption "editor configuration";

    default = lib.mkOption {
      type = lib.types.enum [ "hx" "nvim" "vim" "nano" "emacs" ];
      default = "hx";
      description = "Default editor (sets EDITOR and VISUAL env vars).";
    };

    helix = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install and configure helix.";
      };
    };

    neovim = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install and configure neovim.";
      };
      defaultEditor = lib.mkOption {
        type = lib.types.bool;
        default = false;
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
    (lib.mkIf cfg.helix.enable {
      programs.helix = {
        enable = true;
      };
    })
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
