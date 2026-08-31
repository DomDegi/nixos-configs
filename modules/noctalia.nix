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
#
# Theme source is "wallpaper": Noctalia's own Material-You-style extractor
# (m3-content scheme) generates the palette from the active wallpaper, no
# static/hardcoded palette anywhere. This also drives Noctalia's *builtin
# template* pipeline (src/theme/builtin_templates.cpp upstream) — enabling
# the "foot" template makes Noctalia write
# ~/.config/foot/themes/noctalia from the SAME generated colors on every
# theme/wallpaper change; modules/terminal.nix includes that file so foot
# tracks it. Every other app just stays whatever it already was (no
# per-app template wired up) — deliberately not turning this into a new
# full-system theme-switcher.
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
          source = "wallpaper";
          wallpaper_scheme = "m3-content";
          templates = {
            enable_builtin_templates = true;
            builtin_ids = [ "foot" ];
          };
        };
        # Local plugins (linked into ~/.local/share/noctalia/plugins by
        # their feature files) must also be enabled by id.
        plugins.enabled = [
          "domdegi/battery-conserve"
          "domdegi/display-mode"
          "domdegi/airpods-audio"
          "domdegi/wallpaper-picker"
        ];
      };
    };
  };
}
