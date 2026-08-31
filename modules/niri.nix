# Niri compositor: system-side enablement + portals, and the user-side
# config.kdl (kept as a raw file in config/, editable without a rebuild
# thanks to the out-of-store symlink).
{
  flake.modules.nixos.niri = { pkgs, ... }: {
    # Enable XWayland directly for older apps, without installing the full X11 server
    programs.xwayland.enable = true;

    # Enable Niri (Our Wayland Compositor/Window Manager)
    programs.niri.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = "*";
    };

    environment.systemPackages = with pkgs; [
      xwayland-satellite
      brightnessctl
      wl-clipboard
    ];

    # Allow brightnessctl to write to backlight without sudo
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="nvidia_wmi_ec_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
    '';

    # Deliberately NOT setting systemd.user.services.niri.enableDefaultPath:
    # doing so makes NixOS construct an explicit Environment=PATH= for the
    # unit, which REPLACES (not appends to) the full PATH niri.service
    # otherwise correctly inherits from the systemd --user manager's own
    # environment (which already has the home-manager profile + system
    # profile). A prior "fix" here forced it to `true`, which shrank niri's
    # PATH down to just coreutils/findutils/gnugrep/gnused/systemd —
    # breaking every `spawn`/`spawn-sh` keybind for anything not in that
    # tiny set (foot, display-mode, noctalia, firefox, thunar, sh itself).
    # Leave this option alone; the default is correct.
  };

  flake.modules.homeManager.niri = { config, pkgs, ... }: {
    # Media keys in config.kdl spawn playerctl
    home.packages = [ pkgs.playerctl ];

    # Out-of-store symlink: edits apply on niri's live-reload, no rebuild.
    xdg.configFile."niri/config.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "/persist/nixos-configs/config/niri/config.kdl";
  };
}
