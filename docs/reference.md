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

## `terminal.nix`

*Contributes to: homeManager nixos*

Terminal life: foot, fish, starship, fastfetch, zoxide and the modern
CLI replacements, plus baseline system CLI tools.

## `theming.nix`

*Contributes to: homeManager nixos*

Catppuccin Mocha (lavender) everywhere: GTK, cursors, icons, fonts,
dconf/xfconf, session variables. System + user halves of the same feature.

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

## `zed.nix`

*Contributes to: homeManager*

Zed editor. settings.json lives in the repo, writable via out-of-store
symlink (before this, ~/.config/zed wasn't persisted and died on reboot).

