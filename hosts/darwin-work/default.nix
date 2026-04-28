{ pkgs, ... }:
{
  # ── System identity ──────────────────────────────────────────────────────────
  networking.hostName = "darwin-work";
  system.primaryUser = "philipamendolia";
  ids.gids.nixbld = 30000;

  # ── Modules ──────────────────────────────────────────────────────────────────
  phix.nix.enable = true;

  phix.systemDefaults = {
    enable = true;
    dock = {
      autohide = true;
      largeSize = 36;
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
      automaticPeriodSubstitution = false;
    };
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
