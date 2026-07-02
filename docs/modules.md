# Module reference

Every `.nix` file under `modules/` is auto-imported by import-tree and is one
*feature*: it may contribute a `flake.modules.nixos.<name>` half (system), a
`flake.modules.homeManager.<name>` half (user), or both. Prefix a file with
`_` to disable it without deleting it.

> Keep this file in sync: one entry per module, updated in the same commit
> that changes the module.

## Infrastructure

| Module | Does |
|---|---|
| `hosts/nixos.nix` | Assembles `nixosConfigurations.nixos` from **all** `flake.modules.nixos.*` + `hardware-configuration.nix`; sets `hostName` and `stateVersion`. |
| `home-manager.nix` | HM↔NixOS wiring: pipes **all** `flake.modules.homeManager.*` into user `domdegi`; `useGlobalPkgs`, `backupFileExtension = "hm-bak"`, `home.stateVersion`. |
| `nix.nix` | `allowUnfree`, weekly GC, store auto-optimise, flakes enabled, autoUpgrade (off), **nh** (`nh os switch`, flake path preset) + `nvd`. |
| `secrets.nix` | sops-nix: `secrets/secrets.yaml` decrypted with age key at `/persist/var/lib/sops-nix/key.txt`; `domdegi-password-hash` has `neededForUsers` and feeds `hashedPasswordFile`. |
| `users.nix` | User `domdegi` (groups, fish shell, description), `mutableUsers = false`, system-level fish enable, `~/nixos-configs → /persist/nixos-configs` symlink. |

## Boot, storage, persistence

| Module | Does |
|---|---|
| `boot.nix` | GRUB (EFI, os-prober + manual Windows entry), latest kernel, NTFS support, `/mnt/shared` + `/mnt/windows` mounts and home symlinks. |
| `ephemeral-root.nix` | initrd service that moves the BTRFS `@` subvolume to `/old_roots/<timestamp>` and recreates it fresh on every boot; old roots kept 30 days. |
| `persistence.nix` | Impermanence allowlist: system dirs/files + user dirs/files under `/persist`. **If an app forgets state after reboot, its path is missing here.** |

## Hardware

| Module | Does |
|---|---|
| `nvidia.nix` | Hybrid AMD iGPU + Nvidia dGPU: PRIME offload (`nvidia-offload` cmd), fine-grained power management, proprietary driver. |
| `audio.nix` | PipeWire (+ALSA/pulse compat), rtkit, pavucontrol; HM: `pactl` CLI. |
| `bluetooth-airpods.nix` | BlueZ locked to Classic (`bredr`) for AirPods; WirePlumber: hw-volume off, mSBC + SBC-XQ on, no LE-Audio roles. HM: `airpods-audio` script (music/A2DP ↔ call/HFP + volume resets) + its Noctalia widget. |
| `battery-conserve.nix` | Lenovo conservation mode (cap ~60%): `battery_ctl` group + sysfs perms, `battery-conserve` script, NOPASSWD sudo rule; HM: Noctalia widget. |

## Desktop

| Module | Does |
|---|---|
| `niri.nix` | Niri + XWayland(-satellite), GTK portal, brightnessctl + backlight udev rule, niri PATH fix; HM: `config/niri/config.kdl` (out-of-store symlink → live reload), playerctl. |
| `greeter.nix` | Ly TTY login (Catppuccin, no animation), gnome-keyring + PAM unlock on login. |
| `noctalia.nix` | Noctalia v5 via HM module: systemd service, theme seed, **the only owner of `plugins.enabled`**. Runtime truth = `~/.local/state/noctalia/settings.toml` (persisted, GUI-managed). |
| `display-mode.nix` | HM: `display-mode` script (extend ↔ mirror via wl-mirror; also Mod+P in config.kdl) + its Noctalia widget. |
| `theming.nix` | Catppuccin Mocha Lavender everywhere: GTK3/4 theme + Papirus icons + cursors (system pkgs + HM gtk block), dconf/xfconf, fonts (JetBrainsMono Nerd, Noto), GTK bookmarks. |
| `thunar.nix` | Thunar + archive/volman plugins, gvfs, tumbler; HM: xarchiver, foot as Thunar's "open terminal here". |

## Applications

| Module | Does |
|---|---|
| `terminal.nix` | Foot (Catppuccin, transparency), fish (aliases → eza/bat/btop, fastfetch greeting), Starship prompt, fastfetch, zoxide, **fzf** (Ctrl+R/Ctrl+T/Alt+C); system CLI basics (wget, p7zip, unzip, step-cli). |
| `dev.nix` | Docker (+ `docker` group), git (identity, main default branch), direnv + nix-direnv, gcc, fd/ripgrep/jq, claude-code. |
| `nvim.nix` | Neovim + LSPs (nil, lua, pyright, clang-tools, R, marksman) + treesitter bundle; `config/nvim/init.lua` via out-of-store symlink. |
| `documents.nix` | HM: **markitdown** (anything→md), pandoc + tectonic (md→PDF), ocrmypdf (scans→searchable), typst. |
| `desktop-apps.nix` | Spotify, Obsidian, LibreOffice, media tools (mpv/imv/snapshot/kooha/calculator), zathura, seahorse/libsecret, webeep-sync (keyring-wrapped); `xdg.mimeApps` defaults. |
| `firefox.nix` | System-level enable only; profile lives in persisted `~/.config/mozilla`. |
| `vscode.nix` | VS Code; `config/vscode/settings.json` via out-of-store symlink (GUI edits land in git). |
| `zed.nix` | Zed; `config/zed/settings.json` via out-of-store symlink. |

## Raw configs (`config/`)

Hand-edited files symlinked out-of-store (writable, git-tracked):
`niri/config.kdl`, `nvim/init.lua`, `vscode/settings.json`, `zed/settings.json`,
and the three Noctalia Luau plugins (`battery-conserve`, `display-mode`,
`airpods-audio` — each `plugin.toml` + `widget.luau`, linked store-copied into
`~/.local/share/noctalia/plugins/` by their feature modules).
