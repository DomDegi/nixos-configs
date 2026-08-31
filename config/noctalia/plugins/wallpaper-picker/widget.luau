-- Bar button for the wallpaper menu. The shell work is done by the
-- `wallpaper-pick` script (modules/wallpaper.nix); this widget only shows
-- how many wallpapers are available and opens the panel menu.

local PANEL_ID = "domdegi/wallpaper-picker:panel"

noctalia.setUpdateInterval(30000)

local function refresh()
  noctalia.runAsync("wallpaper-pick status", function(result)
    local count = string.match(result.stdout or "", "^(%d+)")
    if count then
      if count == "0" then
        barWidget.setTooltip("No wallpapers yet.\nDrop images in ~/Pictures/Wallpapers/")
      else
        barWidget.setTooltip(`Wallpapers: {count}\nClick to pick one.`)
      end
    else
      barWidget.setTooltip("Click to pick a wallpaper.")
    end
  end)
end

barWidget.setGlyph("photo")
barWidget.setText("")

function update()
  refresh()
end

function onClick()
  noctalia.togglePanel(PANEL_ID)
end
