# Hybrid AMD + Nvidia graphics (PRIME offload; dGPU powers down when idle).
{
  flake.modules.nixos.nvidia = {
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
