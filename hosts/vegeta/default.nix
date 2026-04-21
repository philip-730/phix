{ config, pkgs, inputs, modulesPath, ... }:
let
  keys = import ../../modules/ssot/keys.nix;
in
{
  # ── Imports ───────────────────────────────────────────────────────────────────
  imports = [
    inputs.disko.nixosModules.disko
    inputs.agenix.nixosModules.default
    ./disko.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # ── Boot ──────────────────────────────────────────────────────────────────────
  boot.loader.grub.enable = true;

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
    openssh.authorizedKeys.keys = keys.users.philip;
  };

  users.users.root.openssh.authorizedKeys.keys = keys.users.philip;

  # ── Modules ───────────────────────────────────────────────────────────────────
  phix.nix.enable = true;

  security.sudo.wheelNeedsPassword = false;

  # ── Services ──────────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale_auth.path;
    extraUpFlags = [ "--ssh" ];
  };

  age.secrets = {
    tailscale_auth = {
      file = ../../secrets/tailscale_auth.age;
    };
    user_ssh = {
      file = ../../secrets/user_ssh.age;
      path = "/home/philip/.ssh/id_ed25519";
      owner = "philip";
      mode = "0600";
    };
  };

  # ── home-manager ──────────────────────────────────────────────────────────────
  home-manager.users.philip = {
    imports = [ ../../users/phil-personal.nix ];
  };

  system.stateVersion = "24.11";
}
