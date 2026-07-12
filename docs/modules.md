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

## Theming (runtime-switchable)

| Module | Does |
|---|---|
| `theme/_palettes.nix` | **Single source of truth for every color**: 7 palettes (Catppuccin Lavender default, Tokyo Night, Gruvbox, Nord, Rosé Pine, Dracula, Everforest) with ANSI-16 + UI roles + per-app bindings (nvim colorscheme, VS Code/Zed theme names, GTK theme, Firefox AMO theme id+slug). `_`-prefixed → imported manually, not by import-tree. **Adding a theme = adding one attrset here.** |
| `theme/switcher.nix` | Generates per-palette foot/starship/fastfetch/GTK-settings.ini configs + Noctalia custom palettes; ships `theme-switch` (repoints `~/.local/state/theme` symlinks incl. `gtk.ini`, edits VS Code/Zed settings + niri `// theme:` markers, dconf GTK, `papirus-folders` recolor + `thunar -q`, Noctalia IPC, Firefox theme via user.js + extensions.json, `spicetify config color_scheme` + `refresh`, Obsidian per-vault `accentColor`) and links the `domdegi/theme-switcher` bar widget + panel menu. Picking a theme in the panel transitions it in place to a wallpaper thumbnail roster for the new theme (no separate auto-opened panel). |
| `theming.nix` | GTK3/4 + Papirus icons + cursors + fonts + dconf/xfconf + GTK bookmarks. Default GTK theme name comes from the palette; **all** palettes' GTK theme packages are installed so runtime switching always has its target. Deliberately does NOT set `GTK_THEME` (it would pin GTK3 apps and defeat theme-switch); `gtk-{3,4}.0/settings.ini` are overridden by `theme/switcher.nix` to route through the state dir. Keeps a **writable Papirus-Dark copy** in `~/.local/share/icons` (shadows the store; refreshed on package updates) so `papirus-folders` can recolor folder icons per palette (`apps.papirus`) — the copy dereferences the upstream theme's `../Papirus/<size>` symlinks (32/48/64/96/128/84/8x8) since those break once copied out of the store; only `places` is a real writable dir per size, everything else stays symlinked absolute into the store. |
| `wallpaper.nix` | Per-theme wallpapers in `~/Pictures/Wallpapers/<slug>/` (folders auto-created from the palette list): `wallpaper-pick` script (list/status/set-by-index → `noctalia msg wallpaper-set`) + `domdegi/wallpaper-picker` Noctalia widget (bar button + standalone panel menu rendering `ui.image` thumbnails in a 2-col grid, active one bordered) for picking a wallpaper without switching themes. |

## Desktop

| Module | Does |
|---|---|
| `niri.nix` | Niri + XWayland(-satellite), GTK portal, brightnessctl + backlight udev rule, niri PATH fix; HM: `config/niri/config.kdl` (out-of-store symlink → live reload), playerctl. |
| `greeter.nix` | Ly TTY login (colors from the default palette, no animation), gnome-keyring + PAM unlock on login. |
| `noctalia.nix` | Noctalia v5 via HM module: systemd service, theme seed, **the only owner of `plugins.enabled`**. Runtime truth = `~/.local/state/noctalia/settings.toml` (persisted, GUI-managed). |
| `display-mode.nix` | HM: `display-mode` script (extend ↔ mirror via wl-mirror; also Mod+P in config.kdl) + its Noctalia widget. |
| `thunar.nix` | Thunar + archive/volman plugins, gvfs, tumbler; HM: xarchiver, foot as Thunar's "open terminal here". |

## Applications

| Module | Does |
|---|---|
| `terminal.nix` | Foot (transparency; colors via `~/.local/state/theme/foot.ini` include), fish (aliases → eza/bat/btop, fastfetch greeting), Starship + fastfetch (per-theme configs generated by `theme/switcher.nix`), zoxide, **fzf** (Ctrl+R/Ctrl+T/Alt+C); system CLI basics (wget, p7zip, unzip, step-cli). |
| `dev.nix` | Docker (+ `docker` group), git (identity, main default branch), direnv + nix-direnv, gcc, fd/ripgrep/jq, claude-code. |
| `nvim.nix` | Neovim + LSPs (nil, lua, pyright, clang-tools, R, marksman) + treesitter bundle; `config/nvim/init.lua` via out-of-store symlink (colorscheme follows `~/.local/state/theme/nvim`). |
| `documents.nix` | HM: **markitdown** (anything→md), pandoc + tectonic (md→PDF), ocrmypdf (scans→searchable), typst. |
| `desktop-apps.nix` | Spotify, Obsidian, LibreOffice, media tools (mpv/imv/snapshot/kooha/calculator), zathura, seahorse/libsecret, webeep-sync (keyring-wrapped); `xdg.mimeApps` defaults. |
| `firefox.nix` | System enable + enterprise policies that force-install every palette's AMO theme addon; `theme-switch` activates one via `extensions.activeThemeID` in each profile's user.js (applies on next launch). Profile lives in persisted `~/.config/mozilla`. |
| `spicetify.nix` | Spotify skinned with the active palette: keeps a **writable copy** of Spotify under `~/.local/share/spicetify-spotify` (store path is read-only; refreshed on Spotify updates), patches it with `spicetify backup apply` (only marked done on actual success, so a failed attempt retries next activation instead of getting stuck unthemed), generates one color scheme per palette from `_palettes.nix`, and shadows `spotify` (hiPrio bin + desktop entry) so the patched copy is what runs. `theme-switch` flips the scheme with `spicetify refresh`. |
| `vscode.nix` | VS Code; `config/vscode/settings.json` via out-of-store symlink (GUI edits land in git). |
| `zed.nix` | Zed; `config/zed/settings.json` via out-of-store symlink. |

## Raw configs (`config/`)

Hand-edited files symlinked out-of-store (writable, git-tracked):
`niri/config.kdl` (keep the `// theme:` marker comments — theme-switch seds
those lines), `nvim/init.lua`, `vscode/settings.json`, `zed/settings.json`
(the last two are also *written* by theme-switch), and five Noctalia Luau
plugins (`battery-conserve`, `display-mode`, `airpods-audio`,
`theme-switcher` and `wallpaper-picker` — the last two each add a
`panel.luau` menu), linked store-copied into `~/.local/share/noctalia/plugins/`
by their feature modules.
