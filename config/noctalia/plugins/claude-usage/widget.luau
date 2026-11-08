-- Claude plan usage (script lives in modules/claude-usage.nix).
-- Bar shows the 5-hour session %; tooltip adds the weekly % and both reset
-- countdowns. Warn color at 70%, error color at 90% (whichever window is
-- higher), plus a one-shot notification when the session crosses 90%.
-- Click to refresh now.

local STATUS_CMD = "claude-usage"

-- The endpoint is undocumented and rate-limits; 5 minutes is plenty.
noctalia.setUpdateInterval(300000)

local notified = false

local function setColor(role)
  barWidget.setColor(role)
  barWidget.setGlyphColor(role)
end

local function apply(stdout)
  local fields = {}
  for f in string.gmatch(stdout or "", "[^\t\n]+") do
    table.insert(fields, f)
  end

  if fields[1] ~= "ok" then
    local reason = fields[2] or "error"
    barWidget.setGlyph("gauge-off")
    barWidget.setText("")
    setColor("")
    if reason == "expired" then
      barWidget.setTooltip("Claude: login token expired.\nRun `claude` once to refresh it.")
    elseif reason == "no-login" then
      barWidget.setTooltip("Claude: not logged in.\nRun `claude` and log in.")
    else
      barWidget.setTooltip("Claude: usage unavailable (offline?).\nClick to retry.")
    end
    return
  end

  local five, seven = tonumber(fields[2]) or 0, tonumber(fields[3]) or 0
  local peak = math.max(five, seven)

  barWidget.setGlyph("gauge")
  barWidget.setText(five .. "%")
  if peak >= 90 then
    setColor("error")
  elseif peak >= 70 then
    setColor("tertiary")
  else
    setColor("")
  end
  barWidget.setTooltip(
    "Claude usage\n"
      .. "Session (5h): " .. five .. "% — resets in " .. fields[4] .. "\n"
      .. "Weekly: " .. seven .. "% — resets in " .. fields[5] .. "\n"
      .. "Click to refresh."
  )

  if five >= 90 and not notified then
    noctalia.notify("Claude usage", "Session at " .. five .. "% — resets in " .. fields[4])
    notified = true
  elseif five < 90 then
    notified = false
  end
end

local function refresh()
  noctalia.runAsync(STATUS_CMD, function(result)
    apply(result.stdout)
  end)
end

function update()
  refresh()
end

function onClick()
  refresh()
end
