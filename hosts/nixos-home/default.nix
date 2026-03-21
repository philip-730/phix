{ pkgs, ... }: {
  # ── WSL ──────────────────────────────────────────────────────────────────────
  wsl = {
    enable = true;
    defaultUser = "philip";
  };

  # ── System identity ──────────────────────────────────────────────────────────
  networking.hostName = "nixos-home";
  time.timeZone = "America/New_York"; # adjust to your timezone
  i18n.defaultLocale = "en_US.UTF-8";

  # ── System user ──────────────────────────────────────────────────────────────
  users.users.philip = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
  };

  # ── Modules ──────────────────────────────────────────────────────────────────
  phix.nix.enable = true;

  # ── home-manager ─────────────────────────────────────────────────────────────
  home-manager.users.philip = import ../../users/phil-personal.nix;

  system.stateVersion = "24.11";
}
