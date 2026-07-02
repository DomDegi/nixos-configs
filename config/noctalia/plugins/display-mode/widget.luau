-- External monitor extend <-> mirror toggle.
-- Mirroring runs wl-mirror fullscreen on the external output, since niri
-- has no native output mirroring (see display-mode script in modules/home.nix).

local STATUS_CMD = "display-mode status"
local TOGGLE_CMD = "display-mode toggle"

noctalia.setUpdateInterval(3000)

local function apply(mode)
  if mode == "mirror" then
    barWidget.setGlyph("screen-share")
    barWidget.setText("")
    barWidget.setTooltip("Mirroring the laptop screen onto the external monitor.\nClick to go back to extend mode.")
  elseif mode == "extend" then
    barWidget.setGlyph("device-desktop")
    barWidget.setText("")
    barWidget.setTooltip("Extend mode — external monitor is a separate desktop.\nClick to mirror the laptop screen (presentations).")
  else
    barWidget.setGlyph("device-laptop")
    barWidget.setText("")
    barWidget.setTooltip("No external monitor connected.")
  end
end

local function refresh()
  noctalia.runAsync(STATUS_CMD, function(result)
    apply(string.match(result.stdout or "", "%a+"))
  end)
end

function update()
  refresh()
end

function onClick()
  noctalia.runAsync(TOGGLE_CMD, function(result)
    if result.exitCode ~= 0 then
      local msg = result.stderr
      if msg == nil or msg == "" then
        msg = "No external monitor connected"
      end
      noctalia.notifyError("Display Mode", msg)
    end
    refresh()
  end)
end
