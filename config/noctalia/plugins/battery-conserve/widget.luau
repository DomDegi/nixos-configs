-- Lenovo IdeaPad battery conservation mode widget.
-- Reads the sysfs flag directly (world-readable, see modules/system.nix);
-- toggling goes through the NOPASSWD sudo rule for battery-conserve.

local MODE_PATH = "/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode"
local TOGGLE_CMD = "sudo /run/current-system/sw/bin/battery-conserve toggle"

noctalia.setUpdateInterval(3000)

local function refresh()
  local contents = noctalia.readFile(MODE_PATH)
  if contents == nil then
    barWidget.setGlyph("battery-vertical-exclamation")
    barWidget.setText("")
    barWidget.setTooltip("Conservation mode not available")
    return
  end
  if string.sub(contents, 1, 1) == "1" then
    barWidget.setGlyph("battery-vertical-eco")
    barWidget.setText("60%")
    barWidget.setTooltip("Battery conservation ON — charge capped at ~60%.\nClick to charge to 100%.")
  else
    barWidget.setGlyph("battery-vertical")
    barWidget.setText("100%")
    barWidget.setTooltip("Battery conservation OFF — charges to 100%.\nClick to cap charge at ~60%.")
  end
end

function update()
  refresh()
end

function onClick()
  noctalia.runAsync(TOGGLE_CMD, function(result)
    if result.exitCode ~= 0 then
      noctalia.notifyError("Battery Conservation", "Toggle failed: " .. (result.stderr or "unknown error"))
    end
    refresh()
  end)
end
