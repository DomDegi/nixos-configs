# GUI applications (default file-type wiring lives in default-apps.nix).
{
  flake.modules.homeManager.desktop-apps = { pkgs, ... }: {
    home.packages = with pkgs; [
      # GUI Apps
      spotify
      obsidian

      # Basic Desktop Utilities
      snapshot # Camera
      imv # Image viewer
      mpv # Video player
      gnome-calculator # Calculator
      libreoffice # Office suite
      kooha # Screen recorder

      # GNOME Keyring GUI Manager (Optional, but highly recommended)
      seahorse
      libsecret

      # WeBeep Sync (Wrapped with the modern Chromium flag)
      (symlinkJoin {
        name = "webeep-sync-keyring";
        paths = [ webeep-sync ];
        buildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/webeep-sync \
            --add-flags "--password-store=gnome-libsecret"
        '';
      })
    ];
  };
}
