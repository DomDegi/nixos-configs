# GUI applications and their default-application (MIME) wiring.
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
      zathura # A highly customizable, keyboard-driven PDF viewer

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

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = [ "thunar.desktop" ];
        "application/pdf" = [ "org.pwmt.zathura.desktop" ];
        "text/html" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "application/zip" = [ "xarchiver.desktop" ];
        "application/x-xz" = [ "xarchiver.desktop" ];
        "application/x-tar" = [ "xarchiver.desktop" ];
        "application/x-bzip2" = [ "xarchiver.desktop" ];
        "application/x-gzip" = [ "xarchiver.desktop" ];
      };
    };
  };
}
