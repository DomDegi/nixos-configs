# Theme palettes — the single source of truth for every color in this config.
# Underscore prefix: NOT auto-imported; consumers do
#   palettes = import ./theme/_palettes.nix;   (adjust the relative path)
#
# Adding a theme = adding one attrset here. Everything else (foot/starship/
# fastfetch configs, the Noctalia colorscheme, the theme-switch script and its
# bar menu) is generated from it by modules/theme/switcher.nix.
#
# Field contract (all colors "#rrggbb"):
#   name       display name; also the Noctalia colorscheme folder name
#   dark       true for dark themes (drives Noctalia darkMode pairing)
#   ui         role colors: bg bgDim surface outline fg fgDim
#              accent secondary tertiary error
#   ansi       the 16 terminal colors (black..white, bright*)
#   apps.nvim      lazy.nvim plugin repo + :colorscheme name
#   apps.vscode    workbench.colorTheme + marketplace extension id
#   apps.zed       theme name + zed extension id ("" = built-in)
#   apps.gtk       GTK theme dir name + nixpkgs package attr ("" = none)
#   apps.firefox   AMO static theme: id (the addon GUID, becomes
#                  extensions.activeThemeID) + slug (addons.mozilla.org URL
#                  slug, used by the policy install_url)
#   apps.papirus   papirus-folders color for the folder icons (valid names:
#                  papirus-folders -l; e.g. violet blue orange nordic green)
#
# Spotify (spicetify) needs no per-theme field: modules/spicetify.nix
# generates one color scheme per palette straight from ui/ansi.
rec {
  default = "catppuccin-lavender";

  themes = {
    catppuccin-lavender = {
      name = "Catppuccin Lavender";
      dark = true;
      ui = {
        bg = "#1e1e2e"; bgDim = "#11111b"; surface = "#313244";
        outline = "#585b70"; fg = "#cdd6f4"; fgDim = "#a6adc8";
        accent = "#b4befe"; secondary = "#f5c2e7"; tertiary = "#cba6f7";
        error = "#f38ba8";
      };
      ansi = {
        black = "#45475a"; red = "#f38ba8"; green = "#a6e3a1";
        yellow = "#f9e2af"; blue = "#89b4fa"; magenta = "#f5c2e7";
        cyan = "#94e2d5"; white = "#bac2de";
        brightBlack = "#585b70"; brightRed = "#f38ba8"; brightGreen = "#a6e3a1";
        brightYellow = "#f9e2af"; brightBlue = "#89b4fa"; brightMagenta = "#f5c2e7";
        brightCyan = "#94e2d5"; brightWhite = "#a6adc8";
      };
      apps = {
        nvim = { plugin = "catppuccin/nvim"; colorscheme = "catppuccin-mocha"; };
        vscode = { theme = "Catppuccin Mocha"; extension = "Catppuccin.catppuccin-vsc"; };
        zed = { theme = "Catppuccin Mocha"; extension = "catppuccin"; };
        gtk = { theme = "catppuccin-mocha-lavender-standard"; package = "catppuccin-gtk"; };
        firefox = { id = "{8446b178-c865-4f5c-8ccc-1d7887811ae3}"; slug = "catppuccin-mocha-lavender-git"; };
        papirus = "blue";
      };
    };

    tokyo-night = {
      name = "Tokyo Night";
      dark = true;
      ui = {
        bg = "#1a1b26"; bgDim = "#16161e"; surface = "#292e42";
        outline = "#414868"; fg = "#c0caf5"; fgDim = "#a9b1d6";
        accent = "#7aa2f7"; secondary = "#bb9af7"; tertiary = "#7dcfff";
        error = "#f7768e";
      };
      ansi = {
        black = "#15161e"; red = "#f7768e"; green = "#9ece6a";
        yellow = "#e0af68"; blue = "#7aa2f7"; magenta = "#bb9af7";
        cyan = "#7dcfff"; white = "#a9b1d6";
        brightBlack = "#414868"; brightRed = "#f7768e"; brightGreen = "#9ece6a";
        brightYellow = "#e0af68"; brightBlue = "#7aa2f7"; brightMagenta = "#bb9af7";
        brightCyan = "#7dcfff"; brightWhite = "#c0caf5";
      };
      apps = {
        nvim = { plugin = "folke/tokyonight.nvim"; colorscheme = "tokyonight-night"; };
        vscode = { theme = "Tokyo Night"; extension = "enkia.tokyo-night"; };
        zed = { theme = "Tokyo Night"; extension = "tokyo-night"; };
        gtk = { theme = "Tokyonight-Dark"; package = "tokyonight-gtk-theme"; };
        firefox = { id = "{cebd391d-f568-473f-bb6e-698d08ec81ec}"; slug = "tokyo-night-dark-theme"; };
        papirus = "blue";
      };
    };

    gruvbox = {
      name = "Gruvbox Dark";
      dark = true;
      ui = {
        bg = "#282828"; bgDim = "#1d2021"; surface = "#3c3836";
        outline = "#504945"; fg = "#ebdbb2"; fgDim = "#a89984";
        accent = "#fe8019"; secondary = "#fabd2f"; tertiary = "#8ec07c";
        error = "#fb4934";
      };
      ansi = {
        black = "#282828"; red = "#cc241d"; green = "#98971a";
        yellow = "#d79921"; blue = "#458588"; magenta = "#b16286";
        cyan = "#689d6a"; white = "#a89984";
        brightBlack = "#928374"; brightRed = "#fb4934"; brightGreen = "#b8bb26";
        brightYellow = "#fabd2f"; brightBlue = "#83a598"; brightMagenta = "#d3869b";
        brightCyan = "#8ec07c"; brightWhite = "#ebdbb2";
      };
      apps = {
        nvim = { plugin = "ellisonleao/gruvbox.nvim"; colorscheme = "gruvbox"; };
        vscode = { theme = "Gruvbox Dark Medium"; extension = "jdinhlife.gruvbox"; };
        zed = { theme = "Gruvbox Dark"; extension = "gruvbox"; };
        gtk = { theme = "Gruvbox-Dark"; package = "gruvbox-gtk-theme"; };
        firefox = { id = "{eb8c4a94-e603-49ef-8e81-73d3c4cc04ff}"; slug = "gruvbox-dark-theme"; };
        papirus = "orange";
      };
    };

    nord = {
      name = "Nord";
      dark = true;
      ui = {
        bg = "#2e3440"; bgDim = "#272c36"; surface = "#3b4252";
        outline = "#4c566a"; fg = "#d8dee9"; fgDim = "#aeb6c3";
        accent = "#88c0d0"; secondary = "#81a1c1"; tertiary = "#b48ead";
        error = "#bf616a";
      };
      ansi = {
        black = "#3b4252"; red = "#bf616a"; green = "#a3be8c";
        yellow = "#ebcb8b"; blue = "#81a1c1"; magenta = "#b48ead";
        cyan = "#88c0d0"; white = "#e5e9f0";
        brightBlack = "#4c566a"; brightRed = "#bf616a"; brightGreen = "#a3be8c";
        brightYellow = "#ebcb8b"; brightBlue = "#81a1c1"; brightMagenta = "#b48ead";
        brightCyan = "#8fbcbb"; brightWhite = "#eceff4";
      };
      apps = {
        nvim = { plugin = "shaunsingh/nord.nvim"; colorscheme = "nord"; };
        vscode = { theme = "Nord"; extension = "arcticicestudio.nord-visual-studio-code"; };
        zed = { theme = "Nord"; extension = "nord"; };
        gtk = { theme = "Nordic"; package = "nordic"; };
        firefox = { id = "{758478b6-29f3-4d69-ab17-c49fe568ed80}"; slug = "nord-polar-night-theme"; };
        papirus = "nordic";
      };
    };

    rose-pine = {
      name = "Rosé Pine";
      dark = true;
      ui = {
        bg = "#191724"; bgDim = "#1f1d2e"; surface = "#26233a";
        outline = "#403d52"; fg = "#e0def4"; fgDim = "#908caa";
        accent = "#c4a7e7"; secondary = "#ebbcba"; tertiary = "#9ccfd8";
        error = "#eb6f92";
      };
      ansi = {
        black = "#26233a"; red = "#eb6f92"; green = "#31748f";
        yellow = "#f6c177"; blue = "#9ccfd8"; magenta = "#c4a7e7";
        cyan = "#ebbcba"; white = "#e0def4";
        brightBlack = "#6e6a86"; brightRed = "#eb6f92"; brightGreen = "#31748f";
        brightYellow = "#f6c177"; brightBlue = "#9ccfd8"; brightMagenta = "#c4a7e7";
        brightCyan = "#ebbcba"; brightWhite = "#e0def4";
      };
      apps = {
        nvim = { plugin = "rose-pine/neovim"; colorscheme = "rose-pine"; };
        vscode = { theme = "Rosé Pine"; extension = "mvllow.rose-pine"; };
        zed = { theme = "Rosé Pine"; extension = "rose-pine"; };
        gtk = { theme = "rose-pine"; package = "rose-pine-gtk-theme"; };
        firefox = { id = "{84496095-b7ad-496e-bce3-51cca2e43703}"; slug = "rose-pine-dark-theme"; };
        papirus = "magenta";
      };
    };

    dracula = {
      name = "Dracula";
      dark = true;
      ui = {
        bg = "#282a36"; bgDim = "#21222c"; surface = "#44475a";
        outline = "#6272a4"; fg = "#f8f8f2"; fgDim = "#bfc7d5";
        accent = "#bd93f9"; secondary = "#ff79c6"; tertiary = "#8be9fd";
        error = "#ff5555";
      };
      ansi = {
        black = "#21222c"; red = "#ff5555"; green = "#50fa7b";
        yellow = "#f1fa8c"; blue = "#bd93f9"; magenta = "#ff79c6";
        cyan = "#8be9fd"; white = "#f8f8f2";
        brightBlack = "#6272a4"; brightRed = "#ff6e6e"; brightGreen = "#69ff94";
        brightYellow = "#ffffa5"; brightBlue = "#d6acff"; brightMagenta = "#ff92df";
        brightCyan = "#a4ffff"; brightWhite = "#ffffff";
      };
      apps = {
        nvim = { plugin = "Mofiqul/dracula.nvim"; colorscheme = "dracula"; };
        vscode = { theme = "Dracula Theme"; extension = "dracula-theme.theme-dracula"; };
        zed = { theme = "Dracula"; extension = "dracula"; };
        gtk = { theme = "Dracula"; package = "dracula-theme"; };
        firefox = { id = "{b743f56d-1cc1-4048-8ba6-f9c2ab7aa54d}"; slug = "dracula-dark-colorscheme"; };
        papirus = "violet";
      };
    };

    everforest = {
      name = "Everforest Dark";
      dark = true;
      ui = {
        bg = "#2d353b"; bgDim = "#232a2e"; surface = "#3d484d";
        outline = "#475258"; fg = "#d3c6aa"; fgDim = "#9da9a0";
        accent = "#a7c080"; secondary = "#7fbbb3"; tertiary = "#dbbc7f";
        error = "#e67e80";
      };
      ansi = {
        black = "#475258"; red = "#e67e80"; green = "#a7c080";
        yellow = "#dbbc7f"; blue = "#7fbbb3"; magenta = "#d699b6";
        cyan = "#83c092"; white = "#d3c6aa";
        brightBlack = "#859289"; brightRed = "#e67e80"; brightGreen = "#a7c080";
        brightYellow = "#dbbc7f"; brightBlue = "#7fbbb3"; brightMagenta = "#d699b6";
        brightCyan = "#83c092"; brightWhite = "#d3c6aa";
      };
      apps = {
        nvim = { plugin = "neanias/everforest-nvim"; colorscheme = "everforest"; };
        vscode = { theme = "Everforest Dark"; extension = "sainnhe.everforest"; };
        zed = { theme = "Everforest Dark"; extension = "everforest"; };
        gtk = { theme = "Everforest-Dark"; package = "everforest-gtk-theme"; };
        firefox = { id = "{0e5c8ff0-b54b-4bd1-b33e-d5e016e066f0}"; slug = "everforest-dark-medium-theme"; };
        papirus = "green";
      };
    };
  };
}
