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
        # home-manager grew its own bundled `programs.noctalia` module
        # (modules/programs/noctalia.nix) that conflicts with the one we
        # get from `inputs.noctalia.homeModules.default` (see
        # modules/noctalia.nix) — same option, two declarations. Keep
        # using the noctalia project's own module (more current, matches
        # our plugin/systemd options) and disable home-manager's copy.
        disabledModules = [ "programs/noctalia.nix" ];
        imports = builtins.attrValues (config.flake.modules.homeManager or { });
        home.stateVersion = "25.11";
      };
    };
  };
}
