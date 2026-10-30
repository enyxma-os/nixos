{
  config,
  lib,
  ...
}:
with lib; {
  options.enyxma.network = {
    enable = mkEnableOption "Enyxma Network and Firewall Baseline";
    hostName = mkOption {
      type = types.str;
      default = "enyxma";
      description = "System hostname";
    };
  };

  config = mkIf config.enyxma.network.enable {
    networking = {
      hostName = config.enyxma.network.hostName;
      networkmanager.enable = true;
      firewall = {
        enable = true;
        allowPing = false;
        logRefusedConnections = false;
      };
    };

    boot.kernel.sysctl = {
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
    };
  };
}
