# Firefox: enabled system-wide; profile state lives in the persisted
# ~/.config/mozilla (declarative HM profiles would fight it for little gain).
# Every palette's AMO theme addon (apps.firefox in theme/_palettes.nix) is
# force-installed via enterprise policies, so theme-switch only has to point
# extensions.activeThemeID at one of them (user.js, read on next launch).
{
  flake.modules.nixos.firefox =
    let
      palettes = import ./theme/_palettes.nix;
    in
    {
      programs.firefox = {
        enable = true;
        policies.ExtensionSettings = builtins.listToAttrs (map (t: {
          name = t.apps.firefox.id;
          value = {
            installation_mode = "force_installed";
            install_url =
              "https://addons.mozilla.org/firefox/downloads/latest/${t.apps.firefox.slug}/latest.xpi";
          };
        }) (builtins.attrValues palettes.themes));
      };
    };
}
