# Bluetooth tuned for AirPods Pro, plus the airpods-audio profile
# switcher script and its Noctalia bar widget.
# Music = A2DP (quality, no mic), Call = HFP (mic works).
{
  flake.modules.nixos.bluetooth-airpods = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          # Disable experimental mode to stop BAP/LE Audio panic
          Experimental = false;

          # Force Classic Bluetooth (highly recommended for AirPods)
          ControllerMode = "bredr";

          JustWorksRepairing = "always";
        };
      };
    };

    # Forces Pipewire to ignore broken LE-Audio and use stable AAC/A2DP for AirPods
    services.pipewire.wireplumber.extraConfig."10-bluez" = {
      "monitor.bluez.properties" = {
        # AirPods report broken absolute (hardware) volume over HFP, which is
        # what made calls whisper-quiet. Software volume instead.
        "bluez5.enable-hw-volume" = false;
        # Wideband-speech (mSBC) makes the AirPods mic actually usable;
        # PipeWire falls back to CVSD if the SCO link refuses it.
        "bluez5.enable-msbc" = true;
        "bluez5.enable-sbc-xq" = true;
        # Removed 'bap_sink' and 'bap_source'
        "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "hfp_hf" "hfp_ag" ];
      };
    };
  };

  flake.modules.homeManager.bluetooth-airpods = { pkgs, ... }: {
    home.packages = [
      # AirPods profile switcher: music (A2DP, no mic) <-> call (HFP, mic works).
      # Used by the Noctalia airpods-audio widget.
      (pkgs.writeShellScriptBin "airpods-audio" ''
        PACTL=${pkgs.pulseaudio}/bin/pactl
        JQ=${pkgs.jq}/bin/jq
        MAC="74_77_86_3C_A9_35"
        CARD="bluez_card.$MAC"

        active_profile() {
          "$PACTL" --format=json list cards \
            | "$JQ" -r --arg c "$CARD" '.[] | select(.name==$c) | .active_profile'
        }

        state() {
          case "$(active_profile)" in
            a2dp*)    echo music ;;
            headset*) echo call ;;
            "")       echo disconnected ;;
            *)        echo other ;;
          esac
        }

        # Make the AirPods the default sink (and source in call mode);
        # profile switches leave PipeWire volumes in odd states, so reset them.
        bt_defaults() {
          sleep 1
          sink=$("$PACTL" --format=json list sinks \
            | "$JQ" -r --arg m "$MAC" '.[] | select(.name | contains($m)) | .name' | head -n1)
          src=$("$PACTL" --format=json list sources \
            | "$JQ" -r --arg m "$MAC" '.[] | select(.name | startswith("bluez_input")) | select(.name | contains($m)) | .name' | head -n1)
          if [ -n "$sink" ]; then
            "$PACTL" set-default-sink "$sink"
            "$PACTL" set-sink-mute "$sink" 0
          fi
          if [ -n "$src" ]; then
            "$PACTL" set-default-source "$src"
            "$PACTL" set-source-volume "$src" 100%
            "$PACTL" set-source-mute "$src" 0
            # HFP starts whisper-quiet even with hw-volume disabled
            [ -n "$sink" ] && "$PACTL" set-sink-volume "$sink" 100%
          fi
        }

        case "''${1:-status}" in
          status)
            state
            ;;
          call)
            "$PACTL" set-card-profile "$CARD" headset-head-unit || exit 1
            bt_defaults
            ;;
          music)
            "$PACTL" set-card-profile "$CARD" a2dp-sink || exit 1
            bt_defaults
            ;;
          toggle)
            case "$(state)" in
              call)         exec "$0" music ;;
              music|other)  exec "$0" call ;;
              *)            echo "AirPods not connected" >&2; exit 1 ;;
            esac
            ;;
          *)
            echo "Usage: airpods-audio [status|call|music|toggle]" >&2
            exit 1
            ;;
        esac
      '')
    ];

    # Bar widget: AirPods music <-> call profile switcher
    xdg.dataFile."noctalia/plugins/airpods-audio".source =
      ../config/noctalia/plugins/airpods-audio;
  };
}
