{ pkgs, ... }: {
  # ── System identity ──────────────────────────────────────────────────────────
  networking.hostName = "darwin-work";

  # ── Modules ──────────────────────────────────────────────────────────────────
  phix.nix.enable = true;

  phix.systemDefaults = {
    enable = true;
    dock = {
      autohide = true;
      tileSize = 48;
      showRecentApps = false;
    };
    finder = {
      showHiddenFiles = true;
      showPathBar = true;
      defaultViewStyle = "clmv";
    };
    keyboard = {
      keyRepeatRate = 2;
      initialKeyRepeatDelay = 15;
    };
  };

  phix.homebrew = {
    enable = true;
    casks = [
      # GUI apps not available in nixpkgs go here
      # e.g. "1password" "slack" "zoom"
    ];
    brews = [
      # Homebrew formulae if needed
    ];
  };

  # ── System user ──────────────────────────────────────────────────────────────
  users.users.philipamendolia = {
    home = "/Users/philipamendolia";
    shell = pkgs.zsh;
  };

  # ── home-manager ─────────────────────────────────────────────────────────────
  home-manager.users.philipamendolia = import ../../users/phil-work.nix;

  system.stateVersion = 5;
}
