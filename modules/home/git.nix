{ config, lib, pkgs, ... }:

let
  cfg = config.phix.git;
in
{
  options.phix.git = {
    enable = lib.mkEnableOption "git configuration";

    userName = lib.mkOption {
      type = lib.types.str;
      description = "Git commit author name.";
    };

    userEmail = lib.mkOption {
      type = lib.types.str;
      description = "Git commit author email.";
    };

    signingKey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "GPG or SSH key ID for commit signing. null disables signing.";
    };

    defaultBranch = lib.mkOption {
      type = lib.types.str;
      default = "main";
      description = "Default branch name for new repositories.";
    };

    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        st = "status";
        co = "checkout";
        br = "branch";
        lg = "log --oneline --graph --decorate";
        undo = "reset HEAD~1 --mixed";
      };
      description = "Git aliases.";
    };

    delta = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use delta as the git pager for improved diffs.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Additional git config attributes.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      aliases = cfg.aliases;

      signing = lib.mkIf (cfg.signingKey != null) {
        key = cfg.signingKey;
        signByDefault = true;
      };

      delta = lib.mkIf cfg.delta {
        enable = true;
        options = {
          navigate = true;
          side-by-side = true;
          line-numbers = true;
        };
      };

      extraConfig = lib.recursiveUpdate {
        init.defaultBranch = cfg.defaultBranch;
        pull.rebase = true;
        push.autoSetupRemote = true;
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
      } cfg.extraConfig;
    };
  };
}
