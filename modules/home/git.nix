{ config, lib, pkgs, ... }:
let
  cfg = config.phix.git;
in
{
  options.phix.git = {
    enable = lib.mkEnableOption "git configuration";
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Raw git settings passed through to programs.git.settings.";
    };
    signing = {
      format = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum [ "openpgp" "ssh" "x509" ]);
        default = null;
      };
      key = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      signByDefault = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
      };
    };
    # delta = lib.mkOption {
    #   type = lib.types.bool;
    #   default = false;
    #   description = "Use delta as the git pager for improved diffs.";
    # };
    # aliases = lib.mkOption {
    #   type = lib.types.attrsOf lib.types.str;
    #   default = {};
    #   description = "Git aliases.";
    # };
    # extraConfig = lib.mkOption {
    #   type = lib.types.attrs;
    #   default = {};
    #   description = "Additional git config attributes.";
    # };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = cfg.settings;
      signing = {
        format = cfg.signing.format;
        key = cfg.signing.key;
        signByDefault = cfg.signing.signByDefault;
      };
      # delta = lib.mkIf cfg.delta {
      #   enable = true;
      #   options = {
      #     navigate = true;
      #     side-by-side = true;
      #     line-numbers = true;
      #   };
      # };
      # aliases = cfg.aliases;
      # extraConfig = cfg.extraConfig;
    };
  };
}
