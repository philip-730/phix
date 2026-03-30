# Personal identity and preferences for the home NixOS machine.
# Username: philip
{ pkgs, ... }: {
  home.stateVersion = "24.11";

  catppuccin = {
    enable = true;
    flavor = "mocha";
  };

  phix.git = {
    enable = true;
    settings = {
      user.Name = "philip-730";
      user.Email = "philip.amendolia@gmail.com";
      init.defaultBranch = "main";
      core.editor = "hx --wait";
    };
    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
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
    starship.settings = {};
  };

  phix.packages = {
    enable = true;
    core = true;
    extra = [
      # Personal packages beyond the core set
      pkgs.google-cloud-sdk
      pkgs.claude-code
    ];
  };

  phix.editor = {
    enable = true;
    default = "hx";
    helix.enable = true;
  };

  home.pointerCursor = {
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  phix.wezterm = {
    enable = true;
    opacity = 0.8;
    stableConfigPath = "/home/philip/.config/wezterm-stable.lua";
    extraConfig = ''
      if string.find(wezterm.target_triple, "windows") then
        config.wsl_domains = {
          {
            name = "WSL:NixOS",
            distribution = "NixOS",
            default_cwd = "/home/philip",
          },
        }
        config.default_domain = "WSL:NixOS"
      end
    '';
  };
}
