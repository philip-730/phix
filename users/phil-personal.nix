# Personal identity and preferences for the home NixOS machine.
# Username: philip
{ pkgs, ... }: {
  home.stateVersion = "24.11";

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
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
    starship.settings = {
      gcloud.disabled = true;
      os.disabled = false;
      # os.symbol = "❄️";
      username = {
        show_always = true;
        style_user = "bold red";
      };
      directory.style = "bold peach";
      git_branch.style = "bold yellow";
      git_status.style = "yellow";
      nix_shell.style = "bold sapphire";
      cmd_duration.style = "bold lavender";
      nodejs.style = "bold green";
      python.style = "bold green";
      rust.style = "bold green";
      golang.style = "bold green";
    };
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
    package = pkgs.catppuccin-cursors.mochaMauve;
    name = "catppuccin-mocha-mauve-cursors";
    size = 24;
  };

  phix.wezterm = {
    enable = true;
    opacity = 0.9;
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
