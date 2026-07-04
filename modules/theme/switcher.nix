# Runtime theme switching across the whole rice, generated from
# _palettes.nix (the single source of truth for colors).
#
# For every palette this builds: foot colors, a starship config, a fastfetch
# config (prompt-matched ╭─ frame layout) and a Noctalia colorscheme. The `theme-switch`
# script repoints symlinks under ~/.local/state/theme (persisted), updates
# VS Code/Zed/niri/GTK/Noctalia in place, and is driven from the Noctalia bar
# via the domdegi/theme-switcher plugin (widget button -> panel menu).
#
# Reach per app:
#   instant ......... noctalia, niri (live reload), GTK, VS Code, Zed
#   next launch ..... foot windows, starship/fastfetch (new shells), nvim
#   rebuild-only .... TTY console + Ly greeter (always the default palette)
{
  flake.modules.homeManager.theme-switcher = { pkgs, lib, config, ... }:
    let
      palettes = import ./_palettes.nix;
      inherit (palettes) themes;

      stateDir = "/home/domdegi/.local/state/theme";
      repoDir = "/persist/nixos-configs";

      raw = c: lib.removePrefix "#" c;

      footConf = t: pkgs.writeText "foot-theme.ini" ''
        [colors-dark]
        alpha=0.85
        background=${raw t.ui.bg}
        foreground=${raw t.ui.fg}
        regular0=${raw t.ansi.black}
        regular1=${raw t.ansi.red}
        regular2=${raw t.ansi.green}
        regular3=${raw t.ansi.yellow}
        regular4=${raw t.ansi.blue}
        regular5=${raw t.ansi.magenta}
        regular6=${raw t.ansi.cyan}
        regular7=${raw t.ansi.white}
        bright0=${raw t.ansi.brightBlack}
        bright1=${raw t.ansi.brightRed}
        bright2=${raw t.ansi.brightGreen}
        bright3=${raw t.ansi.brightYellow}
        bright4=${raw t.ansi.brightBlue}
        bright5=${raw t.ansi.brightMagenta}
        bright6=${raw t.ansi.brightCyan}
        bright7=${raw t.ansi.brightWhite}
      '';

      tomlFormat = pkgs.formats.toml { };
      starshipConf = t: tomlFormat.generate "starship-theme.toml" {
        palette = "theme";
        palettes.theme = {
          accent = t.ui.accent;
          secondary = t.ui.secondary;
          muted = t.ui.fgDim;
          blue = t.ansi.blue;
          red = t.ansi.red;
          green = t.ansi.green;
        };
        format = "[╭─](muted)$os$directory$git_branch$git_status\n[╰─](muted)$character";
        os = { disabled = false; style = "bold accent"; symbols.NixOS = " "; };
        directory = { style = "bold blue"; read_only = " 󰌾"; truncation_length = 3; truncation_symbol = "…/"; };
        character = { success_symbol = "[❯](bold accent)"; error_symbol = "[❯](bold red)"; vimcmd_symbol = "[❮](bold green)"; };
        git_branch = { symbol = " "; style = "bold secondary"; };
        git_status = { style = "bold red"; };
      };

      # Fastfetch styled after the starship prompt (╭─ frame in the muted
      # color, role colors from the palette instead of the ANSI rainbow), so
      # the fetch flows visually into the prompt below it. Icons are strictly
      # base-plane Nerd Font glyphs (U+E000–U+F8FF): the plane-15 Material
      # ones (󰅐 󰏖 󰋊 󰁹) render double-width in foot and break key alignment.
      # `key.width` positions all values in one column via absolute cursor
      # moves, so the embedded color escapes in the keys don't affect it.
      fastfetchConf = t:
        let
          # "#rrggbb" -> truecolor SGR params for fastfetch {#...} placeholders
          sgr = c:
            let d = i: toString (lib.fromHexString (builtins.substring i 2 (raw c)));
            in "38;2;${d 0};${d 2};${d 4}";
          # leading 0: clears the bold+cyan default key style fastfetch
          # emits before the key format
          frame = "{#0;${sgr t.ui.fgDim}}";
          # icons by BMP codepoint (Nix has no \u escapes; JSON does). Keeps
          # raw PUA glyphs out of the source, where editors/tools mangle them.
          glyph = cp: builtins.fromJSON ''"\u${cp}"'';
          key = color: cp: text:
            "${frame}│ {#${sgr color}}${glyph cp} {#${sgr t.ui.fg}}${text}";
          bar = { type = "custom"; format = "${frame}│"; };
        in
        pkgs.writeText "fastfetch-theme.jsonc" (builtins.toJSON {
          logo = {
            source = "nixos";
            # the builtin ascii has 6 slots, one per blade: odd/even alternate
            color = {
              "1" = t.ui.accent; "3" = t.ui.accent; "5" = t.ui.accent;
              "2" = t.ui.secondary; "4" = t.ui.secondary; "6" = t.ui.secondary;
            };
            padding = { top = 1; left = 2; right = 5; };
          };
          display = {
            separator = "  ";
            key.width = 16;
          };
          modules = [
            "break"
            {
              type = "title";
              format = "${frame}╭─── {#1;${sgr t.ui.accent}}{user-name}{#0}${frame}@{#1;${sgr t.ui.secondary}}{host-name}";
            }
            bar
            { type = "os"; key = key t.ui.accent "f313" "OS"; }
            { type = "kernel"; key = key t.ui.accent "f17c" "Kernel"; }
            { type = "uptime"; key = key t.ui.accent "f017" "Uptime"; }
            { type = "packages"; key = key t.ui.accent "f187" "Packages"; }
            bar
            { type = "shell"; key = key t.ui.secondary "f120" "Shell"; }
            { type = "wm"; key = key t.ui.secondary "f2d0" "WM"; }
            { type = "terminal"; key = key t.ui.secondary "e795" "Terminal"; }
            bar
            { type = "cpu"; key = key t.ui.tertiary "f2db" "CPU"; }
            { type = "gpu"; key = key t.ui.tertiary "f108" "GPU"; }
            { type = "memory"; key = key t.ui.tertiary "f0e4" "Memory"; }
            { type = "disk"; key = key t.ui.tertiary "f0a0" "Disk"; }
            { type = "battery"; key = key t.ui.tertiary "f240" "Battery"; }
            bar
            { type = "colors"; key = "${frame}╰───"; symbol = "circle"; }
          ];
        });

      # Noctalia custom palette (~/.config/noctalia/palettes/<Name>.json,
      # switched via `noctalia msg color-scheme-set custom <Name>`).
      # Only dark is meaningful here; light mirrors it so the file is valid.
      noctaliaScheme = t:
        let
          side = {
            mPrimary = t.ui.accent; mOnPrimary = t.ui.bgDim;
            mSecondary = t.ui.secondary; mOnSecondary = t.ui.bgDim;
            mTertiary = t.ui.tertiary; mOnTertiary = t.ui.bgDim;
            mError = t.ui.error; mOnError = t.ui.bgDim;
            mSurface = t.ui.bg; mOnSurface = t.ui.fg;
            mSurfaceVariant = t.ui.surface; mOnSurfaceVariant = t.ui.fgDim;
            mOutline = t.ui.outline; mShadow = t.ui.bgDim;
            mHover = t.ui.tertiary; mOnHover = t.ui.bgDim;
            terminal = {
              foreground = t.ui.fg; background = t.ui.bg;
              selectionFg = t.ui.fg; selectionBg = t.ui.outline;
              cursorText = t.ui.bg; cursor = t.ui.fg;
              normal = {
                inherit (t.ansi) black red green yellow blue magenta cyan white;
              };
              bright = {
                black = t.ansi.brightBlack; red = t.ansi.brightRed;
                green = t.ansi.brightGreen; yellow = t.ansi.brightYellow;
                blue = t.ansi.brightBlue; magenta = t.ansi.brightMagenta;
                cyan = t.ansi.brightCyan; white = t.ansi.brightWhite;
              };
            };
          };
        in builtins.toJSON { dark = side; light = side; };

      # Everything theme-switch needs to know, keyed by slug. Embedding the
      # store paths also makes the script a GC root for the theme assets.
      manifest = builtins.toJSON (lib.mapAttrs (slug: t: {
        inherit (t) name;
        foot = footConf t;
        starship = starshipConf t;
        fastfetch = fastfetchConf t;
        nvim = t.apps.nvim.colorscheme;
        gtk = t.apps.gtk.theme;
        vscodeTheme = t.apps.vscode.theme;
        vscodeExt = t.apps.vscode.extension;
        zedTheme = t.apps.zed.theme;
        accent = t.ui.accent;
        outline = t.ui.outline;
        backdrop = "${t.ui.bg}cc";
      }) themes);

      themeSwitch = pkgs.writeShellApplication {
        name = "theme-switch";
        runtimeInputs = with pkgs; [ jq gnused gnugrep coreutils dconf ];
        text = ''
          MANIFEST=${lib.escapeShellArg manifest}
          STATE=${stateDir}
          REPO=${repoDir}
          DEFAULT=${palettes.default}

          current() { cat "$STATE/current" 2>/dev/null || echo "$DEFAULT"; }

          case "''${1:-}" in
            list)
              cur=$(current)
              jq -r --arg cur "$cur" \
                'to_entries | sort_by(.value.name)[]
                 | [.key, .value.name, (if .key == $cur then "1" else "0" end)]
                 | @tsv' <<<"$MANIFEST"
              exit 0 ;;
            current) current; exit 0 ;;
            reapply) exec "$0" "$(current)" ;;
            "")
              echo "usage: theme-switch <slug>|list|current|reapply" >&2
              echo "themes:" >&2
              jq -r 'to_entries[] | "  \(.key)\t\(.value.name)"' <<<"$MANIFEST" >&2
              exit 2 ;;
          esac

          slug=$1
          entry=$(jq -e --arg s "$slug" '.[$s]' <<<"$MANIFEST") || {
            echo "theme-switch: unknown theme '$slug' (try: theme-switch list)" >&2
            exit 1
          }
          get() { jq -r --arg k "$1" '.[$k]' <<<"$entry"; }
          name=$(get name)

          # 1. State symlinks: foot (via include), starship, fastfetch, nvim
          mkdir -p "$STATE"
          ln -sfn "$(get foot)" "$STATE/foot.ini"
          ln -sfn "$(get starship)" "$STATE/starship.toml"
          ln -sfn "$(get fastfetch)" "$STATE/fastfetch.jsonc"
          get nvim > "$STATE/nvim"
          echo "$slug" > "$STATE/current"

          # 2. VS Code + Zed settings (out-of-store working-tree files)
          for pair in "vscode/settings.json workbench.colorTheme vscodeTheme" \
                      "zed/settings.json theme zedTheme"; do
            read -r file key mkey <<<"$pair"
            f="$REPO/config/$file"
            if jq --indent 4 --arg t "$(get "$mkey")" ".\"$key\" = \$t" "$f" > "$f.tmp"; then
              mv "$f.tmp" "$f"
            else
              rm -f "$f.tmp"
              echo "theme-switch: warning: could not update $f" >&2
            fi
          done

          # 3. niri borders/backdrop (tagged lines; niri live-reloads the file)
          kdl="$REPO/config/niri/config.kdl"
          if grep -q '// theme:accent' "$kdl"; then
            sed -i -E \
              -e "s@(active-color \")#[0-9a-fA-F]+(\" // theme:accent)@\1$(get accent)\2@" \
              -e "s@(inactive-color \")#[0-9a-fA-F]+(\" // theme:outline)@\1$(get outline)\2@" \
              -e "s@(backdrop-color \")#[0-9a-fA-F]+(\" // theme:backdrop)@\1$(get backdrop)\2@" \
              "$kdl"
          else
            echo "theme-switch: warning: no '// theme:' markers in config.kdl" >&2
          fi

          # 4. GTK (runtime; a rebuild re-asserts the default -> use reapply).
          # dconf write instead of gsettings: no schema lookup needed.
          dconf write /org/gnome/desktop/interface/gtk-theme "'$(get gtk)'" 2>/dev/null || \
            echo "theme-switch: warning: dconf write failed (no session bus?)" >&2
          if command -v xfconf-query >/dev/null; then
            xfconf-query -c xsettings -p /Net/ThemeName -s "$(get gtk)" 2>/dev/null || true
          fi

          # 5. Noctalia: our generated colorschemes are installed as custom
          if command -v noctalia >/dev/null; then
            noctalia msg color-scheme-set custom "$name" 2>/dev/null || \
              echo "theme-switch: warning: noctalia IPC failed (shell not running?)" >&2
          fi

          # 6. Make sure the VS Code theme extension exists (best effort, async)
          ext=$(get vscodeExt)
          if command -v code >/dev/null && ! code --list-extensions 2>/dev/null | grep -qix "$ext"; then
            (code --install-extension "$ext" >/dev/null 2>&1 || true) &
          fi

          echo "Theme: $name"
          echo "  live now:      Noctalia, niri, GTK, VS Code, Zed"
          echo "  next launch:   foot windows, fish/starship/fastfetch, nvim"
        '';
      };
    in
    {
      home.packages = [ themeSwitch ];

      xdg.configFile =
        {
          # Runtime-switchable app configs resolve through the state dir
          "fastfetch/config.jsonc".source =
            config.lib.file.mkOutOfStoreSymlink "${stateDir}/fastfetch.jsonc";
          "starship.toml".source =
            config.lib.file.mkOutOfStoreSymlink "${stateDir}/starship.toml";
        }
        # One Noctalia custom palette per theme
        // lib.mapAttrs' (slug: t: lib.nameValuePair
          "noctalia/palettes/${t.name}.json"
          { text = noctaliaScheme t; }) themes;

      # Bar widget + panel menu (files in config/noctalia/plugins/)
      xdg.dataFile."noctalia/plugins/theme-switcher".source =
        ../../config/noctalia/plugins/theme-switcher;

      # First boot / fresh install: state symlinks must exist before the first
      # foot/fastfetch launch. Seed the default palette without side effects.
      home.activation.themeSwitcherSeed =
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -e "${stateDir}/current" ]; then
            mkdir -p "${stateDir}"
            ln -sfn "${footConf themes.${palettes.default}}" "${stateDir}/foot.ini"
            ln -sfn "${starshipConf themes.${palettes.default}}" "${stateDir}/starship.toml"
            ln -sfn "${fastfetchConf themes.${palettes.default}}" "${stateDir}/fastfetch.jsonc"
            echo "${themes.${palettes.default}.apps.nvim.colorscheme}" > "${stateDir}/nvim"
            echo "${palettes.default}" > "${stateDir}/current"
          fi
        '';
    };
}
