# Lenovo IdeaPad battery conservation mode (charge cap at ~60%):
# sysfs permission rule, toggle script + sudo rule, and the Noctalia
# bar widget. The whole feature in one file.
{
  flake.modules.nixos.battery-conserve = { pkgs, ... }: {
    services.upower.enable = true;

    # 1. Create the group required by the Noctalia plugin
    users.groups.battery_ctl = { };

    # 2. Add your user to that group
    users.users.domdegi.extraGroups = [ "battery_ctl" ];

    # 3. Make the sysfs flag world-readable / group-writable
    systemd.tmpfiles.rules = [
      "z /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode 0664 root battery_ctl -"
    ];

    # Custom Lenovo Battery Conservation Toggle
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "battery-conserve" ''
        MODE_PATH="/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode"

        # --- UI STATUS CHECK (No Sudo Required) ---
        if [ "$1" == "status" ]; then
          CURRENT=$(cat "$MODE_PATH")
          if [ "$CURRENT" -eq 1 ]; then
            echo "󰚥 60%"  # Plugged in/Capped icon
          else
            echo "󰁹 100%" # Full battery icon
          fi
          exit 0
        fi

        # --- TOGGLE/WRITE COMMANDS (Sudo Required) ---
        if [ "$EUID" -ne 0 ]; then
          echo "Please run as root: sudo battery-conserve [on|off|toggle|status]"
          exit 1
        fi

        if [ "$1" == "on" ]; then
          echo 1 > "$MODE_PATH"
          echo "Battery Conservation Mode: ON (Caps at ~60%)"
        elif [ "$1" == "off" ]; then
          echo 0 > "$MODE_PATH"
          echo "Battery Conservation Mode: OFF (Charges to 100%)"
        elif [ "$1" == "toggle" ]; then
          CURRENT=$(cat "$MODE_PATH")
          if [ "$CURRENT" -eq 1 ]; then
            echo 0 > "$MODE_PATH"
          else
            echo 1 > "$MODE_PATH"
          fi
        else
          echo "Usage: sudo battery-conserve [on|off|toggle|status]"
        fi
      '')
    ];

    security.sudo.extraRules = [
      {
        users = [ "domdegi" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/battery-conserve";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  flake.modules.homeManager.battery-conserve = {
    # Bar widget for the conservation toggle
    xdg.dataFile."noctalia/plugins/battery-conserve".source =
      ../config/noctalia/plugins/battery-conserve;
  };
}
