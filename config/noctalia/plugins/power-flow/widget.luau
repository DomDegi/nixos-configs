-- Battery power flow (feature module: modules/power-flow.nix).
-- Reads sysfs directly (world-readable, no script). The laptop only meters
-- the battery, not the adapter, so what we know is the battery's net flow:
--   AC, charging        +47W  charge rate into the battery
--   AC, discharging     −12W  RED: drawing more than the charger supplies
--   battery only        −18W  real system draw, with time left
--   AC, battery idle    AC    full / at conservation cap — draw not metered
-- Watts are averaged over the last ~15 s so the number doesn't jitter.

local BAT = "/sys/class/power_supply/BAT0/"
local ADP = "/sys/class/power_supply/ADP0/online"
local SAMPLES = 5

noctalia.setUpdateInterval(3000)

local history = {}
local warned = false

local function readNum(path)
  local s = noctalia.readFile(path)
  return s and tonumber(string.match(s, "%-?%d+")) or nil
end

local function readStr(path)
  local s = noctalia.readFile(path)
  return s and string.match(s, "^%s*(.-)%s*$") or nil
end

-- Battery power in W (power_now, or current × voltage on batteries without it)
local function batteryWatts()
  local p = readNum(BAT .. "power_now")
  if p == nil then
    local i, v = readNum(BAT .. "current_now"), readNum(BAT .. "voltage_now")
    if i == nil or v == nil then
      return nil
    end
    p = i * v / 1e6
  end
  return math.abs(p) / 1e6
end

local function smoothed(w)
  table.insert(history, w)
  if #history > SAMPLES then
    table.remove(history, 1)
  end
  local sum = 0
  for _, x in ipairs(history) do
    sum = sum + x
  end
  return sum / #history
end

local function duration(hours)
  if hours == nil or hours <= 0 or hours > 99 then
    return "-"
  end
  local m = math.floor(hours * 60 + 0.5)
  if m < 60 then
    return m .. "m"
  end
  return string.format("%dh%02dm", m // 60, m % 60)
end

local function setColor(role)
  barWidget.setColor(role)
  barWidget.setGlyphColor(role)
end

local function refresh()
  local status = readStr(BAT .. "status")
  local watts = batteryWatts()
  if status == nil or watts == nil then
    barWidget.setGlyph("battery-exclamation")
    barWidget.setText("")
    setColor("")
    barWidget.setTooltip("Power flow: no battery readings")
    return
  end

  local onAC = readNum(ADP) == 1
  local w = smoothed(watts)
  local capacity = readNum(BAT .. "capacity") or 0
  local now, full = readNum(BAT .. "energy_now"), readNum(BAT .. "energy_full")
  local text = string.format("%.0fW", w)

  if status == "Charging" then
    warned = false
    setColor("")
    barWidget.setGlyph("battery-charging")
    barWidget.setText("+" .. text)
    local toFull = (now and full and w > 0.5) and (full - now) / 1e6 / w or nil
    barWidget.setTooltip({
      { "Charging", string.format("+%.1f W into the battery", w) },
      { "Battery", capacity .. "% · full in " .. duration(toFull) },
    })
  elseif status == "Discharging" and onAC then
    -- The charger is plugged in but the battery still drains.
    setColor("error")
    barWidget.setGlyph("plug-connected-x")
    barWidget.setText("−" .. text)
    local toEmpty = (now and w > 0.5) and now / 1e6 / w or nil
    barWidget.setTooltip({
      { "Over budget", string.format("using %.1f W more than the charger supplies", w) },
      { "Battery", capacity .. "% · empty in " .. duration(toEmpty) },
    })
    if not warned then
      noctalia.notify("Power flow", string.format("Charger can't keep up: battery draining at %.0f W", w))
      warned = true
    end
  elseif status == "Discharging" then
    warned = false
    setColor("")
    barWidget.setGlyph("bolt")
    barWidget.setText("−" .. text)
    local toEmpty = (now and w > 0.5) and now / 1e6 / w or nil
    barWidget.setTooltip({
      { "On battery", string.format("system draw %.1f W", w) },
      { "Battery", capacity .. "% · " .. duration(toEmpty) .. " left" },
    })
  else
    -- Full / Not charging (e.g. conservation cap): battery flow is ~0 and the
    -- adapter isn't metered, so there's nothing honest to show in watts.
    warned = false
    history = {}
    setColor("")
    barWidget.setGlyph("plug-connected")
    barWidget.setText("AC")
    barWidget.setTooltip({
      { "On AC", "battery idle (" .. string.lower(status) .. ")" },
      { "Battery", capacity .. "%" },
      { "", "System draw isn't metered while on AC" },
    })
  end
end

function update()
  refresh()
end
