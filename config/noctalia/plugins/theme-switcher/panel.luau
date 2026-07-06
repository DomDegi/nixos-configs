-- Theme menu panel: lists the palettes `theme-switch list` reports and
-- applies one on click. On success it transitions IN PLACE to a thumbnail
-- roster of the newly active theme's wallpapers (~/Pictures/Wallpapers/<slug>),
-- so picking a theme flows straight into picking a wallpaper for it — no
-- second widget, no separate panel to juggle.
--
-- Button callbacks dispatch by global-function NAME (host convention), so
-- fixed pools map button index -> theme (onPickN) / wallpaper (onWpN).

local view = "themes" -- "themes" | "wallpapers"

local themes = {} -- { { slug, name, current } }
local switching = false

local WALLPAPER_DIR = os.getenv("HOME") .. "/Pictures/Wallpapers"
local COLS = 2
local THUMB_W = 152
local THUMB_H = 96
local wallpapers = {} -- basenames, sorted (same order as wallpaper-pick)
local wpSlug = ""
local wpCurrent = "" -- basename of the wallpaper in use
local applying = false

local render

local function refreshThemes()
  noctalia.runAsync("theme-switch list", function(result)
    themes = {}
    for line in string.gmatch(result.stdout or "", "[^\n]+") do
      local slug, name, cur = string.match(line, "^([^\t]+)\t([^\t]+)\t([01])$")
      if slug then
        table.insert(themes, { slug = slug, name = name, current = cur == "1" })
      end
    end
    render()
  end)
end

local function refreshWallpapers()
  noctalia.runAsync("wallpaper-pick status", function(st)
    local s, _, cur = string.match(st.stdout or "", "^([^\t]+)\t(%d+)\t([^\n]*)")
    wpSlug = s or ""
    wpCurrent = cur or ""
    noctalia.runAsync("wallpaper-pick list", function(result)
      wallpapers = {}
      for line in string.gmatch(result.stdout or "", "[^\n]+") do
        table.insert(wallpapers, line)
      end
      render()
    end)
  end)
end

local function themeRows()
  local rows = {}
  for i, t in ipairs(themes) do
    table.insert(rows, ui.button({
      key = t.slug,
      text = if t.current then "● " .. t.name else t.name,
      variant = if t.current then "primary" else "outline",
      enabled = not switching,
      onClick = `onPick{i - 1}`,
    }))
  end
  if #rows == 0 then
    rows = { ui.label({ text = "Loading themes…", color = "on_surface_variant" }) }
  end
  return rows
end

local function wpThumb(i, w)
  local isCurrent = w == wpCurrent
  return ui.column({ key = w, gap = 4 }, {
    ui.image({
      path = `{WALLPAPER_DIR}/{wpSlug}/{w}`,
      width = THUMB_W,
      height = THUMB_H,
      fit = "cover",
      radius = 8,
      border = if isCurrent then "primary" else "outline",
      borderWidth = if isCurrent then 3 else 1,
      onClick = if applying then nil else `onWp{i - 1}`,
    }),
    ui.label({
      text = if isCurrent then "● " .. w else w,
      fontSize = 10,
      color = if isCurrent then "primary" else "on_surface_variant",
      maxLines = 1,
      maxWidth = THUMB_W,
    }),
  })
end

