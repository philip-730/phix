# Personal identity and preferences for the home NixOS machine.
# Username: philip
{ pkgs, ... }: {
  home.stateVersion = "24.11";

  phix.git = {
    enable = true;
    userName = "Philip Amendolia";
    userEmail = "philip@example.com"; # replace with your actual email
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
  };

  phix.packages = {
    enable = true;
    core = true;
    extra = [
      # Personal packages beyond the core set
    ];
  };

  phix.editor = {
    enable = true;
    default = "hx";
    helix.enable = true;
  };
}
