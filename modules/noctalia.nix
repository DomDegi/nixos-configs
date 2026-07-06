# Noctalia Shell v5 (bar + widgets + theming master).
#
# NOTE on the two config files:
#  - ~/.config/noctalia/config.toml  <- written from `settings` below, but
#    noctalia v5 only reads it as a FIRST-RUN seed.
#  - ~/.local/state/noctalia/settings.toml <- the runtime source of truth
#    (bar layout, GUI edits). It is persisted via persistence.nix.
# So `settings` here must stay minimal: theme + the plugin enable list
# (which MUST live only in this file — freeform TOML lists don't merge
# reliably across modules).
{ inputs, ... }:

{
  flake.modules.homeManager.noctalia = {
    imports = [ inputs.noctalia.homeModules.default ];

    programs.noctalia = {
      enable = true;
      # Run as a systemd user service (Restart=on-failure) instead of
      # niri spawn-at-startup: noctalia v5 can crash on first-run state
      # initialization, and spawn-at-startup never retries.
      systemd.enable = true;
      settings = {
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
        };
        # Local plugins (linked into ~/.local/share/noctalia/plugins by
        # their feature files) must also be enabled by id.
        plugins.enabled = [
          "domdegi/battery-conserve"
          "domdegi/display-mode"
          "domdegi/airpods-audio"
          "domdegi/theme-switcher"
          "domdegi/wallpaper-picker"
        ];
      };
    };
  };
}
