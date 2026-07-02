-- AirPods Pro profile switcher (script lives in modules/home.nix).
-- Music = A2DP (best quality, no microphone).
-- Call  = HFP  (microphone works, lower quality) — for Webex/Meet calls.
-- It also makes the AirPods the default sink/source and fixes the volumes.

local STATUS_CMD = "airpods-audio status"
local TOGGLE_CMD = "airpods-audio toggle"

noctalia.setUpdateInterval(3000)

local function apply(state)
  if state == "music" then
    barWidget.setGlyph("device-airpods")
    barWidget.setText("")
    barWidget.setTooltip("AirPods: Music profile (A2DP, best quality, no mic).\nClick to switch to Call profile for meetings.")
  elseif state == "call" then
    barWidget.setGlyph("microphone")
    barWidget.setText("CALL")
    barWidget.setTooltip("AirPods: Call profile (HFP, mic active).\nClick to switch back to Music profile.")
  elseif state == "other" then
    barWidget.setGlyph("headset")
    barWidget.setText("")
    barWidget.setTooltip("AirPods: profile is off/unknown.\nClick to switch to Call profile.")
  else
    barWidget.setGlyph("headphones-off")
    barWidget.setText("")
    barWidget.setTooltip("AirPods not connected.")
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
        msg = "AirPods not connected"
      end
      noctalia.notifyError("AirPods Audio", msg)
    end
    refresh()
  end)
end
