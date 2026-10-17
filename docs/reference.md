# Module reference (generated)

> Do not edit by hand. Regenerate from the module header comments:
> `nix run .#docs > docs/reference.md`

## `audio.nix`

*Contributes to: homeManager nixos*

PipeWire audio stack. Bluetooth/AirPods specifics live in
bluetooth-airpods.nix.

## `battery-conserve.nix`

*Contributes to: homeManager nixos*

Lenovo IdeaPad battery conservation mode (charge cap at ~60%):
sysfs permission rule, toggle script + the Noctalia bar widget. The whole
feature in one file.

No sudo: the sysfs flag is made group-writable to `battery_ctl` (domdegi is
a member), so the toggle script writes it directly as the user. Simpler
and avoids sudo's tty/PATH quirks when invoked from Noctalia's Luau
runtime (which shells out via `/bin/sh -c`, no interactive tty).

## `bluetooth-airpods.nix`

*Contributes to: homeManager nixos*

Bluetooth tuned for AirPods Pro, plus the airpods-audio profile
switcher script and its Noctalia bar widget.
Music = A2DP (quality, no mic), Call = HFP (mic works).

## `boot.nix`

*Contributes to: nixos*

Bootloader (GRUB dual-boot with Windows), kernel, and the NTFS data
partitions shared with the Windows install.

## `default-apps.nix`

*Contributes to: homeManager*

