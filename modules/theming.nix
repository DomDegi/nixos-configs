# Catppuccin Mocha (lavender) everywhere: GTK, cursors, icons, fonts,
# dconf/xfconf, session variables. System + user halves of the same feature.
{
  flake.modules.nixos.theming = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # GLOBAL THEME ASSETS (Fixes the invisible theme bug)
      (catppuccin-gtk.override {
        accents = [ "lavender" ];
        size = "standard";
        variant = "mocha";
      })
      catppuccin-cursors.mochaDark
      papirus-icon-theme
    ];

    environment.sessionVariables = {
      GTK_THEME = "catppuccin-mocha-lavender-standard";
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

  flake.modules.homeManager.theming = { pkgs, ... }: {
    home.pointerCursor = {
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
      theme = {
        name = "catppuccin-mocha-lavender-standard";
        package = pkgs.catppuccin-gtk.override {
          accents = [ "lavender" ];
          size = "standard";
          variant = "mocha";
        };
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 11;
      };
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "catppuccin-mocha-lavender-standard";
        cursor-theme = "catppuccin-mocha-dark-cursors";
        icon-theme = "Papirus-Dark";
      };
    };

    xfconf.settings = {
      xsettings = {
        "Net/ThemeName" = "catppuccin-mocha-lavender-standard";
        "Net/IconThemeName" = "Papirus-Dark";
      };
    };
  };
}
