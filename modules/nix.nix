# Nix daemon settings, garbage collection, and nixpkgs policy.
{
  flake.modules.nixos.nix = { pkgs, ... }: {
    # Allow proprietary software (Nvidia drivers, Spotify, VSCode)
    nixpkgs.config.allowUnfree = true;

    # catppuccin-gtk is broken two ways on current nixpkgs-unstable:
    #  1. python3Packages.catppuccin's pythonImportsCheck runs against
    #     matplotlib 3.11 (pulled in via its own optional-dependencies as a
    #     nativeCheckInput), whose `style.core` module nixpkgs has since
    #     moved -> AttributeError, regardless of which Python it's built
    #     for. Its runtime code path (used by catppuccin-gtk) never touches
    #     matplotlib, so skipping the check phases is a safe workaround.
    #  2. catppuccin-gtk's own build.py breaks under the now-default Python
    #     3.14 (argparse's BooleanOptionalAction dropped the `type` kwarg it
    #     passes) -> pin it to python313, still known-good.
    #  3. python3Packages.pandas-stubs (a type-stub-only package, pulled in
    #     as a nativeCheckInput of pdfplumber -> markitdown, never a runtime
    #     dep) fails its own pytest suite against this nixpkgs's numpy/pandas
    #     pairing (stale FutureWarning/DeprecationWarning expectations). It's
    #     a pyproject-style build, so that pytest run lives in
    #     installCheckPhase (gated by doInstallCheck, not doCheck); its
    #     pythonImportsCheck = [ "pandas" ] is a separate self-check that
    #     always runs unless pythonImportsCheck is cleared too. Neither
    #     check affects the stub files pdfplumber actually consumes.
    # Drop all three once upstream repins.
    nixpkgs.overlays = [
      (final: prev: {
        catppuccin-gtk = prev.catppuccin-gtk.override { python3 = final.python313; };

        # gruvbox-gtk-theme and tokyonight-gtk-theme both ship a gtk-3.0
        # gtk-dark.css with `border-spacing` on a combobox/dropdown rule --
        # not a valid GTK3 CSS property, so every GTK3 app (Thunar, Spotify's
        # native menus, ...) logs "Theme parsing error: ... 'border-spacing'
        # is not a valid property name" on launch. GTK just skips the rule
        # (harmless, cosmetic), but strip it so the warning stops.
        gruvbox-gtk-theme = prev.gruvbox-gtk-theme.overrideAttrs (old: {
          postFixup = (old.postFixup or "") + ''
            find $out/share/themes -name '*.css' -exec sed -i '/border-spacing:/d' {} +
          '';
        });
        tokyonight-gtk-theme = prev.tokyonight-gtk-theme.overrideAttrs (old: {
          postFixup = (old.postFixup or "") + ''
            find $out/share/themes -name '*.css' -exec sed -i '/border-spacing:/d' {} +
          '';
        });
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (pyfinal: pyprev: {
            catppuccin = pyprev.catppuccin.overrideAttrs (_: {
              doCheck = false;
              doInstallCheck = false;
            });
            pandas-stubs = pyprev.pandas-stubs.overrideAttrs (_: {
              doCheck = false;
              doInstallCheck = false;
              pythonImportsCheck = [ ];
            });
          })
        ];
      })
    ];

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
