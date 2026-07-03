# GTK, cursors, icons, fonts, dconf/xfconf, session variables — themed from
# modules/theme/_palettes.nix. The DEFAULT palette is baked in here (what a
# rebuild asserts); theme-switch retargets GTK at runtime, and every
# palette's GTK theme package is installed so switching always has its
# target ("theme-switch reapply" restores a runtime choice after a rebuild).
{
  flake.modules.nixos.theming = { pkgs, lib, ... }:
    let
      palettes = import ./theme/_palettes.nix;
      defaultGtk = palettes.themes.${palettes.default}.apps.gtk.theme;
      # GTK themes for the non-default palettes (plain package attrs);
      # the default (catppuccin) needs an override, added explicitly below.
      extraGtkPackages = lib.pipe palettes.themes [
        builtins.attrValues
        (map (t: t.apps.gtk.package))
        (lib.filter (p: p != "" && p != "catppuccin-gtk"))
        lib.unique
        (map (p: pkgs.${p}))
      ];
    in
    {
      environment.systemPackages = with pkgs; [
        # GLOBAL THEME ASSETS (Fixes the invisible theme bug)
        (catppuccin-gtk.override {
          accents = [ "lavender" ];
          size = "standard";
          variant = "mocha";
        })
        catppuccin-cursors.mochaDark
        papirus-icon-theme
      ] ++ extraGtkPackages;

      environment.sessionVariables = {
        GTK_THEME = defaultGtk;
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
    let
      palettes = import ./theme/_palettes.nix;
      defaultGtk = palettes.themes.${palettes.default}.apps.gtk.theme;
    in
    {
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
          name = defaultGtk;
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
          gtk-theme = defaultGtk;
          cursor-theme = "catppuccin-mocha-dark-cursors";
          icon-theme = "Papirus-Dark";
        };
      };

      xfconf.settings = {
        xsettings = {
          "Net/ThemeName" = defaultGtk;
          "Net/IconThemeName" = "Papirus-Dark";
        };
      };
    };
}
