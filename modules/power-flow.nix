# Battery power-flow widget for the Noctalia bar: charge rate on AC, real
# system draw on battery, red (+ notification) when the battery drains even
# though the charger is plugged in. The whole feature in one file.
#
# Only the battery is metered on this laptop (ADP0 exposes just `online`),
# so the widget shows the battery's net flow; with the charger in and the
# battery idle (full / conservation cap) it just shows "AC". It reads the
# world-readable sysfs files directly — no script, no permissions.
{
  flake.modules.homeManager.power-flow = {
    xdg.dataFile."noctalia/plugins/power-flow".source =
      ../config/noctalia/plugins/power-flow;
  };
}
