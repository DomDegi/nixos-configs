# Time zone, locales, console keymap and TTY theming.
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

    # Set Italian Keyboard map and Catppuccin TTY Colors!
    console = {
      keyMap = "it";
      colors = [
        "1e1e2e" # 0: Base (Background)
        "f38ba8" # 1: Red
        "a6e3a1" # 2: Green
        "f9e2af" # 3: Yellow
        "89b4fa" # 4: Blue
        "f5c2e7" # 5: Magenta (Pink)
        "94e2d5" # 6: Cyan (Teal)
        "cdd6f4" # 7: Text (Foreground)
        "585b70" # 8: Bright Black (Surface 2)
        "f38ba8" # 9: Bright Red
        "a6e3a1" # 10: Bright Green
        "f9e2af" # 11: Bright Yellow
        "89b4fa" # 12: Bright Blue
        "f5c2e7" # 13: Bright Magenta
        "94e2d5" # 14: Bright Cyan
        "a6adc8" # 15: Bright White
      ];
    };

    services.xserver.xkb = {
      layout = "it";
      variant = "";
    };
  };
}
