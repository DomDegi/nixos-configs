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
- Never push the local `old-history` / `backup/pre-dendritic` branches: they
  contain the pre-public history (inline password hash).
- The age key never enters the repo; `.claude/` and `result*` are gitignored.
