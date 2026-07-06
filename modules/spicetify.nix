# Spicetify: Spotify skinned with the active palette, following theme-switch.
#
# NixOS twist: spicetify patches files inside Spotify's install dir, which is
# a read-only store path here. So activation keeps a WRITABLE COPY of
# ${pkgs.spotify}/share/spotify under ~/.local/share/spicetify-spotify
# (refreshed whenever the store path changes, i.e. on Spotify updates) plus a
# launcher built by rewriting the original wrapper to exec the copy. A hiPrio
# `spotify` shim and a desktop entry make the patched copy what actually runs.
#
# Theming: one local spicetify theme ("domdegi") whose color.ini has ONE
# SCHEME PER PALETTE, generated from theme/_palettes.nix — no third-party
# theme repos. `theme-switch` runs `spicetify config color_scheme <slug> &&
# spicetify refresh`; Spotify shows it on next launch.
# State persisted: ~/.config/spicetify + ~/.local/share/spicetify-spotify
# (see persistence.nix).
#
# Gotcha: "backup apply" is one-time per copy (unpacks Apps/*.spa in place;
# a second run fails with nothing pristine left to back up from), so the
# .nix-src marker is only written when it actually SUCCEEDS — writing it
# unconditionally would permanently skip retrying a failed, never-patched
# copy. Also strips custom_apps/extensions before applying: a
# freshly-created config-xpui.ini ships with custom_apps=marketplace by
# default, and without that custom app actually installed, that fails the
# whole apply.
{
  flake.modules.homeManager.spicetify = { pkgs, lib, ... }:
    let
      palettes = import ./theme/_palettes.nix;
      raw = c: lib.removePrefix "#" c;

      # spicetify color.ini: sections are selectable via `config color_scheme`
      scheme = slug: t: ''
        [${slug}]
        text               = ${raw t.ui.fg}
        subtext            = ${raw t.ui.fgDim}
        main               = ${raw t.ui.bg}
        sidebar            = ${raw t.ui.bgDim}
        player             = ${raw t.ui.bgDim}
        card               = ${raw t.ui.surface}
        shadow             = ${raw t.ui.bgDim}
        selected-row       = ${raw t.ui.fgDim}
        button             = ${raw t.ui.accent}
        button-active      = ${raw t.ui.accent}
        button-disabled    = ${raw t.ui.outline}
        tab-active         = ${raw t.ui.surface}
        notification       = ${raw t.ui.surface}
        notification-error = ${raw t.ui.error}
        misc               = ${raw t.ui.outline}
      '';
      colorIni = lib.concatStringsSep "\n"
        (lib.mapAttrsToList scheme palettes.themes);

      appDir = "/home/domdegi/.local/share/spicetify-spotify";

      launcher = pkgs.writeShellScriptBin "spotify" ''
        exec "${appDir}/spotify-launcher" "$@"
      '';
    in
    {
      home.packages = [
        pkgs.spicetify-cli
        (lib.hiPrio launcher) # shadows pkgs.spotify's bin/spotify
      ];

      # Color-only reskin: colors from color.ini, no extra CSS.
      xdg.configFile."spicetify/Themes/domdegi/color.ini".text = colorIni;
      xdg.configFile."spicetify/Themes/domdegi/user.css".text = "";

      # Shadow pkgs.spotify's desktop entry so app launchers start the copy.
      xdg.desktopEntries.spotify = {
        name = "Spotify";
        genericName = "Music Player";
        exec = "${appDir}/spotify-launcher %U";
        icon = "spotify-client";
        terminal = false;
        categories = [ "Audio" "Music" "AudioVideo" ];
        mimeType = [ "x-scheme-handler/spotify" ];
      };

      # Refresh the writable copy when Spotify's store path changes, then
      # (re)patch it. Never fails the activation — worst case Spotify is
      # unthemed until the next rebuild.
      #
      # `backup apply` is a ONE-TIME operation per copy: it unpacks
      # Apps/*.spa into plain directories, and a second "backup" against an
      # already-unpacked copy fails ("Failed to backup app files") since
      # there's nothing pristine left — expected, not corruption. So the
      # marker must ONLY be written when "backup apply" actually succeeds;
      # writing it unconditionally (the original bug here) permanently
      # skips re-provisioning even after a failed, never-patched attempt.
      home.activation.spicetifySetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        (
          src=${pkgs.spotify}
          dest="${appDir}"
          sp=${pkgs.spicetify-cli}/bin/spicetify

          if [ "$(cat "$dest/.nix-src" 2>/dev/null)" != "$src" ]; then
            echo "spicetify: refreshing writable Spotify copy ($src)"
            rm -rf "$dest"
            mkdir -p "$dest"
            cp -r "$src/share/spotify/." "$dest/"
            chmod -R u+w "$dest"
            # Same env wrapper as the original, but exec'ing the copy
            sed "s|$src/share/spotify|$dest|g" "$src/bin/spotify" \
              > "$dest/spotify-launcher"
            chmod +x "$dest/spotify-launcher"
            mkdir -p "$HOME/.config/spotify"
            [ -f "$HOME/.config/spotify/prefs" ] || touch "$HOME/.config/spotify/prefs"
            slug=$(cat "$HOME/.local/state/theme/current" 2>/dev/null \
              || echo ${palettes.default})
            "$sp" config spotify_path "$dest" \
              prefs_path "$HOME/.config/spotify/prefs" \
              current_theme domdegi color_scheme "$slug" \
              inject_css 1 replace_colors 1 overwrite_assets 0
            # Guard against the stock config-xpui.ini default
            # (custom_apps=marketplace), which we don't ship and which
            # fails the whole apply if left in place.
            cfg="$HOME/.config/spicetify/config-xpui.ini"
            sed -i -E 's/^(custom_apps[[:space:]]*=).*/\1/; s/^(extensions[[:space:]]*=).*/\1/' \
              "$cfg" 2>/dev/null || true
            if "$sp" backup apply; then
              printf '%s' "$src" > "$dest/.nix-src"
            else
              echo "spicetify: backup/apply failed, will retry next activation (rerun manually: spicetify backup apply)" >&2
            fi
          fi
        ) || echo "spicetify: setup failed, Spotify stays unthemed" >&2
      '';
    };
}
