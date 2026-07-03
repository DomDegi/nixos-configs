-- ==========================================================================
-- 1. BASIC SETTINGS
-- ==========================================================================
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true

-- ==========================================================================
-- 2. BOOTSTRAP LAZY.NVIM
-- ==========================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==========================================================================
-- ==========================================================================
-- 1. BASIC SETTINGS
-- ==========================================================================
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true

-- ==========================================================================
-- 2. BOOTSTRAP LAZY.NVIM
-- ==========================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==========================================================================
-- 3. PLUGINS & CONFIGURATION
-- ==========================================================================
-- ==========================================================================
-- ACTIVE THEME (managed by theme-switch — see modules/theme/switcher.nix)
-- Reads the colorscheme name from ~/.local/state/theme/nvim; every theme in
-- modules/theme/_palettes.nix has its plugin installed below.
-- ==========================================================================
local function active_colorscheme()
  local f = io.open(vim.fn.expand("~/.local/state/theme/nvim"), "r")
  if f then
    local name = f:read("*l")
    f:close()
    if name and #name > 0 then return name end
  end
  return "catppuccin-mocha"
end

require("lazy").setup({

  -- Theme plugins (one per palette in _palettes.nix); only the active one
  -- is loaded, picked via the state file above.
  { "catppuccin/nvim", name = "catppuccin", lazy = true },
  { "folke/tokyonight.nvim", lazy = true },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  { "shaunsingh/nord.nvim", lazy = true },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
  { "Mofiqul/dracula.nvim", lazy = true },
  { "neanias/everforest-nvim", lazy = true },

  -- Telescope (Fuzzy Finder)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>pf', function() builtin.find_files({ hidden = true }) end, { desc = "Find Files" })
      vim.keymap.set('n', '<leader>ps', builtin.live_grep, { desc = "Search Project" })
    end
  },
  
  -- Treesitter (Syntax Highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.install").prefer_git = true
      require('nvim-treesitter').setup({
        ensure_installed = { 
            "lua", "vim", "vimdoc", "python", "c", "cpp", "nix", "bash",
            "markdown", "markdown_inline", "r", "cuda" 
        },
        highlight = { enable = true },
      })
    end
  },

  -- Neovim Development Setup
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {}
  },

  -- ==========================================
  -- Autocompletion Engine (nvim-cmp)
  -- ==========================================
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        -- Added Obsidian sources specifically
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, 
          { name = "luasnip" },
          { name = "obsidian" },
          { name = "obsidian_new" },
        }, {
          { name = "buffer" },
          { name = "path" },
        })
      })
    end
  },

  -- ==========================================
  -- LSP Support 
  -- ==========================================
  {
    "neovim/nvim-lspconfig",
    config = function()
      local servers = { "nil_ls", "lua_ls", "pyright", "clangd", "ts_ls", "marksman", "r_language_server" }
      
      -- Grab capabilities from cmp for autocompletion
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Neovim 0.12 Native LSP Configuration
      for _, server in ipairs(servers) do
        -- This tells Neovim's built-in LSP client how to configure the server
        vim.lsp.config(server, {
          capabilities = capabilities,
        })
        -- This officially enables and starts the server for matching filetypes
        vim.lsp.enable(server)
      end

      -- LSP Keybinds
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Hover Documentation" })
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Go to Definition" })
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = "Code Action" })
    end
  },

  -- ==========================================
  -- OBSIDIAN & MARKDOWN INTEGRATION
  -- ==========================================
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
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "notes",
          path = "~/shared/Vault/", 
        },
        {
          name = "study_material",
          path = "~/shared/WeBeepSync/"
        },
      },
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },
      ui = { enable = false },
    },
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ft = { 'markdown', 'norg', 'rmd', 'org' },
    opts = {
      heading = {
        sign = false,
        icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
      },
      checkbox = {
        unchecked = { icon = '󰄱 ' },
        checked = { icon = '󰱒 ' },
      },
    },
  }

})

-- Apply the active theme (lazy.nvim auto-loads the matching theme plugin).
-- pcall: a bad/missing state file must never break startup.
if not pcall(vim.cmd.colorscheme, active_colorscheme()) then
  vim.cmd.colorscheme("catppuccin-mocha")
end

-- ==========================================================================
-- 4. PERSONAL KEYBINDINGS
-- ==========================================================================
vim.keymap.set('i', 'jj', '<Esc>', { noremap = true, silent = true })

-- Obsidian Shortcuts
vim.keymap.set("n", "<leader>on", "<cmd>ObsidianNew<CR>", { desc = "New Obsidian note" })
vim.keymap.set("n", "<leader>os", "<cmd>ObsidianSearch<CR>", { desc = "Search Obsidian" })
vim.keymap.set("n", "<leader>oo", "<cmd>ObsidianOpen<CR>", { desc = "Open in Obsidian App" })
vim.keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>", { desc = "Show Backlinks" })
vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianTemplate<CR>", { desc = "Insert Template" })

-- ==========================================================================
-- 5. AUTOCOMMANDS (PDF HANDLING)
-- ==========================================================================
vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = "*.pdf",
    callback = function(opts)
        local filepath = vim.fn.expand(opts.file)
        vim.fn.jobstart({"zathura", filepath}, { detach = true })
        vim.api.nvim_buf_delete(opts.buf, { force = true })
    end,
})
