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
| `nix.nix` | `allowUnfree`, weekly GC, store auto-optimise, flakes enabled, autoUpgrade (off), **nh** (`nh os switch`, flake path preset) + `nvd`. No overlays. |
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

One fixed look baked in directly (neutral Adwaita-dark apps, Catppuccin Mocha accents in terminal/compositor/greeter) — no runtime
palette switching, no `theme/` indirection.

| Module | Does |
|---|---|
| `theming.nix` | GTK3/4 Adwaita-dark (neutral dark grey, built into GTK) + Papirus-Dark icons with **grey folders** (`papirus-icon-theme.override { color = "grey"; }`) + Catppuccin cursors + fonts + dconf/xfconf + GTK bookmarks. Deliberately does NOT set `GTK_THEME` (would pin GTK3 apps globally); `gtk-{3,4}.0/settings.ini` come from the `gtk` HM module directly. Never keep an icon-theme copy in `~/.local/share/icons` (persisted) — it shadows the Nix one. |
| `wallpaper.nix` | Wallpapers in `~/Pictures/Wallpapers/` (flat, auto-created): `wallpaper-pick` script (list/status/set-by-index → `noctalia msg wallpaper-set`) + `domdegi/wallpaper-picker` Noctalia widget (bar button + panel menu rendering `ui.image` thumbnails in a 2-col grid, active one bordered). |

## Desktop

| Module | Does |
|---|---|
| `niri.nix` | Niri + XWayland(-satellite), GTK portal, brightnessctl + backlight udev rule, niri PATH fix; HM: `config/niri/config.kdl` (out-of-store symlink → live reload), playerctl. |
| `greeter.nix` | Ly TTY login (static Catppuccin colors, no animation), gnome-keyring + PAM unlock on login. |
| `noctalia.nix` | Noctalia v5 via HM module: systemd service, theme seed, **the only owner of `plugins.enabled`**. Runtime truth = `~/.local/state/noctalia/settings.toml` (persisted, GUI-managed). |
| `display-mode.nix` | HM: `display-mode` script (extend ↔ mirror via wl-mirror; also Mod+P in config.kdl) + its Noctalia widget. |
| `thunar.nix` | Thunar + volman plugin, gvfs, tumbler; HM: xarchiver (double-click archives), foot as "open terminal here", and right-click custom actions in `~/.config/Thunar/uca.xml`: **Extract Here** (`extract-here`: bsdtar → 7z fallback, lifts a single top-level folder), **Compress to .zip** (`compress-zip`), Open in VS Code / Zed, Open Terminal Here. |

## Applications

| Module | Does |
|---|---|
| `terminal.nix` | Foot (transparency; static Catppuccin Mocha colors), fish (aliases → eza/bat/btop, fastfetch greeting), Starship (static Catppuccin palette prompt) + fastfetch (plain default layout), zoxide, **fzf** (Ctrl+R/Ctrl+T/Alt+C); system CLI basics (wget, p7zip, unzip, step-cli). |
| `dev.nix` | Docker (+ `docker` group), micro as `$EDITOR`/`$VISUAL`, nix-ld (unpatched prebuilt binaries: Julia artifacts, extension-downloaded LSPs), git (identity, main default branch), direnv + nix-direnv, gcc, fd/ripgrep/jq, claude-code. |
| `documents.nix` | HM: pandoc + tectonic (md→PDF), ocrmypdf (scans→searchable), typst. |
| `desktop-apps.nix` | Spotify (plain, unthemed — see below), Obsidian, LibreOffice, media tools (mpv/imv/snapshot/kooha/calculator), seahorse/libsecret, webeep-sync (keyring-wrapped). |
| `default-apps.nix` | `xdg.mimeApps` for everything: code/text → **Zed** (VS Code pre-listed in "Open With"), `.ipynb`/`.R`/`.Rmd`/`.qmd` → **VS Code** (Zed + RStudio listed), `.Rproj` → RStudio, PDF → `open-pdf` (**Obsidian** if the file is inside a vault from `~/.config/obsidian/obsidian.json`, else **Firefox**), HTML/SVG → Firefox, images → imv, audio/video → mpv, office/CSV → LibreOffice, archives → xarchiver. Adds R/Rmd/Quarto/Rproj MIME types and `rstudio-project` (runs `nix develop <nearest flake>#rstudio -c rstudio`). |
| `firefox.nix` | System enable, no enterprise policies. Profile lives in persisted `~/.config/mozilla`. |
| `vscode.nix` | VS Code; `config/vscode/settings.json` via out-of-store symlink (GUI edits land in git). |
| `zed.nix` | Zed (default editor for code/text; extensions persisted in `~/.local/share/zed`); `config/zed/settings.json` via out-of-store symlink. |

## Raw configs (`config/`)

Hand-edited files symlinked out-of-store (writable, git-tracked):
`niri/config.kdl`, `vscode/settings.json`,
`zed/settings.json`, and four Noctalia Luau plugins (`battery-conserve`,
`display-mode`, `airpods-audio`, `wallpaper-picker` — the last adds a
`panel.luau` menu), linked store-copied into `~/.local/share/noctalia/plugins/`
by their feature modules.
