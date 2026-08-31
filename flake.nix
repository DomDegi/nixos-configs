# ~/nixos-configs/flake.nix
{
  description = "NixOS + Niri + Noctalia System Flake (dendritic)";

  inputs = {
    # Track the bleeding edge
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    impermanence = {
      url = "github:nix-community/impermanence";
      # Dedupe: impermanence only ships modules; its own nixpkgs/HM copies
      # exist for its test suite and would otherwise bloat the lock file.
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

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

    # Bring in the official Noctalia Shell flake (v5). Pinned to a specific
    # rev, not the default branch: noctalia has no tagged stable releases,
    # moves fast, and has broken our custom plugin host/IPC surface before
    # (see git history). `nix flake update` intentionally will NOT move
    # this — bump the rev here deliberately, then re-check the 5 plugins
    # under config/noctalia/plugins/ still work (plugin_api version,
    # ~/.local/share/noctalia/plugins/ layout, IPC command names).
    noctalia = {
      url = "github:noctalia-dev/noctalia/c7abdb8e72b1a80bd6f1d8e096b0a93eeb0b32ff";
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
