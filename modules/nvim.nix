# Neovim: LazyVim starter (config/nvim/) + language servers, installed by
# Nix so LazyVim's LSP config never needs mason to hit the network.
{
  flake.modules.homeManager.nvim = { config, pkgs, ... }: {
    programs.neovim = {
      enable = true;
      withRuby = false;
      withPython3 = false;
      # withRuby/withPython3 = false makes HM auto-generate a provider-disable
      # snippet and write it to nvim/init.lua — the exact path our
      # whole-directory symlink below owns. sideloadInitLua passes that
      # snippet via the wrapper's `--cmd` instead, freeing the path.
      sideloadInitLua = true;
    };

    # Out-of-store symlink: the whole ~/.config/nvim is the repo's
    # config/nvim/ directory, so LazyVim edits (incl. lazy-lock.json) land
    # in the working tree without a rebuild.
    xdg.configFile."nvim".source =
      config.lib.file.mkOutOfStoreSymlink "/persist/nixos-configs/config/nvim";

    home.packages = with pkgs; [
      # Language Servers (wired up in config/nvim/lua/plugins/lsp.lua,
      # mason disabled — these come straight from Nix)
      nil
      lua-language-server
      pyright
      clang-tools
      rPackages.languageserver
      marksman # The standard Markdown LSP for autocompletion and links
    ];
  };
}
