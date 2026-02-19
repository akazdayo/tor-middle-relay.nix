{...}: {
  # DigitalOcean Provider
  terraform.required_providers.digitalocean = {
    source = "digitalocean/digitalocean";
    version = "~> 2.75";
  };

  # API Token (環境変数 DIGITALOCEAN_TOKEN から取得)
  provider.digitalocean = {};

  # SSH Key (既存のキーを参照)
  data.digitalocean_ssh_key.default = {
    name = "default";
  };

  # NixOS カスタムイメージ
  resource.digitalocean_custom_image.nixos = {
    name = "middle-relay";
    url = "https://github.com/akazdayo/digitalocean-nix-tf/releases/download/latest/nixos-digitalocean-do.qcow2.gz";
    regions = ["sgp1"];
  };

  # Droplet
  resource.digitalocean_droplet.digitalocean-nix-tf = {
    image = "\${digitalocean_custom_image.nixos.id}";
    name = "digitalocean-nix-tf";
    region = "sgp1";
    size = "s-1vcpu-1gb";
    ssh_keys = ["\${data.digitalocean_ssh_key.default.id}"];
  };

  # Firewall (SSH + Tor ORPort のみ許可)
  resource.digitalocean_firewall.tor-relay = {
    name = "tor-relay-firewall";
    droplet_ids = ["\${digitalocean_droplet.digitalocean-nix-tf.id}"];

    # Inbound: SSH (22) + Tor ORPort (9001) のみ
    inbound_rule = [
      {
        protocol = "tcp";
        port_range = "22";
        source_addresses = [
          "0.0.0.0/0"
          "::/0"
        ];
      }
      {
        protocol = "tcp";
        port_range = "9001";
        source_addresses = [
          "0.0.0.0/0"
          "::/0"
        ];
      }
      {
        protocol = "icmp";
        source_addresses = [
          "0.0.0.0/0"
          "::/0"
        ];
      }
    ];

    # Outbound: 全て許可 (Tor リレーは他ノードへ接続する必要がある)
    outbound_rule = [
      {
        protocol = "tcp";
        port_range = "1-65535";
        destination_addresses = [
          "0.0.0.0/0"
          "::/0"
        ];
      }
      {
        protocol = "udp";
        port_range = "1-65535";
        destination_addresses = [
          "0.0.0.0/0"
          "::/0"
        ];
      }
      {
        protocol = "icmp";
        destination_addresses = [
          "0.0.0.0/0"
          "::/0"
        ];
      }
    ];
  };

  # Outputs
  output.droplet_ip = {
    value = "\${digitalocean_droplet.digitalocean-nix-tf.ipv4_address}";
    description = "The public IPv4 address of the Droplet";
  };
}
