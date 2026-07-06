-- Bar button for the wallpaper menu. The shell work is done by the
-- `wallpaper-pick` script (modules/wallpaper.nix); this widget only shows
-- how many wallpapers the active theme has and opens the panel menu.

local PANEL_ID = "domdegi/wallpaper-picker:panel"

noctalia.setUpdateInterval(30000)

local function refresh()
  noctalia.runAsync("wallpaper-pick status", function(result)
    local slug, count = string.match(result.stdout or "", "^([^\t]+)\t(%d+)")
    if slug then
      if count == "0" then
        barWidget.setTooltip(`No wallpapers for {slug} yet.\nDrop images in ~/Pictures/Wallpapers/{slug}/`)
      else
        barWidget.setTooltip(`Wallpapers for {slug}: {count}\nClick to pick one.`)
      end
    else
      barWidget.setTooltip("Click to pick a wallpaper.")
    end
  end)
end

barWidget.setGlyph("image")
barWidget.setText("")

function update()
  refresh()
end

function onClick()
  noctalia.togglePanel(PANEL_ID)
end
