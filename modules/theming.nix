# GTK, cursors, icons, fonts, dconf/xfconf, session variables — a single
# static look. Apps: plain Adwaita-dark (neutral dark grey, built into
# GTK3; GTK4/libadwaita follows color-scheme = prefer-dark). Icons:
# Papirus-Dark with grey folders (recolored at build time via the
# package's `color` argument). Cursor: Catppuccin Mocha dark. No runtime
# switching, no multi-palette installs.
#
# Never keep a copy of an icon theme in ~/.local/share/icons (persisted):
# a stale/partial user copy shadows the Nix one and files lose their icons.
{
  flake.modules.nixos.theming = { pkgs, ... }:
    let
      papirus = pkgs.papirus-icon-theme.override { color = "grey"; };
    in
    {
      environment.systemPackages = [
        pkgs.catppuccin-cursors.mochaDark
        papirus
      ];

      environment.sessionVariables = {
        XCURSOR_THEME = "catppuccin-mocha-dark-cursors";
        XCURSOR_SIZE = "24";
      };

      # Required to save GTK settings and Niri configurations
      programs.dconf.enable = true;

      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        noto-fonts
        noto-fonts-color-emoji
      ];
    };

  flake.modules.homeManager.theming = { pkgs, ... }:
    {
      home.pointerCursor = {
        enable = true;
        name = "catppuccin-mocha-dark-cursors";
        package = pkgs.catppuccin-cursors.mochaDark;
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };

      gtk = {
        enable = true;

        gtk3.bookmarks = [
          "file:///home/domdegi/Documents"
          "file:///home/domdegi/Downloads"
          "file:///home/domdegi/Pictures"
          "file:///home/domdegi/Music"
          "file:///home/domdegi/Videos"
          "file:///home/domdegi/projects"
          "file:///home/domdegi/shared Shared"
          "file:///home/domdegi/nixos-configs nixos-configs"
        ];

        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
        gtk4.theme = null;
        # Adwaita-dark ships inside GTK3 itself — no package needed.
        theme.name = "Adwaita-dark";
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme.override { color = "grey"; };
        };
        font = {
          name = "JetBrainsMono Nerd Font";
          size = 11;
        };
      };

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Adwaita-dark";
          cursor-theme = "catppuccin-mocha-dark-cursors";
          icon-theme = "Papirus-Dark";
        };
      };

      xfconf.settings = {
        xsettings = {
          "Net/ThemeName" = "Adwaita-dark";
          "Net/IconThemeName" = "Papirus-Dark";
        };
      };
    };
}
