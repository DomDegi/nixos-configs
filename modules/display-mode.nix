# Extend <-> mirror toggle for the external monitor / projectors:
# the display-mode script (wl-mirror based, niri has no native mirroring),
# its Noctalia bar widget, and the Mod+P keybind in niri's config.kdl.
{
  flake.modules.homeManager.display-mode = { pkgs, ... }: {
    home.packages = [
      pkgs.wl-mirror # mirrors an output onto another

      (pkgs.writeShellScriptBin "display-mode" ''
        JQ=${pkgs.jq}/bin/jq
        outs=$(niri msg --json outputs)
        internal=$(printf '%s' "$outs" | "$JQ" -r 'keys_unsorted[] | select(startswith("eDP"))' | head -n1)
        external=$(printf '%s' "$outs" | "$JQ" -r 'keys_unsorted[] | select(startswith("eDP") | not)' | head -n1)

        running() { ${pkgs.procps}/bin/pgrep -x wl-mirror >/dev/null; }

        case "''${1:-status}" in
          status)
            if [ -z "$external" ]; then
              echo single
            elif running; then
              echo mirror
            else
              echo extend
            fi
            ;;
          mirror)
            if [ -z "$external" ]; then
              echo "No external monitor connected" >&2
              exit 1
            fi
            running || ${pkgs.util-linux}/bin/setsid -f \
              ${pkgs.wl-mirror}/bin/wl-mirror --fullscreen-output "$external" "$internal" \
              >/dev/null 2>&1
            ;;
          extend)
            ${pkgs.procps}/bin/pkill -x wl-mirror 2>/dev/null || true
            ;;
          toggle)
            if running; then "$0" extend; else "$0" mirror; fi
            ;;
          *)
            echo "Usage: display-mode [status|mirror|extend|toggle]" >&2
            exit 1
            ;;
        esac
      '')
    ];

    # Bar widget: extend <-> mirror toggle
    xdg.dataFile."noctalia/plugins/display-mode".source =
      ../config/noctalia/plugins/display-mode;
  };
}
