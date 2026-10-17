# Nix daemon settings, garbage collection, and nixpkgs policy.
{
  flake.modules.nixos.nix = { pkgs, ... }: {
    # Allow proprietary software (Nvidia drivers, Spotify, VSCode)
    nixpkgs.config.allowUnfree = true;

    # Nicer rebuild UX: `nh os switch` builds, shows an nvd package diff,
    # then activates — no need to pass the flake path every time.
    programs.nh = {
      enable = true;
      flake = "/persist/nixos-configs";
    };
    environment.systemPackages = [ pkgs.nvd ];

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    nix.settings.auto-optimise-store = true;
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    system.autoUpgrade = {
      enable = false;
      dates = "02:00";
      randomizedDelaySec = "45min";
      operation = "boot";
      channel = "https://nixos.org/channels/nixos-unstable";
    };
  };
}
