# Terminal life: foot, fish, starship, fastfetch, zoxide and the modern
# CLI replacements, plus baseline system CLI tools.
{
  flake.modules.nixos.terminal = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      wget
      p7zip
      unzip
      step-cli
    ];
  };

  flake.modules.homeManager.terminal = { pkgs, ... }: {
    home.packages = with pkgs; [
      # Modern CLI Upgrades
      eza # Beautiful 'ls' replacement with icons
      bat # Beautiful 'cat' replacement with syntax highlighting
      btop # The coolest system monitor
    ];

    # Foot Terminal
    programs.foot = {
      enable = true;
      settings = {
        main = {
          term = "xterm-256color";
          font = "JetBrainsMono Nerd Font:size=11";
          pad = "10x10";
        };
        cursor = {
          style = "block";
          # (Cursor color removed here; Foot natively inverses colors for a perfect block)
        };
        colors-dark = {
          alpha = "0.85";
          background = "1e1e2e";
          foreground = "cdd6f4";

          # Catppuccin Mocha Palette
          regular0 = "45475a"; # Surface 1
          regular1 = "f38ba8"; # Red
          regular2 = "a6e3a1"; # Green
          regular3 = "f9e2af"; # Yellow
          regular4 = "89b4fa"; # Blue
          regular5 = "f5c2e7"; # Pink
          regular6 = "94e2d5"; # Teal
          regular7 = "bac2de"; # Subtext 1
          bright0 = "585b70"; # Surface 2
          bright1 = "f38ba8"; # Red
          bright2 = "a6e3a1"; # Green
          bright3 = "f9e2af"; # Yellow
          bright4 = "89b4fa"; # Blue
          bright5 = "f5c2e7"; # Pink
          bright6 = "94e2d5"; # Teal
          bright7 = "a6adc8"; # Subtext 0
        };
      };
    };

    # Starship Prompt
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        palette = "catppuccin_mocha";
        palettes.catppuccin_mocha = {
          rosewater = "#f5e0dc"; flamingo = "#f2cdcd"; pink = "#f5c2e7";
          mauve = "#cba6f7";
          red = "#f38ba8"; maroon = "#eba0ac"; peach = "#fab387"; yellow = "#f9e2af";
          green = "#a6e3a1";
          teal = "#94e2d5"; sky = "#89dceb"; sapphire = "#74c7ec";
          blue = "#89b4fa"; lavender = "#b4befe"; text = "#cdd6f4";
          subtext1 = "#bac2de";
          subtext0 = "#a6adc8"; overlay2 = "#9399b2"; overlay1 = "#7f849c"; overlay0 = "#6c7086";
          surface2 = "#585b70";
          surface1 = "#45475a"; surface0 = "#313244"; base = "#1e1e2e";
          mantle = "#181825"; crust = "#11111b";
        };
        format = "[╭─](subtext0)$os$directory$git_branch$git_status\n[╰─](subtext0)$character";
        os = { disabled = false; style = "bold lavender"; symbols.NixOS = " "; };
        directory = { style = "bold blue"; read_only = " 󰌾"; truncation_length = 3; truncation_symbol = "…/"; };
        character = { success_symbol = "[❯](bold lavender)"; error_symbol = "[❯](bold red)"; vimcmd_symbol = "[❮](bold green)"; };
        git_branch = { symbol = " "; style = "bold pink"; };
        git_status = { style = "bold red"; };
      };
    };

    # Fastfetch (ultra-clean custom UI)
    programs.fastfetch = {
      enable = true;
      settings = {
        logo = {
          source = "nixos";
          color = { "1" = "#b4befe"; "2" = "#cdd6f4"; };
          padding = { top = 2; left = 2; right = 4; };
        };
        display = {
          separator = " 󰁔 ";
        };
        modules = [
          "break"
          { type = "title"; color = { user = "magenta"; host = "blue"; }; }
          "separator"
          { type = "os"; key = " OS"; keyColor = "blue"; }
          { type = "kernel"; key = " Kernel"; keyColor = "white"; }
          { type = "uptime"; key = "󰅐 Uptime"; keyColor = "yellow"; }
          { type = "packages"; key = "󰏖 Packages"; keyColor = "cyan"; }
          { type = "shell"; key = " Shell"; keyColor = "green"; }
          { type = "wm"; key = " WM"; keyColor = "blue"; }
          { type = "terminal"; key = " Terminal"; keyColor = "magenta"; }
          { type = "cpu"; key = " CPU"; keyColor = "red"; }
          { type = "memory"; key = " Memory"; keyColor = "magenta"; }
          { type = "disk"; key = "󰋊 Disk"; keyColor = "cyan"; }
          { type = "battery"; key = "󰁹 Battery"; keyColor = "green"; }
          "break"
          "colors"
        ];
      };
    };

    # Fish Shell
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set -U fish_greeting ""
        fastfetch
      '';
      shellAliases = {
        ls = "eza --icons=always";
        ll = "eza -l --icons=always";
        la = "eza -la --icons=always";
        cat = "bat --style=plain";
        top = "btop";
      };
    };

    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    # Fuzzy finder: Ctrl+R history, Ctrl+T files, Alt+C cd
    programs.fzf = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
