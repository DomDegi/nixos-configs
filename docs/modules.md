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
| `nix.nix` | `allowUnfree`, weekly GC, store auto-optimise, flakes enabled, autoUpgrade (off), **nh** (`nh os switch`, flake path preset) + `nvd`. Also carries an overlay patching known-broken upstream packages: catppuccin-gtk (python3.13 pin), gruvbox/tokyonight-gtk-theme (strip invalid `border-spacing` CSS causing GTK3 parse warnings). |
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

## Theming (static)

One fixed look (Catppuccin Mocha Lavender) baked in directly — no runtime
palette switching, no `theme/` indirection.

| Module | Does |
|---|---|
| `theming.nix` | GTK3/4 + Papirus icons (stock, unrecolored) + cursors + fonts + dconf/xfconf + GTK bookmarks, all static Catppuccin Mocha Lavender. Deliberately does NOT set `GTK_THEME` (would pin GTK3 apps globally); `gtk-{3,4}.0/settings.ini` come from the `gtk` HM module directly. |
| `wallpaper.nix` | Wallpapers in `~/Pictures/Wallpapers/` (flat, auto-created): `wallpaper-pick` script (list/status/set-by-index → `noctalia msg wallpaper-set`) + `domdegi/wallpaper-picker` Noctalia widget (bar button + panel menu rendering `ui.image` thumbnails in a 2-col grid, active one bordered). |

## Desktop

| Module | Does |
|---|---|
| `niri.nix` | Niri + XWayland(-satellite), GTK portal, brightnessctl + backlight udev rule, niri PATH fix; HM: `config/niri/config.kdl` (out-of-store symlink → live reload), playerctl. |
| `greeter.nix` | Ly TTY login (static Catppuccin colors, no animation), gnome-keyring + PAM unlock on login. |
| `noctalia.nix` | Noctalia v5 via HM module: systemd service, theme seed, **the only owner of `plugins.enabled`**. Runtime truth = `~/.local/state/noctalia/settings.toml` (persisted, GUI-managed). |
| `display-mode.nix` | HM: `display-mode` script (extend ↔ mirror via wl-mirror; also Mod+P in config.kdl) + its Noctalia widget. |
| `thunar.nix` | Thunar + archive/volman plugins, gvfs, tumbler; HM: xarchiver, foot as Thunar's "open terminal here". |

## Applications

| Module | Does |
|---|---|
| `terminal.nix` | Foot (transparency; static Catppuccin Mocha colors), fish (aliases → eza/bat/btop, fastfetch greeting), Starship (static Catppuccin palette prompt) + fastfetch (plain default layout), zoxide, **fzf** (Ctrl+R/Ctrl+T/Alt+C); system CLI basics (wget, p7zip, unzip, step-cli). |
| `dev.nix` | Docker (+ `docker` group), nix-ld (unpatched prebuilt binaries: Julia artifacts, extension-downloaded LSPs), git (identity, main default branch), direnv + nix-direnv, gcc, fd/ripgrep/jq, claude-code. |
| `nvim.nix` | Neovim: LazyVim starter under `config/nvim/` (out-of-store symlink for the whole directory, LazyVim edits incl. `lazy-lock.json` land in the repo) + LSPs (nil, lua, pyright, clang-tools, R, marksman) provided by Nix — mason is disabled in `lua/plugins/lsp.lua` so it never needs the network. |
| `documents.nix` | HM: **markitdown** (anything→md), pandoc + tectonic (md→PDF), ocrmypdf (scans→searchable), typst. |
| `desktop-apps.nix` | Spotify (plain, unthemed — see below), Obsidian, LibreOffice, media tools (mpv/imv/snapshot/kooha/calculator), zathura, seahorse/libsecret, webeep-sync (keyring-wrapped); `xdg.mimeApps` defaults. |
| `firefox.nix` | System enable, no enterprise policies. Profile lives in persisted `~/.config/mozilla`. |
| `vscode.nix` | VS Code; `config/vscode/settings.json` via out-of-store symlink (GUI edits land in git). |
| `zed.nix` | Zed; `config/zed/settings.json` via out-of-store symlink. |

## Raw configs (`config/`)

Hand-edited files symlinked out-of-store (writable, git-tracked):
`niri/config.kdl`, `nvim/` (the whole LazyVim tree — `init.lua`, `lua/config/`,
`lua/plugins/`, and `lazy-lock.json` once LazyVim writes it), `vscode/settings.json`,
`zed/settings.json`, and four Noctalia Luau plugins (`battery-conserve`,
`display-mode`, `airpods-audio`, `wallpaper-picker` — the last adds a
`panel.luau` menu), linked store-copied into `~/.local/share/noctalia/plugins/`
by their feature modules.
