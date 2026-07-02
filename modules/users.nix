# The domdegi user account. Password hash comes from sops-nix (secrets.nix).
{
  flake.modules.nixos.users = { pkgs, ... }: {
    users.mutableUsers = false;

    users.users.domdegi = {
      isNormalUser = true;
      description = "Domenico";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      shell = pkgs.fish;
    };

    # Enable Fish system-wide (Needed so NixOS knows it's a valid login shell)
    programs.fish.enable = true;

    # Symlink the config repo into the home directory
    systemd.tmpfiles.rules = [
      "L+ /home/domdegi/nixos-configs - - - - /persist/nixos-configs"
    ];
  };
}
