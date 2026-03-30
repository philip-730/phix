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
    starship.settings = {
      format = "$username$directory$git_branch$git_status$nodejs$python$rust$golang$nix_shell$cmd_duration$line_break$character";

      gcloud.disabled = true;

      username = {
        show_always = true;
        style_user = "bold rosewater";
        style_root = "bold red";
        format = "[$user]($style) in ";
      };

      directory = {
        style = "bold peach";
        format = "[$path]($style) ";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = "󰝚 ";
          "Pictures" = " ";
        };
      };

      git_branch = {
        symbol = "";
        style = "bold mauve";
        format = "on [$symbol $branch]($style) ";
      };

      git_status = {
        style = "yellow";
        format = "[$all_status$ahead_behind]($style) ";
      };

      nodejs = {
        symbol = "";
        style = "bold green";
        format = "[$symbol($version )]($style)";
      };

      python = {
        symbol = "";
        style = "bold green";
        format = "[$symbol($version )(\\($virtualenv\\) )]($style)";
      };

      rust = {
        symbol = "";
        style = "bold green";
        format = "[$symbol($version )]($style)";
      };

      golang = {
        symbol = "";
        style = "bold green";
        format = "[$symbol($version )]($style)";
      };

      nix_shell = {
        symbol = "";
        style = "bold sapphire";
        format = "[$symbol$state( \\($name\\))]($style) ";
      };

      cmd_duration = {
        style = "bold yellow";
        format = "took [$duration]($style) ";
        min_time = 2000;
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
        vimcmd_replace_one_symbol = "[❮](bold lavender)";
        vimcmd_replace_symbol = "[❮](bold lavender)";
        vimcmd_visual_symbol = "[❮](bold yellow)";
      };
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
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  phix.wezterm = {
    enable = true;
    opacity = 0.8;
    stableConfigPath = "/home/philip/.config/wezterm-stable.lua";
    extraConfig = ''
      config.wsl_domains = {
        {
          name = "WSL:NixOS",
          distribution = "NixOS",
          default_cwd = "/home/philip",
        },
      }
      config.default_domain = "WSL:NixOS"
    '';
  };
}
