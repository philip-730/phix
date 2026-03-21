{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  # ── System identity ──────────────────────────────────────────────────────────
  networking.hostName = "nixos-home";
  time.timeZone = "America/New_York"; # adjust to your timezone
  i18n.defaultLocale = "en_US.UTF-8";

  # ── System user ──────────────────────────────────────────────────────────────
  users.users.philip = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # ── Modules ──────────────────────────────────────────────────────────────────
  phix.nix.enable = true;
  phix.networking.enable = true;
  phix.desktop = {
    enable = true;
    compositor = "hyprland"; # change to "gnome", "plasma", or "none"
  };

  # ── home-manager ─────────────────────────────────────────────────────────────
  home-manager.users.philip = import ../../users/phil-personal.nix;

  system.stateVersion = "24.11";
}
