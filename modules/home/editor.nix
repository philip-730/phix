{ config, lib, pkgs, ... }:

let
  cfg = config.phix.editor;
in
{
  options.phix.editor = {
    enable = lib.mkEnableOption "editor configuration";

    default = lib.mkOption {
      type = lib.types.enum [ "hx" "vim" "nano" "emacs" ];
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
        settings = {
          editor = {
            true-color = true;
            line-number = "absolute";
            mouse = false;
            cursorline = true;
            color-modes = true;
            idle-timeout = 50;
            cursor-shape = {
              insert = "bar";
              normal = "block";
              select = "underline";
            };
            soft-wrap = {
              enable = true;
              wrap-indicator = "↩ ";
            };
            lsp = {
              display-inlay-hints = true;
              display-messages = true;
            };
          };
        };
        languages = {
          language-server.ruff = {
            command = "ruff";
            args = [ "server" ];
          };
          language-server.terraform-ls = {
            command = "terraform-ls";
            args = [ "serve" ];
          };
          language-server.typescript-language-server = {
            command = "typescript-language-server";
            args = [ "--stdio" ];
          };
          language = [
            {
              name = "python";
              language-servers = [ "ruff" "pyright" ];
            }
            {
              name = "nix";
              formatter = { command = "nixfmt"; };
            }
            {
              name = "javascript";
              file-types = [ "js" "mjs" "cjs" ];
              language-servers = [ "typescript-language-server" ];
            }
            {
              name = "hcl";
              language-servers = [ "terraform-ls" ];
              language-id = "terraform-vars";
            }
            {
              name = "tfvars";
              language-servers = [ "terraform-ls" ];
              language-id = "terraform-vars";
            }
          ];
        };
      };
    })
  ]);
}
