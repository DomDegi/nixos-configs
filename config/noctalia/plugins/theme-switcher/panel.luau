-- Theme menu panel: lists the palettes `theme-switch list` reports and
-- applies one on click. The list comes from the script (single source of
-- truth in modules/theme/_palettes.nix) so adding a theme there is enough.
--
-- Button callbacks dispatch by global-function NAME (host convention), so
-- a fixed pool of onPickN handlers maps button index -> theme.

local themes = {} -- { { slug, name, current } }
local switching = false

local render

local function refresh()
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

render = function()
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

  panel.render(ui.column({ flexGrow = 1, gap = 16 }, {
    ui.row({ align = "center", justify = "space_between", gap = 8 }, {
      ui.label({ text = "Theme", fontSize = 16, fontWeight = "bold", color = "on_surface", flexGrow = 1 }),
      ui.button({ glyph = "close", onClick = "onCloseClicked" }),
    }),
    ui.scroll({ flexGrow = 1, gap = 8, align = "stretch" }, rows),
    ui.label({
      text = "Foot/fish/nvim pick this up in new windows.",
      fontSize = 11,
      color = "on_surface_variant",
    }),
  }))
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
      panel.close()
    else
      noctalia.notifyError("Theme switch failed", result.stderr or "unknown error")
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
