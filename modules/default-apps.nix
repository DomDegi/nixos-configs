# Default applications per file type (xdg.mimeApps) and the small launchers
# behind them:
#  - open-pdf: PDFs inside an Obsidian vault open in Obsidian, all others
#    in Firefox (vaults read from ~/.config/obsidian/obsidian.json).
#  - rstudio-project: launches RStudio inside the nearest project flake's
#    `rstudio` devshell (walks up from the file), so it sees that project's
#    R packages. RStudio itself is never installed system-wide.
#  - R / R Markdown / Quarto / .Rproj MIME types (shared-mime-info has none,
#    so they'd be plain text).
# Editors: Zed is the default for code/text (fast to open), VS Code for
# notebooks, R, LaTeX and Typst (live preview); the other editors are
# pre-listed in every "Open With" menu so they're one click away.
{
  flake.modules.homeManager.default-apps = { pkgs, lib, ... }:
    let
      open-pdf = pkgs.writeShellApplication {
        name = "open-pdf";
        runtimeInputs = with pkgs; [ jq coreutils ];
        text = ''
          cfg="$HOME/.config/obsidian/obsidian.json"
          for arg in "$@"; do
            f=$(realpath -- "$arg")
            if [ -r "$cfg" ]; then
              while IFS= read -r v; do
                rv=$(realpath -- "$v" 2>/dev/null) || continue
                case "$f" in
                  "$rv"/*)
                    uri=$(jq -rn --arg p "$v''${f#"$rv"}" '$p | @uri')
                    obsidian "obsidian://open?path=$uri" &
                    continue 2
                    ;;
                esac
              done < <(jq -r '.vaults[].path' "$cfg")
            fi
            firefox "$f" &
          done
        '';
      };

      rstudio-project = pkgs.writeShellApplication {
        name = "rstudio-project";
        runtimeInputs = with pkgs; [ coreutils gnugrep libnotify ];
        text = ''
          target=$(realpath -- "''${1:-$PWD}")
          d=$target
          [ -d "$d" ] || d=$(dirname -- "$d")
          while [ "$d" != / ]; do
            if [ -f "$d/flake.nix" ] && grep -q 'rstudio' "$d/flake.nix"; then
              cd "$d"
              args=()
              [ -f "$target" ] && args=("$target")
              exec nix develop "$d#rstudio" -c rstudio "''${args[@]}"
            fi
            d=$(dirname -- "$d")
          done
          notify-send -i rstudio "RStudio" "No project flake with an 'rstudio' devshell above $target"
          exit 1
        '';
      };

      r-mime = pkgs.writeTextDir "share/mime/packages/r-lang.xml" ''
        <?xml version="1.0" encoding="UTF-8"?>
        <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
          <mime-type type="text/x-r">
            <comment>R script</comment>
            <sub-class-of type="text/plain"/>
            <icon name="text-x-r"/>
            <glob pattern="*.R" case-sensitive="true"/>
            <glob pattern="*.r" case-sensitive="true"/>
          </mime-type>
          <mime-type type="text/x-r-markdown">
            <comment>R Markdown document</comment>
            <sub-class-of type="text/plain"/>
            <icon name="text-x-r"/>
            <glob pattern="*.Rmd"/>
          </mime-type>
          <mime-type type="text/x-quarto">
            <comment>Quarto document</comment>
            <sub-class-of type="text/plain"/>
            <generic-icon name="text-x-generic"/>
            <glob pattern="*.qmd"/>
          </mime-type>
          <mime-type type="application/x-rstudio-project">
            <comment>RStudio project</comment>
            <sub-class-of type="text/plain"/>
            <icon name="rstudio"/>
            <glob pattern="*.Rproj"/>
          </mime-type>
        </mime-info>
      '';

      zed = "dev.zed.Zed.desktop";
      code = "code.desktop";
      rstudio = "rstudio-project.desktop";

      # Code and plain text: Zed first, VS Code one click away.
      codeTypes = [
        "text/plain" "text/markdown" "text/x-readme" "text/x-log"
        "text/x-python" "text/x-python3" "text/julia" "text/rust" "text/x-go"
        "text/x-csrc" "text/x-chdr" "text/x-c++src" "text/x-c++hdr"
        "text/x-java" "text/x-lua" "text/x-nix" "text/x-shellscript"
        "text/x-makefile" "text/x-cmake" "text/x-matlab"
        "text/css" "text/javascript" "application/json" "application/toml"
        "application/yaml" "application/xml" "application/sql"
        "application/x-zerosize"
      ];
      # VS Code first (R extension / notebooks), the rest in "Open With".
      rTypes = [ "text/x-r" "text/x-r-markdown" "text/x-quarto" ];
      # LaTeX/Typst: VS Code first (LaTeX Workshop / Tinymist live preview).
      docTypes = [ "text/x-tex" "text/x-bibtex" "text/vnd.typst" ];
      archiveTypes = [
        "application/zip" "application/x-7z-compressed" "application/vnd.rar"
        "application/x-rar" "application/x-tar" "application/x-compressed-tar"
        "application/x-xz-compressed-tar" "application/x-bzip2-compressed-tar"
        "application/x-zstd-compressed-tar" "application/gzip" "application/x-xz"
        "application/x-bzip2" "application/zstd"
      ];
      imageTypes = [
        "image/png" "image/jpeg" "image/gif" "image/webp" "image/bmp"
        "image/tiff" "image/avif" "image/heif"
      ];
      mediaTypes = [
        "video/mp4" "video/x-matroska" "video/webm" "video/quicktime"
        "video/x-msvideo" "audio/mpeg" "audio/flac" "audio/ogg" "audio/x-wav"
        "audio/mp4" "audio/aac" "audio/x-opus+ogg"
      ];

      for = types: app: lib.genAttrs types (_: app);
    in
    {
      home.packages = [ open-pdf rstudio-project r-mime ];

      xdg.desktopEntries = {
        open-pdf = {
          name = "PDF (Obsidian vault / Firefox)";
          exec = "open-pdf %F";
          icon = "application-pdf";
          mimeType = [ "application/pdf" ];
          noDisplay = true;
        };
        rstudio-project = {
          name = "RStudio (project)";
          genericName = "R IDE";
          exec = "rstudio-project %f";
          icon = "rstudio";
          mimeType = rTypes ++ [ "application/x-rstudio-project" ];
          categories = [ "Development" "IDE" ];
        };
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications =
          for codeTypes [ zed code ]
          // for rTypes [ code ]
          // for docTypes [ code ]
          // for archiveTypes [ "xarchiver.desktop" ]
          // for imageTypes [ "imv.desktop" ]
          // for mediaTypes [ "mpv.desktop" ]
          // {
            "inode/directory" = [ "thunar.desktop" ];
            "application/pdf" = [ "open-pdf.desktop" ];
            "text/html" = [ "firefox.desktop" ];
            "application/xhtml+xml" = [ "firefox.desktop" ];
            "image/svg+xml" = [ "firefox.desktop" ];
            "x-scheme-handler/http" = [ "firefox.desktop" ];
            "x-scheme-handler/https" = [ "firefox.desktop" ];
            "application/x-ipynb+json" = [ code ];
            "application/x-rstudio-project" = [ rstudio ];
            "text/csv" = [ "calc.desktop" ];
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ];
            "application/msword" = [ "writer.desktop" ];
            "application/vnd.oasis.opendocument.text" = [ "writer.desktop" ];
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "calc.desktop" ];
            "application/vnd.ms-excel" = [ "calc.desktop" ];
            "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
            "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [ "impress.desktop" ];
            "application/vnd.ms-powerpoint" = [ "impress.desktop" ];
            "application/vnd.oasis.opendocument.presentation" = [ "impress.desktop" ];
          };

        # Pre-listed in Thunar's "Open With" so the other editor/viewer is
        # always one click away.
        associations.added =
          for codeTypes [ zed code ]
          // for rTypes [ code zed rstudio ]
          // for docTypes [ zed ]
          // {
            "inode/directory" = [ code zed ];
            "application/pdf" = [ "firefox.desktop" ];
            "text/html" = [ code zed ];
            "image/svg+xml" = [ "imv.desktop" zed ];
            "text/csv" = [ code zed ];
            "application/x-ipynb+json" = [ zed ];
            "application/x-rstudio-project" = [ code ];
          };
      };
    };
}
