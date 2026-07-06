warning: Git tree '/persist/nixos-configs' is dirty
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
sysfs permission rule, toggle script + sudo rule, and the Noctalia
bar widget. The whole feature in one file.

## `bluetooth-airpods.nix`

*Contributes to: homeManager nixos*

Bluetooth tuned for AirPods Pro, plus the airpods-audio profile
switcher script and its Noctalia bar widget.
Music = A2DP (quality, no mic), Call = HFP (mic works).

## `boot.nix`

*Contributes to: nixos*

Bootloader (GRUB dual-boot with Windows), kernel, and the NTFS data
partitions shared with the Windows install.

## `desktop-apps.nix`

*Contributes to: homeManager*

GUI applications and their default-application (MIME) wiring.

## `dev.nix`

*Contributes to: homeManager nixos*

Development tooling: docker, git, direnv, compilers, search tools.

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

Document tooling: converting, compiling and processing course material.

## `ephemeral-root.nix`

*Contributes to: nixos*

BTRFS ephemeral root: the @ subvolume is rolled back to a pristine
state in the initrd on every boot. Anything worth keeping must be
listed in persistence.nix.

## `firefox.nix`

*Contributes to: nixos*

Firefox: enabled system-wide; profile state lives in the persisted
~/.config/mozilla (declarative HM profiles would fight it for little gain).
Every palette's AMO theme addon (apps.firefox in theme/_palettes.nix) is
force-installed via enterprise policies, so theme-switch only has to point
extensions.activeThemeID at one of them (user.js, read on next launch).

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

Time zone, locales, console keymap and TTY theming.

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

## `nvidia.nix`

*Contributes to: nixos*

Hybrid AMD + Nvidia graphics (PRIME offload; dGPU powers down when idle).

## `nvim.nix`

*Contributes to: homeManager*

Neovim + language servers + treesitter. init.lua stays a raw lua file.

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

## `spicetify.nix`

*Contributes to: homeManager*

Spicetify: Spotify skinned with the active palette, following theme-switch.

NixOS twist: spicetify patches files inside Spotify's install dir, which is
a read-only store path here. So activation keeps a WRITABLE COPY of
${pkgs.spotify}/share/spotify under ~/.local/share/spicetify-spotify
(refreshed whenever the store path changes, i.e. on Spotify updates) plus a
launcher built by rewriting the original wrapper to exec the copy. A hiPrio
`spotify` shim and a desktop entry make the patched copy what actually runs.

Theming: one local spicetify theme ("domdegi") whose color.ini has ONE
SCHEME PER PALETTE, generated from theme/_palettes.nix — no third-party
theme repos. `theme-switch` runs `spicetify config color_scheme <slug> &&
spicetify refresh`; Spotify shows it on next launch.
State persisted: ~/.config/spicetify + ~/.local/share/spicetify-spotify
(see persistence.nix).

