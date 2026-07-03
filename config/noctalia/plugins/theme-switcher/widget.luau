-- Bar button for the theme menu. The heavy lifting is done by the
-- `theme-switch` script (modules/theme/switcher.nix); this widget only
-- shows the active theme and opens the panel menu.

local PANEL_ID = "domdegi/theme-switcher:panel"

noctalia.setUpdateInterval(10000)

local function refresh()
  noctalia.runAsync("theme-switch list", function(result)
    for line in string.gmatch(result.stdout or "", "[^\n]+") do
      local name = string.match(line, "^[^\t]+\t([^\t]+)\t1$")
      if name then
        barWidget.setTooltip("Theme: " .. name .. "\nClick to pick another.")
        return
      end
    end
    barWidget.setTooltip("Click to pick a theme.")
  end)
end

barWidget.setGlyph("palette")
barWidget.setText("")

function update()
  refresh()
end

function onClick()
  noctalia.togglePanel(PANEL_ID)
end
