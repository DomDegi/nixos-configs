# Per-theme wallpapers: ~/Pictures/Wallpapers/<palette-slug>/ holds each
# theme's collection (dirs auto-created from _palettes.nix; Pictures is
# already persisted). The domdegi/wallpaper-picker Noctalia widget lists the
# ACTIVE theme's images and applies one via Noctalia's native wallpaper
# engine; theme-switch pops the picker open after a switch when the new
# theme's folder is non-empty. The `wallpaper-pick` helper does the shell
# work (list/set by index) so the Luau side never handles file paths.
{
  flake.modules.homeManager.wallpaper = { pkgs, lib, ... }:
    let
      palettes = import ./theme/_palettes.nix;
      wallpaperDir = "/home/domdegi/Pictures/Wallpapers";
      stateDir = "/home/domdegi/.local/state/theme";

      wallpaperPick = pkgs.writeShellApplication {
        name = "wallpaper-pick";
        runtimeInputs = with pkgs; [ coreutils findutils ];
        text = ''
          DEFAULT=${palettes.default}
          slug=$(cat ${stateDir}/current 2>/dev/null || echo "$DEFAULT")
          dir="${wallpaperDir}/$slug"

          images() {
            find "$dir" -maxdepth 1 -type f \
              \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \
                 -o -iname '*.webp' \) -printf '%f\n' 2>/dev/null | sort
          }

          case "''${1:-}" in
            list) images ;;
            status)
              # <slug>TAB<count>TAB<current wallpaper basename>
              cur=$(noctalia msg wallpaper-get 2>/dev/null | head -n1 || true)
              printf '%s\t%s\t%s\n' "$slug" "$(images | wc -l)" "''${cur##*/}" ;;
            set)
              n=''${2:?usage: wallpaper-pick set <N>}
              img=$(images | sed -n "''${n}p")
              [ -n "$img" ] || { echo "wallpaper-pick: no image #$n in $dir" >&2; exit 1; }
              noctalia msg wallpaper-set "$dir/$img" ;;
            *)
              echo "usage: wallpaper-pick list|status|set <N>" >&2
              exit 2 ;;
          esac
        '';
      };
    in
    {
      home.packages = [ wallpaperPick ];

      # Bar widget + panel menu (files in config/noctalia/plugins/)
      xdg.dataFile."noctalia/plugins/wallpaper-picker".source =
        ../config/noctalia/plugins/wallpaper-picker;

      # One folder per palette, so dropping wallpapers in is all it takes.
      home.activation.wallpaperDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ${lib.concatMapStringsSep " "
          (slug: "\"${wallpaperDir}/${slug}\"")
          (builtins.attrNames palettes.themes)}
      '';
    };
}
