{ config, lib, ... }:

let
  cfg = config.phix.networking;
in
{
  options.phix.networking = {
    enable = lib.mkEnableOption "networking configuration";

    firewall = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable the NixOS firewall.";
      };
      allowedTCPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [];
        description = "TCP ports to allow through the firewall.";
      };
    };

    networkManager = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable NetworkManager.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      firewall = {
        enable = cfg.firewall.enable;
        allowedTCPPorts = cfg.firewall.allowedTCPPorts;
      };
      networkmanager.enable = cfg.networkManager;
    };
  };
}
