# Impermanence: what survives the ephemeral-root wipe (see
# ephemeral-root.nix). /home lives on the wiped @ subvolume too, so user
# state must be listed here — anything not listed dies at reboot.
{ inputs, ... }:

{
  flake.modules.nixos.persistence = {
    imports = [ inputs.impermanence.nixosModules.impermanence ];

    environment.persistence."/persist" = {
      hideMounts = true;

      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/lib/docker" # Docker images/volumes otherwise vanish on reboot
        "/etc/NetworkManager/system-connections"
      ];

      files = [
        "/etc/machine-id"
        "/etc/ly/save.txt" # Ly login screen: remembers the last logged-in user
      ];

      users.domdegi = {
        directories = [
          # Standard folders
          "Documents"
          "Downloads"
          "Pictures"
          "Music"
          "Videos"
          "projects"

          ".vscode"

          # Security
          ".ssh"
          ".gnupg"
          ".local/share/keyrings"
          ".step"

          # Claude Code (login token, settings, session history)
          ".claude"

          # Application State
          ".config/mozilla"
          ".config/spotify"
          ".config/spicetify" # theme-switch edits config-xpui.ini; Backup/ per Spotify version
          ".config/obsidian"
          ".config/Code"
          ".config/noctalia"
          ".config/dconf"
          ".config/webeep-sync"
          ".config/pulse" # PulseAudio/PipeWire auth cookie

          ".cache/noctalia"
          ".cache/spotify"

          # Noctalia v5 keeps runtime state (lockscreen widgets, palettes,
          # plugins) here; without persistence it re-runs first-time init
          # on every boot, which crashes the current build.
          ".local/state/noctalia"

          # WirePlumber remembers default sink/source, per-device volumes and
          # the last-used bluetooth profile here — without it every reboot
          # forgets which audio device/profile you last used.
          ".local/state/wireplumber"

          # Active theme selection + per-theme config symlinks that
          # foot/starship/fastfetch/nvim resolve through (theme-switch)
          ".local/state/theme"

          # Desktop entries created at runtime (e.g. Claude Code URL handler)
          ".local/share/applications"

          # Writable Spotify copy that spicetify patches (spicetify.nix);
          # losing it just means a re-copy on next activation, but that's slow
          ".local/share/spicetify-spotify"

          # Development / Terminal
          ".local/share/fish"
          ".local/share/direnv"
          ".local/share/nvim" # Optional: Keeps you from re-downloading plugins on boot
          ".local/share/zoxide"

          # Theming
          ".icons"
          ".local/share/icons"
        ];
        files = [
          ".face"
          ".bash_history"
          ".claude.json" # Claude Code main config/auth file
        ];
      };
    };
  };
}
