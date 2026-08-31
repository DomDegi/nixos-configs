-- LSP servers are installed by Nix (modules/nvim.nix), not mason — they're
-- already on PATH, so mason has nothing to do and never needs the network.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = {},
        pyright = {},
        clangd = {},
        marksman = {},
        r_language_server = {},
      },
    },
  },
  { "williamboman/mason.nvim", opts = { ensure_installed = {} } },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = { ensure_installed = {}, automatic_installation = false },
  },
}
