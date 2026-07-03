# Operations manual

Day-2 recipes for this config. Commands assume you're in
`/persist/nixos-configs` (or `~/nixos-configs`, same thing).

## Rebuild & update

```bash
nh os switch                 # build + nvd package diff + activate (preferred)
nh os test                   # activate WITHOUT adding a GRUB entry (experiment safely)
nix flake check              # eval sanity before a rebuild
nix flake update && nh os switch    # upgrade everything (kernel, apps, noctalia)
nh clean all --keep 5        # prune old generations (keep last 5)
```

After a rebuild that changes HM-managed files, check activation output for
`hm-bak` renames — that means a real file was in the way of a managed one.

## Add something

- **A package**: find the feature module it belongs to (see
  [modules.md](modules.md)) and add it to that module's `home.packages`
  (user CLI/GUI) or `environment.systemPackages` (needed by root/system).
- **A new feature**: create `modules/<feature>.nix` — it is imported
  automatically. Contribute both halves from the same file:

  ```nix
  {
    flake.modules.nixos.myfeature = { pkgs, ... }: { /* system half */ };
    flake.modules.homeManager.myfeature = { pkgs, ... }: { /* user half */ };
  }
  ```

- **Persist an app's state**: add the path to `modules/persistence.nix`
  (`users.domdegi.directories` or `.files`). ⚠️ For **files** that already
  exist, move them into `/persist` first (mirroring the path, e.g.
  `sudo mv /etc/foo /persist/etc/foo`), or activation fails with
  "A file already exists at ...".
- **A Noctalia widget**: new dir under `config/noctalia/plugins/<name>/`
  (`plugin.toml` + `widget.luau`), link it via `xdg.dataFile` in its feature
  module, add `domdegi/<name>` to `plugins.enabled` in `modules/noctalia.nix`
  (single owner — never set that list elsewhere), then add the widget to the
  bar via Noctalia's GUI (or `~/.local/state/noctalia/settings.toml`).

## Theme switching

```bash
theme-switch list                # available palettes (● = active)
theme-switch tokyo-night        # switch everything
theme-switch reapply            # after a rebuild, restore a non-default theme
```

Or click the palette icon in the bar → pick from the menu. What happens:
Noctalia/niri/GTK/VS Code/Zed change **immediately**; foot windows, the
fish/starship/fastfetch stack and nvim pick it up on **next launch**; the TTY
console and the Ly greeter always show the **default** palette (rebuild-only).

- **Add a theme**: one attrset in `modules/theme/_palettes.nix` (colors +
  nvim/VS Code/Zed/GTK bindings — see the header there), rebuild. It appears
  in `theme-switch list` and the bar menu automatically. If it has a GTK
  theme, its package is installed automatically too.
- **A rebuild resets GTK/niri-defaults to the default palette** (declarative
  files re-assert it). Run `theme-switch reapply` if you were on another theme.
- VS Code needs the theme's extension; theme-switch auto-installs it in the
  background on first switch (needs network). Zed auto-installs via
  `auto_install_extensions` in its settings.
- nvim theme plugins download on first nvim start after a rebuild (lazy.nvim).
- Don't delete the `// theme:accent|outline|backdrop` markers in
  `config/niri/config.kdl` — theme-switch rewrites exactly those lines.

## Secrets (sops-nix)

```bash
export SOPS_AGE_KEY_FILE=/persist/var/lib/sops-nix/key.txt
sops secrets/secrets.yaml            # edit decrypted view in $EDITOR
```

- Change the login password: `mkpasswd -m sha-512` → paste the new hash as
  `domdegi-password-hash` → rebuild → **verify before reboot**:
  `sudo cat /run/secrets-for-users/domdegi-password-hash` and
  `sudo getent shadow domdegi` must both show the new hash (not `!`).
- New secret: add key in `sops secrets/secrets.yaml`, declare it in
  `modules/secrets.nix` (`sops.secrets."name" = { ... };`), reference
  `config.sops.secrets."name".path`.
- New recipient (second machine): add its age public key to `.sops.yaml`,
  then `sops updatekeys secrets/secrets.yaml`.

## Disaster recovery

- **Bad rebuild / broken boot**: pick the previous generation in the GRUB
  menu. Generations regenerate `/etc` (incl. shadow) per their own config.
- **Locked out of login** (sops failure): boot previous generation; or GRUB
  edit → append `init=/bin/sh` to the kernel line.
- **Deleted a file that was alive this boot**: check
  `/old_roots/<timestamp>/` on the btrfs root — the wiped `@` snapshots are
  kept 30 days.
- **Full reinstall**: install NixOS minimally → clone this repo to
  `/persist/nixos-configs` (path is hardcoded by the hybrid symlinks) →
  restore the age key from Bitwarden:
  `sudo install -D -m 600 <key.txt> /persist/var/lib/sops-nix/key.txt`
  → `sudo nixos-rebuild switch --flake /persist/nixos-configs#nixos`.
- **Age key lost AND machine dead**: secrets are unrecoverable — but they're
  only the password hash; set a new one on reinstall with `mkpasswd`.

## Conventions

- Hand-edited GUI configs live in `config/` and are symlinked out-of-store —
  GUI edits show up in `git status`; commit or discard them deliberately.
- `mkOutOfStoreSymlink` paths must be **absolute string literals**
  (`"/persist/nixos-configs/..."`); a `./relative` path silently freezes the
  file into the store (check with `readlink`, must not print `/nix/store/...`).
- Never push the local `old-history` / `backup/pre-dendritic` /
  `archive-persistent-home` branches: they contain the pre-public history
  (inline password hash).
- The age key never enters the repo; `.claude/` and `result*` are gitignored.
