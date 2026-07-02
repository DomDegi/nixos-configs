# Networking (hostname lives with the host in modules/hosts/).
{
  flake.modules.nixos.network = {
    networking.networkmanager.enable = true;
  };
}
