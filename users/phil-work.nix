# Work identity and preferences for the Darwin work machine.
# Username: philipamendolia
{ pkgs, ... }: {
  home.stateVersion = "24.11";

  phix.git = {
    enable = true;
    userName = "Philip Amendolia";
    userEmail = "philip@work.com"; # replace with your actual work email
  };

  phix.zsh = {
    enable = true;
    aliases = {
      ll = "eza -la";
      la = "eza -a";
      ls = "eza";
      cat = "bat";
      grep = "rg";
      top = "htop";
    };
    envVars = {
      # Work-specific env vars go here
    };
  };

  phix.packages = {
    enable = true;
    core = true;
    extra = [
      # Work-specific packages beyond the core set
    ];
  };

  phix.editor = {
    enable = true;
    default = "hx";
    helix.enable = true;
  };
}
