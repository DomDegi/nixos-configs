-- Claude plan usage (script lives in modules/claude-usage.nix).
-- Bar: one view at a time — click cycles session % → weekly % → API-equivalent
-- $ of the session. Tooltip: progress bars + reset countdowns for both
-- windows, per-model caps, the weekly usage split, and the $ per window and
-- per model. Warn color at 70%, error at 90% (whichever window is higher);
-- one-shot notification when the session crosses 90%.
-- Right-click refreshes now. Polls every 5 min (the endpoint rate-limits,
-- HTTP 429); only "offline" retries every 30 s (network not up yet at
-- login). On transient errors the last good reading stays up, marked stale.

local STATUS_CMD = "claude-usage"
local OK_INTERVAL = 300000
local RETRY_INTERVAL = 30000

local VIEWS = { "session", "weekly", "cost" }
local view = 1
local notified = false
local last = nil

noctalia.setUpdateInterval(OK_INTERVAL)

local function setColor(role)
  barWidget.setColor(role)
  barWidget.setGlyphColor(role)
end

-- ▰▰▰▱▱▱▱▱▱▱
local function bar(pct)
  local filled = math.floor(math.min(math.max(pct, 0), 100) / 10 + 0.5)
  return string.rep("▰", filled) .. string.rep("▱", 10 - filled)
end

local function usd(n)
  return string.format("$%.2f", tonumber(n) or 0)
end

local function tokens(n)
  n = tonumber(n) or 0
  if n >= 1e9 then
    return string.format("%.1fB", n / 1e9)
  elseif n >= 1e6 then
    return string.format("%.1fM", n / 1e6)
  elseif n >= 1e3 then
    return string.format("%.0fk", n / 1e3)
  end
  return tostring(n)
end

-- "claude-opus-5-5" -> "Opus 5.5"
local function modelName(id)
  local family, version = string.match(id, "^claude%-(%a+)%-([%d%-]+)")
  if family == nil then
    return id
  end
  version = string.gsub(string.gsub(version, "%-%d%d%d%d%d%d%d%d$", ""), "%-", ".")
  return string.upper(string.sub(family, 1, 1)) .. string.sub(family, 2) .. " " .. version
end

local function parse(stdout)
  local data = { scoped = {}, share = {}, models = {} }
  for line in string.gmatch(stdout or "", "[^\n]+") do
    local f = {}
    for field in string.gmatch(line, "[^\t]+") do
      table.insert(f, field)
    end
    local kind = f[1]
    if kind == "ok" then
      data.ok = true
    elseif kind == "err" then
      data.err = f[2] or "error"
    elseif kind == "five" then
      data.five, data.fiveReset = tonumber(f[2]) or 0, f[3] or "-"
    elseif kind == "week" then
      data.week, data.weekReset = tonumber(f[2]) or 0, f[3] or "-"
    elseif kind == "scoped" then
      table.insert(data.scoped, { label = f[2], pct = tonumber(f[3]) or 0 })
    elseif kind == "share" then
      table.insert(data.share, f[2] .. " " .. f[3] .. "%")
    elseif kind == "cost" then
      data.cost5, data.cost7 = f[2], f[3]
    elseif kind == "model" then
      table.insert(data.models, { id = f[2], cost5 = f[3], cost7 = f[4], tokens = f[5] })
    end
  end
  return data
end

local function showError(reason)
  barWidget.setGlyph("gauge-off")
  barWidget.setText("")
  setColor("")
  if reason == "expired" then
    barWidget.setTooltip("Claude: login token expired.\nRun `claude` once to refresh it.")
  elseif reason == "no-login" then
    barWidget.setTooltip("Claude: not logged in.\nRun `claude` and log in.")
  elseif reason == "ratelimited" then
    barWidget.setTooltip("Claude: usage endpoint rate-limited.\nRetrying in 5 min.")
  else
    barWidget.setTooltip("Claude: usage unavailable (offline?).\nRetrying every 30 s — right-click to retry now.")
  end
end

local function render()
  local d = last
  if d == nil then
    return
  end
  if not d.ok then
    showError(d.err)
    return
  end
  local staleNote = d.stale and ("Stale — last refresh failed (" .. d.stale .. ")") or nil

  local peak = math.max(d.five, d.week)
  if peak >= 90 then
    setColor("error")
  elseif peak >= 70 then
    setColor("tertiary")
  else
    setColor("")
  end

  local mode = VIEWS[view]
  if mode == "session" then
    barWidget.setGlyph("sparkles")
    barWidget.setText(d.five .. "%")
  elseif mode == "weekly" then
    barWidget.setGlyph("calendar-week")
    barWidget.setText(d.week .. "%")
  else
    barWidget.setGlyph("coin")
    barWidget.setText(usd(d.cost5))
  end

  local rows = {
    { "Session · 5h", bar(d.five) .. "  " .. d.five .. "%  ↻ " .. d.fiveReset },
    { "Weekly", bar(d.week) .. "  " .. d.week .. "%  ↻ " .. d.weekReset },
  }
  for _, s in ipairs(d.scoped) do
    table.insert(rows, { s.label .. " (week)", bar(s.pct) .. "  " .. s.pct .. "%" })
  end
  if #d.share > 0 then
    table.insert(rows, { "Week split", table.concat(d.share, " · ") })
  end
  if d.cost5 ~= nil then
    table.insert(rows, { "API-equivalent", usd(d.cost5) .. " session · " .. usd(d.cost7) .. " week" })
  end
  for _, m in ipairs(d.models) do
    table.insert(rows, {
      "  " .. modelName(m.id),
      usd(m.cost5) .. " · " .. usd(m.cost7) .. " · " .. tokens(m.tokens) .. " tok",
    })
  end
  if staleNote then
    table.insert(rows, { "", staleNote })
  end
  table.insert(rows, { "", "Click: switch view · Right-click: refresh" })
  barWidget.setTooltip(rows)

  if d.five >= 90 and not notified then
    noctalia.notify("Claude usage", "Session at " .. d.five .. "% — resets in " .. d.fiveReset)
    notified = true
  elseif d.five < 90 then
    notified = false
  end
end

local function refresh()
  noctalia.runAsync(STATUS_CMD, function(result)
    local data = parse(result.stdout)
    local offline = data.err == "offline"
    noctalia.setUpdateInterval(offline and RETRY_INTERVAL or OK_INTERVAL)
    if data.ok or last == nil or not last.ok or data.err == "expired" or data.err == "no-login" then
      last = data
    else
      -- transient failure: keep the last good reading on screen
      last.stale = data.err
    end
    render()
  end)
end

function update()
  refresh()
end

function onClick()
  view = view % #VIEWS + 1
  render()
end

function onRightClick()
  refresh()
end
