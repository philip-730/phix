# Work identity and preferences for the Darwin work machine.
# Username: philipamendolia
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
      core.editor = "hx";
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
      # Work machine extras
      pkgs.google-cloud-sdk
      pkgs.claude-code
      pkgs.jsonnet-language-server
      pkgs.aerospace
      pkgs.jankyborders
    ];
  };

  phix.editor = {
    enable = true;
    default = "hx";
    helix.enable = true;
  };

  phix.wezterm = {
    enable = true;
    opacity = 0.9;
    stableConfigPath = "/Users/philipamendolia/.config/wezterm-stable.lua";
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

  # AeroSpace window manager + jankyborders startup hook.
  home.file.".aerospace.toml".text = ''
    start-at-login = true
    after-startup-command = [
      'exec-and-forget /Users/philipamendolia/.nix-profile/bin/borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=5.0'
    ]
    enable-normalization-flatten-containers = true
    enable-normalization-opposite-orientation-for-nested-containers = true
    accordion-padding = 30
    default-root-container-layout = 'tiles'
    default-root-container-orientation = 'auto'
    on-focused-monitor-changed = ['move-mouse monitor-lazy-center']
    automatically-unhide-macos-hidden-apps = true

    [key-mapping]
    preset = 'qwerty'

    [gaps]
    inner.horizontal = 8
    inner.vertical = 8
    outer.left = 8
    outer.bottom = 8
    outer.top = 8
    outer.right = 8

    [mode.main.binding]
    alt-shift-f = 'exec-and-forget open -a Finder'
    alt-q = "close"
    alt-slash = 'layout tiles horizontal vertical'
    alt-comma = 'layout accordion horizontal vertical'
    alt-m = 'fullscreen'
    alt-h = 'focus left'
    alt-j = 'focus down'
    alt-k = 'focus up'
    alt-l = 'focus right'
    alt-shift-h = 'move left'
    alt-shift-j = 'move down'
    alt-shift-k = 'move up'
    alt-shift-l = 'move right'
    alt-shift-minus = 'resize smart -50'
    alt-shift-equal = 'resize smart +50'
    alt-1 = 'workspace 1'
    alt-2 = 'workspace 2'
    alt-3 = 'workspace 3'
    alt-4 = 'workspace 4'
    alt-5 = 'workspace 5'
    alt-6 = 'workspace 6'
    alt-7 = 'workspace 7'
    alt-8 = 'workspace 8'
    alt-9 = 'workspace 9'
    alt-shift-1 = 'move-node-to-workspace 1'
    alt-shift-2 = 'move-node-to-workspace 2'
    alt-shift-3 = 'move-node-to-workspace 3'
    alt-shift-4 = 'move-node-to-workspace 4'
    alt-shift-5 = 'move-node-to-workspace 5'
    alt-shift-6 = 'move-node-to-workspace 6'
    alt-shift-7 = 'move-node-to-workspace 7'
    alt-shift-8 = 'move-node-to-workspace 8'
    alt-shift-9 = 'move-node-to-workspace 9'
    alt-tab = 'workspace-back-and-forth'
    alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'
    alt-shift-semicolon = 'mode service'

    [workspace-to-monitor-force-assignment]
    1 = ['secondary', 'main']
    2 = ['secondary', 'main']
    3 = ['secondary', 'main']
    4 = ['secondary', 'main']
    5 = ['secondary', 'main']
    6 = 'main'
    7 = 'main'
    8 = 'main'
    9 = 'main'

    [mode.service.binding]
    esc = ['reload-config', 'mode main']
    r = ['flatten-workspace-tree', 'mode main']
    f = ['layout floating tiling', 'mode main']
    backspace = ['close-all-windows-but-current', 'mode main']
    alt-shift-h = ['join-with left', 'mode main']
    alt-shift-j = ['join-with down', 'mode main']
    alt-shift-k = ['join-with up', 'mode main']
    alt-shift-l = ['join-with right', 'mode main']

    [[on-window-detected]]
    if.app-id = 'us.zoom.xos'
    run = 'move-node-to-workspace 6'
  '';
}
