return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    cmd = {
      "ObsidianOpen",
      "ObsidianNew",
      "ObsidianQuickSwitch",
      "ObsidianSearch",
      "ObsidianToday",
      "ObsidianDailies",
      "ObsidianWorkspace",
      "ObsidianBacklinks",
      "ObsidianTemplate",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        { name = "notes", path = "~/shared/Vault/" },
        { name = "study_material", path = "~/shared/WeBeepSync/" },
      },
      -- No explicit completion.nvim_cmp/blink flag: obsidian.nvim
      -- auto-detects whichever completion engine LazyVim has active.
      completion = { min_chars = 2 },
      ui = { enable = false },
    },
  },
  -- Icon/checkbox styling for LazyVim's markdown extra (render-markdown.nvim)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      heading = {
        sign = false,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
      },
    },
  },
}
