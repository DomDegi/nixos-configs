# Zed editor. settings.json lives in the repo, writable via out-of-store
# symlink (before this, ~/.config/zed wasn't persisted and died on reboot).
{
  flake.modules.homeManager.zed = { config, pkgs, ... }: {
    home.packages = [ pkgs.zed-editor ];

    xdg.configFile."zed/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "/persist/nixos-configs/config/zed/settings.json";
  };
}
