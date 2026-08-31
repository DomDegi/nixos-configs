# Operations manual

Day-2 recipes for this config. Commands assume you're in
`/persist/nixos-configs` (or `~/nixos-configs`, same thing).

## Rebuild & update

```bash
nh os switch                 # build + nvd package diff + activate (preferred)
nh os test                   # activate WITHOUT adding a GRUB entry (experiment safely)
nix flake check              # eval sanity before a rebuild
nix flake update && nh os switch    # upgrade everything EXCEPT noctalia (pinned, see below)
nh clean all --keep 5        # prune old generations (keep last 5)
```

After a rebuild that changes HM-managed files, check activation output for
`hm-bak` renames — that means a real file was in the way of a managed one.

- **Updating noctalia deliberately**: `noctalia.url` in `flake.nix` is
  pinned to a specific rev, not the default branch — it has no tagged
  releases and has broken our 5 custom bar widgets before by changing the
  plugin manifest/IPC surface. To bump it: `nix flake lock --update-input
  noctalia`, `nh os switch`, then verify each widget in
  `config/noctalia/plugins/` still shows up on the bar (a manifest missing
  the mandatory `plugin_api` key, or a plugin dropped somewhere other than
  `~/.local/share/noctalia/plugins/<name>/`, fails silently — no bar icon,
  no error).
- Prefer updating one input at a time
  (`nix flake lock --update-input nixpkgs`, etc.) over a blanket `nix flake
  update` when chasing down what broke after an upgrade — it tells you which
  input to blame.

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
  `plugin.toml` MUST include `id`, `name` and a numeric `plugin_api` (not
  `min_noctalia` — that key doesn't exist and is silently ignored; a missing
  `plugin_api` fails the whole manifest, with no error surfaced anywhere
  except the widget just never appearing). Glyph names in `icon =`/`setGlyph`
  must be real Tabler icon names — check against
  `share/noctalia/assets/fonts/tabler.json` in the noctalia package if a
  glyph doesn't render.

## Theming

One static look (Catppuccin Mocha Lavender), inlined directly into
`theming.nix`, `terminal.nix`, `locale.nix`, `greeter.nix`,
`config/niri/config.kdl`, `config/vscode/settings.json` and
`config/zed/settings.json` — no runtime switcher, no `theme/_palettes.nix`
indirection. To change the look, edit those files' hardcoded values directly
and rebuild; there's no single source of truth to update anymore, since
there's only one theme.

- **Spotify is intentionally plain (unthemed)**: `modules/spicetify.nix` was
  removed after spicetify's patched `xpui` assets left Spotify stuck on the
  loading spinner / rendering a blank grey window (audio + MPRIS still worked
  since that's a separate backend from the patched UI). Confirmed by running
  the plain `pkgs.spotify` binary directly, which rendered fine — the
  patching, not the Spotify version or a nixpkgs bump, was the cause. If
  re-adding spicetify in the future, verify the patched UI actually paints
  content (not just that the process launches) before trusting it.

## Wallpapers

Drop images (png/jpg/jpeg/webp) into `~/Pictures/Wallpapers/` (flat, auto-created).
Click the image icon in the bar to open the picker panel, or use the CLI:
`wallpaper-pick list`, `wallpaper-pick set <N>`. Applied through Noctalia's
own wallpaper engine and persists across reboots.

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
