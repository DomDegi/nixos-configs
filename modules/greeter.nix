# Ly TTY login screen + keyring unlock on login.
{
  flake.modules.nixos.greeter = { lib, ... }:
    let
      palettes = import ./theme/_palettes.nix;
      t = palettes.themes.${palettes.default};
      ly = c: "0x00${lib.removePrefix "#" c}";
    in
    {
    services.displayManager.ly = {
      enable = true;
      settings = {
        # Disable animations for a clean, minimal look
        animation = "none";

        # Box colors from the DEFAULT palette (runs before login —
        # can't follow runtime theme switches)
        bg = ly t.ui.bg;
        fg = ly t.ui.fg;
        border_fg = ly t.ui.accent;
        hide_borders = false;
        blank_box = true;
        clock = "%c";
      };
    };

    services.gnome.gnome-keyring.enable = true;

    # Ensure the Ly Display Manager unlocks the keyring on login
    security.pam.services.ly.enableGnomeKeyring = true;
  };
}