Gotcha: "backup apply" is one-time per copy (unpacks Apps/*.spa in place;
a second run fails with nothing pristine left to back up from), so the
.nix-src marker is only written when it actually SUCCEEDS — writing it
unconditionally would permanently skip retrying a failed, never-patched
copy. Also strips custom_apps/extensions before applying: a
freshly-created config-xpui.ini ships with custom_apps=marketplace by
default, and without that custom app actually installed, that fails the
whole apply.

## `terminal.nix`

*Contributes to: homeManager nixos*

Terminal life: foot, fish, starship, fastfetch, zoxide and the modern
CLI replacements, plus baseline system CLI tools.

## `theme/_palettes.nix`

*Contributes to: flake-parts*

Theme palettes — the single source of truth for every color in this config.
Underscore prefix: NOT auto-imported; consumers do
  palettes = import ./theme/_palettes.nix;   (adjust the relative path)

Adding a theme = adding one attrset here. Everything else (foot/starship/
fastfetch configs, the Noctalia colorscheme, the theme-switch script and its
bar menu) is generated from it by modules/theme/switcher.nix.

Field contract (all colors "#rrggbb"):
  name       display name; also the Noctalia colorscheme folder name
  dark       true for dark themes (drives Noctalia darkMode pairing)
  ui         role colors: bg bgDim surface outline fg fgDim
             accent secondary tertiary error
  ansi       the 16 terminal colors (black..white, bright*)
  apps.nvim      lazy.nvim plugin repo + :colorscheme name
  apps.vscode    workbench.colorTheme + marketplace extension id
  apps.zed       theme name + zed extension id ("" = built-in)
  apps.gtk       GTK theme dir name + nixpkgs package attr ("" = none)
  apps.firefox   AMO static theme: id (the addon GUID, becomes
                 extensions.activeThemeID) + slug (addons.mozilla.org URL
                 slug, used by the policy install_url)
  apps.papirus   papirus-folders color for the folder icons (valid names:
                 papirus-folders -l; e.g. violet blue orange nordic green)

Spotify (spicetify) needs no per-theme field: modules/spicetify.nix
generates one color scheme per palette straight from ui/ansi.

## `theme/switcher.nix`

*Contributes to: homeManager*

Runtime theme switching across the whole rice, generated from
_palettes.nix (the single source of truth for colors).

For every palette this builds: foot colors, a starship config, a fastfetch
config (prompt-matched ╭─ frame layout), a GTK settings.ini and a Noctalia
colorscheme. The `theme-switch` script repoints symlinks under
~/.local/state/theme (persisted), updates VS Code/Zed/niri/GTK/Noctalia in
place, activates the palette's Firefox theme addon (user.js + extensions.json),
flips the spicetify color scheme, recolors the Papirus folder icons
(papirus-folders on the writable copy from theming.nix) and Obsidian's
accent color per vault. Driven from the Noctalia bar via
domdegi/theme-switcher; on a successful pick, its panel transitions in
place to a thumbnail roster of the new theme's wallpapers (same grid as
the standalone domdegi/wallpaper-picker, which still exists on its own
for picking a wallpaper without switching themes).

Reach per app:
  instant ......... noctalia, niri (live reload), VS Code, Zed, GTK4/libadwaita
  next launch ..... foot windows, starship/fastfetch (new shells), nvim,
                    Thunar & other GTK3 apps, Firefox, Spotify (spicetify),
                    Obsidian
  rebuild-only .... TTY console + Ly greeter (always the default palette)

## `theming.nix`

*Contributes to: homeManager nixos*

GTK, cursors, icons, fonts, dconf/xfconf, session variables — themed from
modules/theme/_palettes.nix. The DEFAULT palette is baked in here (what a
rebuild asserts); theme-switch retargets GTK at runtime, and every
palette's GTK theme package is installed so switching always has its
target ("theme-switch reapply" restores a runtime choice after a rebuild).
Also keeps a writable Papirus-Dark copy in ~/.local/share/icons so
theme-switch can recolor the folder icons per palette (apps.papirus).

## `thunar.nix`

*Contributes to: homeManager nixos*

Thunar file manager + its "open terminal here" integration with foot.

## `users.nix`

*Contributes to: nixos*

The domdegi user account. Password hash comes from sops-nix (secrets.nix).

## `vscode.nix`

*Contributes to: homeManager*

VS Code. settings.json lives in the repo but stays writable (out-of-store
symlink): GUI edits land in the git working tree as reviewable diffs.

## `wallpaper.nix`

*Contributes to: homeManager*

Per-theme wallpapers: ~/Pictures/Wallpapers/<palette-slug>/ holds each
theme's collection (dirs auto-created from _palettes.nix; Pictures is
already persisted). The domdegi/wallpaper-picker Noctalia widget lists the
ACTIVE theme's images and applies one via Noctalia's native wallpaper
engine; theme-switch pops the picker open after a switch when the new
theme's folder is non-empty. The `wallpaper-pick` helper does the shell
work (list/set by index) so the Luau side never handles file paths.

## `zed.nix`

*Contributes to: homeManager*

Zed editor. settings.json lives in the repo, writable via out-of-store
symlink (before this, ~/.config/zed wasn't persisted and died on reboot).

