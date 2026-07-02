# Ly TTY login screen + keyring unlock on login.
{
  flake.modules.nixos.greeter = {
    services.displayManager.ly = {
      enable = true;
      settings = {
        # Disable animations for a clean, minimal look
        animation = "none";

        # Box Colors (Catppuccin Mocha)
        bg = "0x001e1e2e";
        fg = "0x00cdd6f4";
        border_fg = "0x00b4befe";
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
