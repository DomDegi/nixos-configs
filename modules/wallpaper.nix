# Wallpapers: drop images into ~/Pictures/Wallpapers (Pictures is already
# persisted). The domdegi/wallpaper-picker Noctalia widget lists them and
# applies one via Noctalia's native wallpaper engine. The `wallpaper-pick`
# helper does the shell work (list/set by index) so the Luau side never
# handles file paths.
{
  flake.modules.homeManager.wallpaper = { pkgs, lib, ... }:
    let
      wallpaperDir = "/home/domdegi/Pictures/Wallpapers";

      wallpaperPick = pkgs.writeShellApplication {
        name = "wallpaper-pick";
        runtimeInputs = with pkgs; [ coreutils findutils ];
        text = ''
          dir="${wallpaperDir}"

          images() {
            find "$dir" -maxdepth 1 -type f \
              \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \
                 -o -iname '*.webp' \) -printf '%f\n' 2>/dev/null | sort
          }

          case "''${1:-}" in
            list) images ;;
            status)
              # <count>TAB<current wallpaper basename>
              cur=$(noctalia msg wallpaper-get 2>/dev/null | head -n1 || true)
              printf '%s\t%s\n' "$(images | wc -l)" "''${cur##*/}" ;;
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

      home.activation.wallpaperDir =
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "${wallpaperDir}"
        '';
    };
}
