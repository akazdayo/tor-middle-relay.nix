{ pkgs, ... }:
{
  # Nix
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Networking
  networking.hostName = "digitalocean-nix-tf";
  networking.firewall.allowedTCPPorts = [ 22 ];

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # Tor Middle Relay
  services.tor = {
    enable = true;
    openFirewall = true;
    relay = {
      enable = true;
      role = "relay";
    };
    settings = {
      Nickname = "akazdayo";
      ContactInfo = "tor@odango.app";
      ORPort = [ 9001 ];
      ExitPolicy = "reject *:*";
      ControlPort = 9051;
      RelayBandwidthRate = "2 MB";
      RelayBandwidthBurst = "4 MB";
      CookieAuthentication = true;
      AvoidDiskWrites = 1;
      SafeLogging = 1;
    };
  };

  # Timezone
  time.timeZone = "Asia/Tokyo";

  # System packages
  environment.systemPackages = with pkgs; [
    nyx
  ];

  # Swap
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 3 * 1024;
    }
  ];

  system.stateVersion = "26.05";
}
