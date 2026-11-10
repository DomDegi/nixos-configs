# Hybrid AMD + Nvidia graphics (PRIME offload; dGPU powers down when idle).
#
# Hang guard: the proprietary driver (seen on 595.112.07) can deadlock its
# RM lock when an ACPI power-source event (charger plug/unplug) races driver
# init — kworkers and a udev-worker sit in D state forever. That stalls
# `switch-to-configuration` (udevd won't stop) and makes poweroff hang.
# Shorter stop timeouts + the hardware watchdog (wdat_wdt) during shutdown
# turn "hold the power button" into a ~1 min forced reset.
{
  flake.modules.nixos.nvidia = {
    systemd.settings.Manager = {
      DefaultTimeoutStopSec = "20s";
      RebootWatchdogSec = "1min";
    };

    # Enable OpenGL
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Load the official Nvidia driver
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;

      # Completely powers down the Nvidia GPU when not in use
      powerManagement.finegrained = true;

      open = false; # Uses the stable proprietary drivers
      nvidiaSettings = true;

      # PRIME (Hybrid) Configuration using your specific hardware IDs
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };

        amdgpuBusId = "PCI:6:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
}
