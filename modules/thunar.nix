# Thunar file manager + its "open terminal here" integration with foot.
{
  flake.modules.nixos.thunar = { pkgs, ... }: {
    programs.thunar.enable = true;
    programs.xfconf.enable = true;
    programs.thunar.plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];

    # Required by Thunar for Trash, USB auto-mounting, and network drives
    services.gvfs.enable = true;
    # Required by Thunar to generate image thumbnails
    services.tumbler.enable = true;
  };

  flake.modules.homeManager.thunar = { pkgs, ... }: {
    # GUI backend for Thunar to unzip files
    home.packages = [ pkgs.xarchiver ];

    # 1. Tell XFCE/Thunar to use Foot as the default terminal emulator
    xdg.configFile."xfce4/helpers.rc".text = ''
      TerminalEmulator=foot
    '';

    # 2. Teach XFCE how to launch Foot and pass the current directory to it
    xdg.dataFile."xfce4/helpers/foot.desktop".text = ''
      [Desktop Entry]
      Version=1.0
      Icon=foot
      Type=X-XFCE-Helper
      Name=Foot
      StartupNotify=false
      X-XFCE-Binaries=foot;
      X-XFCE-Category=TerminalEmulator
      X-XFCE-Commands=%B;
      X-XFCE-CommandsWithParameter=%B -D %s;
    '';
  };
}
