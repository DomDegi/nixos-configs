# PipeWire audio stack. Bluetooth/AirPods specifics live in
# bluetooth-airpods.nix.
{
  flake.modules.nixos.audio = { pkgs, ... }: {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    environment.systemPackages = [ pkgs.pavucontrol ];
  };

  flake.modules.homeManager.audio = { pkgs, ... }: {
    # Only for the pactl CLI; the daemon stays disabled (PipeWire)
    home.packages = [ pkgs.pulseaudio ];
  };
}
