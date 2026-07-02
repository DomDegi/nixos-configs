# Host assembly: builds nixosConfigurations.nixos from every module
# declared under flake.modules.nixos.* (one per feature file).
{ config, inputs, ... }:

{
  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    # Pass flake inputs into the modules so they can use them
    specialArgs = { inherit inputs; };

    modules = builtins.attrValues (config.flake.modules.nixos or { }) ++ [
      ../../hardware-configuration.nix
      {
        networking.hostName = "nixos";
        system.stateVersion = "25.11";
      }
    ];
  };
}
