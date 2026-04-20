{ pkgs, inputs, ... }:
{
  # ── Disk layout (disko) ───────────────────────────────────────────────────────
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
  ];

  # ── Boot ──────────────────────────────────────────────────────────────────────
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # ── System identity ───────────────────────────────────────────────────────────
  networking.hostName = "vegeta";
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── Networking ────────────────────────────────────────────────────────────────
  # IPv6-only Hetzner cloud server; Tailscale provides the overlay network
  networking.useDHCP = true;

  # ── User ──────────────────────────────────────────────────────────────────────
  users.users.philip = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELlZIKOjzYwlQKX1axFreOXhZQz5MuPscRi2PDba1zi philip@mactan"
    ];
  };

  # ── Modules ───────────────────────────────────────────────────────────────────
  phix.nix.enable = true;

  # ── Services ──────────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.tailscale.enable = true;

  # ── home-manager ──────────────────────────────────────────────────────────────
  home-manager.users.philip = {
    imports = [ ../../users/phil-personal.nix ];
  };

  system.stateVersion = "24.11";
}
