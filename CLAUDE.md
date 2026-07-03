# nixos-configs — working rules

Single-host NixOS flake using the **dendritic pattern**: flake-parts +
import-tree; every `.nix` under `modules/` is auto-imported and is one
feature contributing `flake.modules.nixos.<name>` and/or
`flake.modules.homeManager.<name>`. Docs: `README.md` (overview),
`docs/modules.md` (per-module reference), `docs/operations.md` (recipes).

## Keep the docs in sync (hard rule)

Any commit that adds/removes/renames a module or meaningfully changes what a
module does MUST, in the same commit: update `docs/modules.md`, keep the
module's header comment accurate (it is the docstring), and regenerate
`docs/reference.md` via `nix run .#docs > docs/reference.md`. New workflows,
gotchas or recovery procedures go to `docs/operations.md`. `README.md` stays
a short overview — update its module tree only when files are added/removed.

## Repo-specific gotchas

- `modules/` is auto-imported: never leave scratch `.nix` files there
  (prefix `_` to disable). `hardware-configuration.nix` must stay at repo
  root, OUT of `modules/`.
- `plugins.enabled` (Noctalia) has a single owner: `modules/noctalia.nix`.
  Noctalia's runtime config is `~/.local/state/noctalia/settings.toml`
  (persisted); `programs.noctalia.settings` is only a first-run seed.
- `mkOutOfStoreSymlink` takes absolute string literals only
  (`"/persist/nixos-configs/..."`), never `./paths` (silent store-freeze).
- Persisting an already-existing **file** needs it moved under `/persist`
  first, or activation fails ("A file already exists").
- Refactors must be verified with
  `nix store diff-closures /run/current-system ./result` ≈ empty.
- sudo is interactive-only for the user: hand them ONE short command or a
  script file to run; never multi-line sudo blocks (fish mangles them).
- Password/secrets: sops-nix, age key at `/persist/var/lib/sops-nix/key.txt`
  (never in repo). After password changes verify `/run/secrets-for-users/`
  and `getent shadow` BEFORE any reboot.
- Never push `old-history`, `backup/pre-dendritic` or
  `archive-persistent-home` (pre-public history with inline password hash).
