-- Wallpaper menu panel: shows THUMBNAILS of the active theme's images (via
-- `wallpaper-pick list`) and applies one on click (`wallpaper-pick set <N>`,
-- which drives Noctalia's native wallpaper engine). The panel stays open so
-- several wallpapers can be tried in a row.
--
-- ui.image (see noctalia's ui_tree_reconciler) takes an absolute/`~` path
-- directly and supports onClick itself, so each thumbnail IS the button —
-- no ui.button/text list needed. Laid out as a 2-column grid since the ui.*
-- flex containers have no wrap; onOpenClicked callbacks dispatch by global
-- function NAME (host convention), so a fixed pool of onPickN maps
-- thumbnail index -> wallpaper.

-- os.getenv isn't exposed in Noctalia's Luau sandbox (calling it throws
-- "attempt to call a nil value" and kills the whole chunk before anything
-- renders) — hardcode the path, same convention as the absolute paths
-- baked into the nix modules (mkOutOfStoreSymlink etc).
local WALLPAPER_DIR = "/home/domdegi/Pictures/Wallpapers"
local COLS = 2
local THUMB_W = 152
local THUMB_H = 96

local wallpapers = {} -- basenames, sorted (same order as wallpaper-pick)
local slug = ""
local current = "" -- basename of the wallpaper in use
local applying = false

local render

local function refresh()
  noctalia.runAsync("wallpaper-pick status", function(st)
    local s, _, cur = string.match(st.stdout or "", "^([^\t]+)\t(%d+)\t([^\n]*)")
    slug = s or ""
    current = cur or ""
    noctalia.runAsync("wallpaper-pick list", function(result)
      wallpapers = {}
      for line in string.gmatch(result.stdout or "", "[^\n]+") do
        table.insert(wallpapers, line)
      end
      render()
    end)
  end)
end

local function thumb(i, w)
  local isCurrent = w == current
  return ui.column({ key = w, gap = 4 }, {
    ui.image({
      path = `{WALLPAPER_DIR}/{slug}/{w}`,
      width = THUMB_W,
      height = THUMB_H,
      fit = "cover",
      radius = 8,
      border = if isCurrent then "primary" else "outline",
      borderWidth = if isCurrent then 3 else 1,
      onClick = if applying then nil else `onPick{i - 1}`,
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

render = function()
  local grid = {}
  for i = 1, #wallpapers, COLS do
    local cells = {}
    for j = i, math.min(i + COLS - 1, #wallpapers) do
      table.insert(cells, thumb(j, wallpapers[j]))
    end
    table.insert(grid, ui.row({ key = `row{i}`, gap = 8 }, cells))
  end
  if #grid == 0 then
    grid = { ui.label({
      text = if slug == "" then "Loading…"
             else `No wallpapers yet.\nDrop images in\n~/Pictures/Wallpapers/{slug}/`,
      color = "on_surface_variant",
    }) }
  end

  panel.render(ui.column({ flexGrow = 1, gap = 16 }, {
    ui.row({ align = "center", justify = "space_between", gap = 8 }, {
      ui.label({ text = if slug == "" then "Wallpaper" else `Wallpaper · {slug}`,
                 fontSize = 16, fontWeight = "bold", color = "on_surface", flexGrow = 1 }),
      ui.button({ glyph = "close", onClick = "onCloseClicked" }),
    }),
    ui.scroll({ flexGrow = 1, gap = 8, align = "stretch" }, grid),
    ui.label({
      text = "Per-theme folders under ~/Pictures/Wallpapers/.",
      fontSize = 11,
      color = "on_surface_variant",
    }),
  }))
end

local function onPickAt(index)
  local w = wallpapers[index + 1]
  if not w or w == current or applying then
    return
  end
  applying = true
  render()
  -- 1-based index into the same sorted list wallpaper-pick sees
  noctalia.runAsync(`wallpaper-pick set {index + 1}`, function(result)
    applying = false
    if result.exitCode == 0 then
      current = w
      render()
    else
      noctalia.notifyError("Wallpaper failed", result.stderr or "unknown error")
      refresh()
    end
  end)
end

function onOpen(_context)
  render()
  refresh()
end

function onCloseClicked()
  panel.close()
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
function onPick16() onPickAt(16) end
function onPick17() onPickAt(17) end
function onPick18() onPickAt(18) end
function onPick19() onPickAt(19) end
