# Time zone, locales, console keymap and TTY theming.
{
  flake.modules.nixos.locale = { lib, ... }:
    let
      palettes = import ./theme/_palettes.nix;
      t = palettes.themes.${palettes.default};
      raw = c: lib.removePrefix "#" c;
    in
    {
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

    # Italian keyboard map + TTY colors from the DEFAULT palette
    # (modules/theme/_palettes.nix — the console can't switch at runtime)
    console = {
      keyMap = "it";
      colors = map raw [
        t.ui.bg # 0: background
        t.ansi.red
        t.ansi.green
        t.ansi.yellow
        t.ansi.blue
        t.ansi.magenta
        t.ansi.cyan
        t.ui.fg # 7: foreground
        t.ansi.brightBlack
        t.ansi.brightRed
        t.ansi.brightGreen
        t.ansi.brightYellow
        t.ansi.brightBlue
        t.ansi.brightMagenta
        t.ansi.brightCyan
        t.ansi.brightWhite
      ];
    };

    services.xserver.xkb = {
      layout = "it";
      variant = "";
    };
  };
}
