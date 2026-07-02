# Neovim + language servers + treesitter. init.lua stays a raw lua file.
{
  flake.modules.homeManager.nvim = { config, pkgs, ... }: {
    programs.neovim = {
      enable = true;
      withRuby = false;
      withPython3 = false;
    };

    # Out-of-store symlink: iterate on init.lua without a rebuild.
    xdg.configFile."nvim/init.lua".source =
      config.lib.file.mkOutOfStoreSymlink "/persist/nixos-configs/config/nvim/init.lua";

    home.packages = with pkgs; [
      # Language Servers
      nil
      lua-language-server
      pyright
      clang-tools
      rPackages.languageserver

      marksman # The standard Markdown LSP for autocompletion and links

      # Treesitter
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
        p.c p.cpp p.lua p.nix p.vim p.vimdoc p.query p.bash p.python
        p.markdown p.markdown_inline
      ]))
    ];
  };
}