Default applications per file type (xdg.mimeApps) and the small launchers
behind them:
 - open-pdf: PDFs inside an Obsidian vault open in Obsidian, all others
   in Firefox (vaults read from ~/.config/obsidian/obsidian.json).
 - rstudio-project: launches RStudio inside the nearest project flake's
   `rstudio` devshell (walks up from the file), so it sees that project's
   R packages. RStudio itself is never installed system-wide.
 - R / R Markdown / Quarto / .Rproj MIME types (shared-mime-info has none,
   so they'd be plain text).
Editors: Zed is the default for code/text (fast to open), VS Code for
notebooks, R, LaTeX and Typst (live preview); the other editors are
pre-listed in every "Open With" menu so they're one click away.

## `desktop-apps.nix`

*Contributes to: homeManager*

GUI applications (default file-type wiring lives in default-apps.nix).

## `dev.nix`

*Contributes to: homeManager nixos*

Development tooling: docker, git, direnv, nix-ld, micro ($EDITOR), compilers, search tools.

## `display-mode.nix`

*Contributes to: homeManager*

Extend <-> mirror toggle for the external monitor / projectors:
the display-mode script (wl-mirror based, niri has no native mirroring),
its Noctalia bar widget, and the Mod+P keybind in niri's config.kdl.

## `docs.nix`

*Contributes to: flake-parts*

Generated documentation: harvests each module's header comment into a
markdown reference (javadoc-style — docs live in the source).
Regenerate with:  nix run .#docs > docs/reference.md

## `documents.nix`

*Contributes to: homeManager*

Document tooling: writing, compiling and processing course material.
LaTeX (TeX Live medium + latexmk) and Typst (+ tinymist LSP) both preview
live in VS Code: LaTeX Workshop rebuilds on save, Tinymist on every
keystroke (config in config/vscode/settings.json; per-folder PDF export
lives in that folder's .vscode/settings.json, e.g. the Obsidian vault).

## `ephemeral-root.nix`

*Contributes to: nixos*

BTRFS ephemeral root: the @ subvolume is rolled back to a pristine
state in the initrd on every boot. Anything worth keeping must be
listed in persistence.nix.

## `firefox.nix`

*Contributes to: nixos*

Firefox: enabled system-wide; profile state lives in the persisted
~/.config/mozilla (declarative HM profiles would fight it for little gain).

## `greeter.nix`

*Contributes to: nixos*

Ly TTY login screen + keyring unlock on login.

## `home-manager.nix`

*Contributes to: homeManager nixos*

Home Manager <-> NixOS wiring. Every feature file's
flake.modules.homeManager.* contribution is imported into the user here.

## `hosts/nixos.nix`

*Contributes to: nixos*

Host assembly: builds nixosConfigurations.nixos from every module
declared under flake.modules.nixos.* (one per feature file).

## `locale.nix`

*Contributes to: nixos*

Time zone, locales, console keymap and TTY colors (static Catppuccin
Lavender — the console can't follow a runtime theme, so this is just
literal hex, no palette indirection).

## `network.nix`

*Contributes to: nixos*

Networking (hostname lives with the host in modules/hosts/).

## `niri.nix`

*Contributes to: homeManager nixos*

Niri compositor: system-side enablement + portals, and the user-side
config.kdl (kept as a raw file in config/, editable without a rebuild
thanks to the out-of-store symlink).

## `nix.nix`

*Contributes to: nixos*

Nix daemon settings, garbage collection, and nixpkgs policy.

## `noctalia.nix`

*Contributes to: homeManager*

Noctalia Shell v5 (bar + widgets + theming master).

NOTE on the two config files:
 - ~/.config/noctalia/config.toml  <- written from `settings` below, but
   noctalia v5 only reads it as a FIRST-RUN seed.
 - ~/.local/state/noctalia/settings.toml <- the runtime source of truth
   (bar layout, GUI edits). It is persisted via persistence.nix.
So `settings` here must stay minimal: theme + the plugin enable list
(which MUST live only in this file — freeform TOML lists don't merge
reliably across modules).

Theme source is "wallpaper": Noctalia's own Material-You-style extractor
(m3-content scheme) generates the palette from the active wallpaper, no
static/hardcoded palette anywhere. This also drives Noctalia's *builtin
template* pipeline (src/theme/builtin_templates.cpp upstream) — enabling
the "foot" template makes Noctalia write
~/.config/foot/themes/noctalia from the SAME generated colors on every
theme/wallpaper change; modules/terminal.nix includes that file so foot
tracks it. Every other app just stays whatever it already was (no
per-app template wired up) — deliberately not turning this into a new
full-system theme-switcher.

## `nvidia.nix`

*Contributes to: nixos*

Hybrid AMD + Nvidia graphics (PRIME offload; dGPU powers down when idle).

## `persistence.nix`

*Contributes to: nixos*

Impermanence: what survives the ephemeral-root wipe (see
ephemeral-root.nix). /home lives on the wiped @ subvolume too, so user
state must be listed here — anything not listed dies at reboot.

## `secrets.nix`

*Contributes to: nixos*

sops-nix: secrets encrypted in-repo (secrets/secrets.yaml), decrypted
at activation with the age key at /persist/var/lib/sops-nix/key.txt.
/persist is neededForBoot, so the key is available early enough for
neededForUsers secrets.

## `terminal.nix`

*Contributes to: homeManager nixos*

Terminal life: foot, fish, starship, fastfetch, zoxide and the modern
CLI replacements, plus baseline system CLI tools. Colors are static
Catppuccin Mocha Lavender — no runtime theme switching.

## `theming.nix`

*Contributes to: homeManager nixos*

GTK, cursors, icons, fonts, dconf/xfconf, session variables — a single
static look. Apps: plain Adwaita-dark (neutral dark grey, from
gnome-themes-extra; GTK4/libadwaita follows color-scheme = prefer-dark).
Icons: Papirus-Dark with soft sand-yellow ("paleorange") folders (recolored at build time via the
package's `color` argument). Cursor: Catppuccin Mocha dark. No runtime
switching, no multi-palette installs.

Never keep a copy of an icon theme in ~/.local/share/icons (persisted):
a stale/partial user copy shadows the Nix one and files lose their icons.

## `thunar.nix`

*Contributes to: homeManager nixos*

Thunar file manager: foot as "open terminal here", and right-click custom
actions (~/.config/Thunar/uca.xml, owned by HM): Extract Here, Compress to
.zip, Open folder in VS Code / Zed, Open Terminal Here. Archives
double-click into xarchiver. Extraction uses libarchive's bsdtar (zip, tar.*,
7z, rar) with 7z as fallback; an archive with a single top-level folder is
unpacked without an extra wrapping directory.

## `users.nix`

*Contributes to: nixos*

The domdegi user account. Password hash comes from sops-nix (secrets.nix).

## `vscode.nix`

*Contributes to: homeManager*

VS Code. settings.json lives in the repo but stays writable (out-of-store
symlink): GUI edits land in the git working tree as reviewable diffs.

## `wallpaper.nix`

*Contributes to: homeManager*

Wallpapers: drop images into ~/Pictures/Wallpapers (Pictures is already
persisted). The domdegi/wallpaper-picker Noctalia widget lists them and
applies one via Noctalia's native wallpaper engine. The `wallpaper-pick`
helper does the shell work (list/set by index) so the Luau side never
handles file paths.

## `zed.nix`

*Contributes to: homeManager*

Zed editor. settings.json lives in the repo, writable via out-of-store
symlink (before this, ~/.config/zed wasn't persisted and died on reboot).

