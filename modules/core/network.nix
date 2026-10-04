{
  host,
  options,
  ...
}:
{
  networking = {
    hostName = host;
    # NetworkManager on top of iwd, for Quickshell.Networking (NM is its only
    # backend). NM handles addressing, so iwd's own network config is off.
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
    wireless.iwd = {
      enable = true;
      settings.General.EnableNetworkConfiguration = false;
    };
    dhcpcd.denyInterfaces = [ "wl*" ];
    timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
        59010
        59011
        8080
      ];
      allowedUDPPorts = [
        59010
        59011
      ];
    };
  };
}
