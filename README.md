# ❄️ NixOS · Niri · Noctalia — Dendritic Configuration

Personal NixOS flake for a Lenovo Legion 5 (hybrid AMD/Nvidia), built around the
**Niri** scrollable tiling compositor, the **Noctalia v5** shell, and a
**runtime-switchable theme system** — Catppuccin Lavender by default; Tokyo
Night, Gruvbox, Nord, Rosé Pine, Dracula and Everforest one bar-click away
(`theme-switch`) — on an **ephemeral BTRFS root** that is wiped on every boot
(Impermanence).

- **Compositor:** [Niri](https://github.com/YaLTeR/niri) · **Bar/Shell:** [Noctalia v5](https://github.com/noctalia-dev/noctalia) with custom Luau widgets
- **Login:** Ly (TTY, Catppuccin) · **Terminal:** Foot · **Prompt:** Fish + Starship
- **CLI:** `eza`, `bat`, `zoxide`, `btop`, `fd`, `ripgrep`
- **Secrets:** [sops-nix](https://github.com/Mic92/sops-nix) (encrypted in-repo, age key on disk)

---

## 🌳 Layout — the dendritic pattern

This flake uses the [dendritic pattern](https://github.com/mightyiam/dendritic):
[flake-parts](https://flake.parts) is the top-level module system and
[import-tree](https://github.com/vic/import-tree) auto-imports **every** `.nix`
file under `modules/`. There is no central imports list — dropping a file into
`modules/` is all it takes (prefix with `_` to disable one).

Each file is one *feature* and contributes to every layer that feature touches:

```nix
# modules/battery-conserve.nix — the WHOLE feature in one file
{
  flake.modules.nixos.battery-conserve       = { ... }; # group, sysfs rule, script, sudo rule
  flake.modules.homeManager.battery-conserve = { ... }; # Noctalia bar widget
}
```

`modules/hosts/nixos.nix` assembles the host from all `flake.modules.nixos.*`;
`modules/home-manager.nix` pipes all `flake.modules.homeManager.*` into the user.

```
flake.nix                    # inputs + mkFlake + import-tree (that's all)
hardware-configuration.nix   # generated; kept OUT of modules/ on purpose
.sops.yaml                   # sops recipient config (age public key)
secrets/secrets.yaml         # encrypted secrets (safe to publish)
config/                      # raw configs, symlinked out-of-store (see below)
  niri/config.kdl  nvim/init.lua  vscode/settings.json  zed/settings.json
  noctalia/plugins/{battery-conserve,display-mode,airpods-audio,theme-switcher}/
modules/                     # one feature per file — auto-imported
  hosts/nixos.nix  home-manager.nix  persistence.nix  ephemeral-root.nix
  theme/_palettes.nix  theme/switcher.nix  # all colors + theme-switch tooling
  secrets.nix  users.nix  boot.nix  nix.nix  locale.nix  network.nix
  nvidia.nix  audio.nix  bluetooth-airpods.nix  battery-conserve.nix
  display-mode.nix  niri.nix  greeter.nix  theming.nix  terminal.nix
  dev.nix  nvim.nix  documents.nix  desktop-apps.nix  thunar.nix
  firefox.nix  vscode.nix  zed.nix  noctalia.nix
```

**📚 Full documentation:** [docs/modules.md](docs/modules.md) — curated
per-module reference · [docs/operations.md](docs/operations.md) —
rebuild/update recipes, secrets, persistence, disaster recovery ·
[docs/reference.md](docs/reference.md) — **generated** from module header
comments (`nix run .#docs > docs/reference.md`). Kept in sync with any
module change (enforced by `CLAUDE.md`).

## 🔗 Hybrid configs (editable *and* tracked)

GUI-edited files (`config/niri/config.kdl`, `nvim/init.lua`, VS Code & Zed
`settings.json`) are linked with `mkOutOfStoreSymlink`: the app writes straight
into this repo's working tree, so edits apply instantly (no rebuild) and show
up in `git status` for review.

> ⚠️ **Path assumption:** those symlinks hardcode `/persist/nixos-configs`.
> Clone the repo exactly there (a `~/nixos-configs` symlink is created by
> `modules/users.nix`).

**Noctalia caveat:** the runtime source of truth is
`~/.local/state/noctalia/settings.toml` (persisted, GUI-managed). The
`programs.noctalia.settings` block in `modules/noctalia.nix` is only a
first-run seed — keep the plugin enable list there, tweak the bar via the GUI.

## 💾 Ephemeral root & persistence

The `@` BTRFS subvolume (`/` **and** `/home`) is rolled back in the initrd on
every boot (`modules/ephemeral-root.nix`); old roots are kept 30 days under
`/old_roots`. **Anything not listed in `modules/persistence.nix` is gone after
a reboot** — if an app forgets its state, add its path there.

## 🔐 Secrets

The login password hash lives encrypted in `secrets/secrets.yaml` (committed —
that is the point of sops). Decryption uses the age key at
`/persist/var/lib/sops-nix/key.txt` (mode 600, **never** in git; keep a copy in
a password manager). `neededForUsers` decrypts it before user creation, so
`users.mutableUsers = false` keeps working.

```bash
# edit secrets
SOPS_AGE_KEY_FILE=/persist/var/lib/sops-nix/key.txt sops secrets/secrets.yaml

# fresh install / disaster recovery: restore the key FIRST, then rebuild
sudo install -D -m 600 <backup-of-key.txt> /persist/var/lib/sops-nix/key.txt
```

## 🛠️ Cheatsheet

```bash
nh os switch                                          # apply (shows package diff)
nix flake check                                       # eval sanity
nix flake update && nh os switch                      # upgrade everything
sudo nixos-rebuild switch --flake .#nixos             # plain fallback
theme-switch list && theme-switch tokyo-night         # switch the whole rice
```

More recipes in [docs/operations.md](docs/operations.md).

Custom scripts wired to Noctalia bar widgets: `battery-conserve` (Lenovo 60%
charge cap), `display-mode` (extend ↔ mirror via wl-mirror, also on Mod+P),
`airpods-audio` (A2DP music ↔ HFP call profile with mic fixes),
`theme-switch` (palette menu — the whole desktop follows
`modules/theme/_palettes.nix`).
