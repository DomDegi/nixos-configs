# ~/nixos-configs/flake.nix
{
  description = "NixOS + Niri + Noctalia System Flake (dendritic)";

  inputs = {
    # Track the bleeding edge
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";

    # Dendritic pattern plumbing: flake-parts is the top-level module
    # system, import-tree auto-imports every .nix under ./modules.
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";

    # Bring in Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Bring in the official Noctalia Shell flake (v5)
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets (login password hash) encrypted in-repo
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        # Provides the `flake.modules.<class>.<name>` options used by
        # every feature file under ./modules.
        inputs.flake-parts.flakeModules.modules
        (inputs.import-tree ./modules)
      ];
    };
}