local function wallpaperGrid()
  local grid = {}
  for i = 1, #wallpapers, COLS do
    local cells = {}
    for j = i, math.min(i + COLS - 1, #wallpapers) do
      table.insert(cells, wpThumb(j, wallpapers[j]))
    end
    table.insert(grid, ui.row({ key = `wprow{i}`, gap = 8 }, cells))
  end
  if #grid == 0 then
    grid = { ui.label({
      text = if wpSlug == "" then "Loading…"
             else `No wallpapers yet.\nDrop images in\n~/Pictures/Wallpapers/{wpSlug}/`,
      color = "on_surface_variant",
    }) }
  end
  return grid
end

render = function()
  if view == "wallpapers" then
    panel.render(ui.column({ flexGrow = 1, gap = 16 }, {
      ui.row({ align = "center", justify = "space_between", gap = 8 }, {
        ui.button({ text = "← Back", onClick = "onBackClicked" }),
        ui.label({ text = if wpSlug == "" then "Wallpaper" else `Wallpaper · {wpSlug}`,
                   fontSize = 16, fontWeight = "bold", color = "on_surface", flexGrow = 1 }),
        ui.button({ glyph = "close", onClick = "onCloseClicked" }),
      }),
      ui.scroll({ flexGrow = 1, gap = 8, align = "stretch" }, wallpaperGrid()),
    }))
    return
  end

  panel.render(ui.column({ flexGrow = 1, gap = 16 }, {
    ui.row({ align = "center", justify = "space_between", gap = 8 }, {
      ui.label({ text = "Theme", fontSize = 16, fontWeight = "bold", color = "on_surface", flexGrow = 1 }),
      ui.button({ glyph = "close", onClick = "onCloseClicked" }),
    }),
    ui.scroll({ flexGrow = 1, gap = 8, align = "stretch" }, themeRows()),
    ui.label({
      text = "Foot/fish/nvim pick this up in new windows.",
      fontSize = 11,
      color = "on_surface_variant",
    }),
  }))
end

local function goToWallpapers()
  view = "wallpapers"
  wallpapers = {}
  wpCurrent = ""
  render()
  refreshWallpapers()
end

local function onPickAt(index)
  local t = themes[index + 1]
  if not t or t.current or switching then
    return
  end
  switching = true
  render()
  noctalia.runAsync(`theme-switch {t.slug}`, function(result)
    switching = false
    if result.exitCode == 0 then
      noctalia.notify("Theme", t.name)
      for _, tt in ipairs(themes) do
        tt.current = tt.slug == t.slug
      end
      goToWallpapers()
    else
      noctalia.notifyError("Theme switch failed", result.stderr or "unknown error")
      refreshThemes()
    end
  end)
end

local function onWpAt(index)
  local w = wallpapers[index + 1]
  if not w or w == wpCurrent or applying then
    return
  end
  applying = true
  render()
  noctalia.runAsync(`wallpaper-pick set {index + 1}`, function(result)
    applying = false
    if result.exitCode == 0 then
      wpCurrent = w
      render()
    else
      noctalia.notifyError("Wallpaper failed", result.stderr or "unknown error")
      refreshWallpapers()
    end
  end)
end

function onOpen(_context)
  view = "themes"
  render()
  refreshThemes()
end

function onCloseClicked()
  panel.close()
end

function onBackClicked()
  view = "themes"
  render()
end

function onPick0() onPickAt(0) end
function onPick1() onPickAt(1) end
function onPick2() onPickAt(2) end
function onPick3() onPickAt(3) end
function onPick4() onPickAt(4) end
function onPick5() onPickAt(5) end
function onPick6() onPickAt(6) end
function onPick7() onPickAt(7) end
function onPick8() onPickAt(8) end
function onPick9() onPickAt(9) end
function onPick10() onPickAt(10) end
function onPick11() onPickAt(11) end
function onPick12() onPickAt(12) end
function onPick13() onPickAt(13) end
function onPick14() onPickAt(14) end
function onPick15() onPickAt(15) end

function onWp0() onWpAt(0) end
function onWp1() onWpAt(1) end
function onWp2() onWpAt(2) end
function onWp3() onWpAt(3) end
function onWp4() onWpAt(4) end
function onWp5() onWpAt(5) end
function onWp6() onWpAt(6) end
function onWp7() onWpAt(7) end
function onWp8() onWpAt(8) end
function onWp9() onWpAt(9) end
function onWp10() onWpAt(10) end
function onWp11() onWpAt(11) end
function onWp12() onWpAt(12) end
function onWp13() onWpAt(13) end
function onWp14() onWpAt(14) end
function onWp15() onWpAt(15) end
function onWp16() onWpAt(16) end
function onWp17() onWpAt(17) end
function onWp18() onWpAt(18) end
function onWp19() onWpAt(19) end
