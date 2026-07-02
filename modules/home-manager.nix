# Home Manager <-> NixOS wiring. Every feature file's
# flake.modules.homeManager.* contribution is imported into the user here.
{ config, inputs, ... }:

{
  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
      # If a real file is in the way of a managed one, rename it instead
      # of failing the whole activation.
      backupFileExtension = "hm-bak";

      users.domdegi = {
        imports = builtins.attrValues (config.flake.modules.homeManager or { });
        home.stateVersion = "25.11";
      };
    };
  };
}
