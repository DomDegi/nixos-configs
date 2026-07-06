# GTK, cursors, icons, fonts, dconf/xfconf, session variables — themed from
# modules/theme/_palettes.nix. The DEFAULT palette is baked in here (what a
# rebuild asserts); theme-switch retargets GTK at runtime, and every
# palette's GTK theme package is installed so switching always has its
# target ("theme-switch reapply" restores a runtime choice after a rebuild).
# Also keeps a writable Papirus-Dark copy in ~/.local/share/icons so
# theme-switch can recolor the folder icons per palette (apps.papirus).
{
  flake.modules.nixos.theming = { pkgs, lib, ... }:
    let
      palettes = import ./theme/_palettes.nix;
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

      # NOTE: no GTK_THEME here — that env var overrides every other GTK
      # theme mechanism per-session and would pin GTK3 apps (Thunar…) to the
      # default palette, breaking theme-switch. Theme selection flows through
      # ~/.config/gtk-{3,4}.0/settings.ini (switchable, see theme/switcher.nix).
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

  flake.modules.homeManager.theming = { pkgs, lib, ... }:
    let
      palettes = import ./theme/_palettes.nix;
      defaultGtk = palettes.themes.${palettes.default}.apps.gtk.theme;
    in
    {
      # Folder icons follow the palette (apps.papirus). papirus-folders
      # rewrites folder-*.svg symlinks inside the theme, which is impossible
      # on the read-only store copy — so keep a writable Papirus-Dark under
      # ~/.local/share/icons (shadows the store one; persisted via
      # .local/share/icons). Refreshed when the package updates, recolored
      # for the active palette right away.
      #
      # Gotcha: in the upstream theme, most of Papirus-Dark's "places" dirs
      # (where folder icons live) are RELATIVE symlinks into a sibling
      # "../Papirus/<size>" theme, at TWO different levels: some whole size
      # dirs are themselves symlinks (32/48/64/96/128/84/8x8), while others
      # are real dirs with just "places" symlinked inside (22x22, 24x24).
      # Plain `cp -r` preserves symlinks as-is, and once copied out of the
      # store the sibling no longer exists at that relative path — so those
      # icons 404 and GTK silently falls back to the un-recolored inherited
      # theme. papirus-folders itself only touches 22/24/32/48/64, so this
      # broke recoloring for the Thunar sidebar (22/24) even after the main
      # folder-view sizes (48/64) were fixed. Fix: for every size, resolve
      # where "places" really lives; if that's through the shared sibling,
      # rebuild just that dir for real (writable, so papirus-folders can
      # rewrite it) — dereferencing the whole size dir too when IT was the
      # symlink, with every other category (apps/mimetypes/devices/...)
      # symlinked absolute back into the read-only store. Keeps the copy
      # ~100 MB instead of ~1.5 GB from fully dereferencing the shared theme.
      home.activation.papirusCopy = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        (
          src=${pkgs.papirus-icon-theme}
          dest="$HOME/.local/share/icons/Papirus-Dark"
          if [ "$(cat "$dest/.nix-src" 2>/dev/null)" != "$src" ]; then
            echo "theming: refreshing writable Papirus-Dark copy"
            rm -rf "$dest"
            mkdir -p "$dest"
            cp -r "$src/share/icons/Papirus-Dark/." "$dest/"
            chmod -R u+w "$dest"

            base="$src/share/icons/Papirus"
            srcDark="$src/share/icons/Papirus-Dark"
            for sizedir in "$srcDark"/*/; do
              size=$(basename "$sizedir")
              placesSrc="$srcDark/$size/places"
              [ -e "$placesSrc" ] || continue
              resolved=$(readlink -f "$placesSrc")
              case "$resolved" in
                "$base"/*)
                  # Whole size dir is a symlink to the shared theme: rebuild
                  # it for real, symlinking every non-"places" category
                  # absolute into the store.
                  if [ -L "$dest/$size" ]; then
                    realSize=$(readlink -f "$srcDark/$size")
                    rm -f "$dest/$size"
                    mkdir -p "$dest/$size"
                    for cat in "$realSize"/*/; do
                      catname=$(basename "$cat")
                      [ "$catname" = "places" ] && continue
                      ln -s "$cat" "$dest/$size/$catname"
                    done
                  fi
                  rm -rf "$dest/$size/places"
                  cp -r "$resolved" "$dest/$size/places"
                  chmod -R u+w "$dest/$size/places"
                  ;;
              esac
            done

            slug=$(cat "$HOME/.local/state/theme/current" 2>/dev/null \
              || echo ${palettes.default})
            case "$slug" in
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList
          (slug: t: "      ${slug}) color=${t.apps.papirus} ;;") palettes.themes)}
              *) color=${palettes.themes.${palettes.default}.apps.papirus} ;;
            esac
            ${pkgs.papirus-folders}/bin/papirus-folders -C "$color" \
              --theme Papirus-Dark >/dev/null 2>&1 || true
            ${pkgs.gtk3}/bin/gtk-update-icon-cache -q -f "$dest" 2>/dev/null || true
            printf '%s' "$src" > "$dest/.nix-src"
          fi
        ) || echo "theming: Papirus copy failed, folder colors stay default" >&2
      '';
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
