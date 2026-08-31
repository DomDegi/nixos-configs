# Time zone, locales, console keymap and TTY colors (static Catppuccin
# Lavender — the console can't follow a runtime theme, so this is just
# literal hex, no palette indirection).
{
  flake.modules.nixos.locale = {
    time.timeZone = "Europe/Rome";
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "it_IT.UTF-8";
      LC_IDENTIFICATION = "it_IT.UTF-8";
      LC_MEASUREMENT = "it_IT.UTF-8";
      LC_MONETARY = "it_IT.UTF-8";
      LC_NAME = "it_IT.UTF-8";
      LC_NUMERIC = "it_IT.UTF-8";
      LC_PAPER = "it_IT.UTF-8";
      LC_TELEPHONE = "it_IT.UTF-8";
      LC_TIME = "it_IT.UTF-8";
    };

    # Italian keyboard map + TTY colors (Catppuccin Mocha Lavender)
    console = {
      keyMap = "it";
      colors = [
        "1e1e2e" # 0: background
        "f38ba8"
        "a6e3a1"
        "f9e2af"
        "89b4fa"
        "f5c2e7"
        "94e2d5"
        "cdd6f4" # 7: foreground
        "585b70"
        "f38ba8"
        "a6e3a1"
        "f9e2af"
        "89b4fa"
        "f5c2e7"
        "94e2d5"
        "a6adc8"
      ];
    };

    services.xserver.xkb = {
      layout = "it";
      variant = "";
    };
  };
}
