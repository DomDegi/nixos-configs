# VS Code. settings.json lives in the repo but stays writable (out-of-store
# symlink): GUI edits land in the git working tree as reviewable diffs.
{
  flake.modules.homeManager.vscode = { config, pkgs, ... }: {
    home.packages = [ pkgs.vscode ];

    # Absolute string path on purpose — a ./path would be frozen into the store.
    xdg.configFile."Code/User/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "/persist/nixos-configs/config/vscode/settings.json";
  };
}
