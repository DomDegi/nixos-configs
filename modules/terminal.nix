# Terminal life: foot, fish, starship, fastfetch, zoxide and the modern
# CLI replacements, plus baseline system CLI tools. Colors are static
# Catppuccin Mocha Lavender — no runtime theme switching.
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

    # Foot Terminal — colors come from Noctalia's own generated theme
    # (~/.config/foot/themes/noctalia, written by its builtin "foot"
    # template — enabled in modules/noctalia.nix — from whatever palette
    # Noctalia is currently using, e.g. wallpaper-extracted colors). Only
    # NEW foot windows pick up a change; alpha isn't part of that template
    # so it stays a plain override here.
    programs.foot = {
      enable = true;
      settings = {
        main = {
          term = "xterm-256color";
          font = "JetBrainsMono Nerd Font:size=10";
          pad = "10x10";
          include = "~/.config/foot/themes/noctalia";
        };
        colors-dark = {
          alpha = "0.85";
        };
        cursor = {
          style = "block";
          # (Cursor color removed here; Foot natively inverses colors for a perfect block)
        };
      };
    };

    # Starship Prompt — static Catppuccin Mocha Lavender palette.
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        palette = "catppuccin_mocha";
        palettes.catppuccin_mocha = {
          accent = "#b4befe";
          secondary = "#f5c2e7";
          muted = "#a6adc8";
          blue = "#89b4fa";
          red = "#f38ba8";
          green = "#a6e3a1";
        };
        format = "[╭─](muted)$os$directory$git_branch$git_status\n[╰─](muted)$character";
        os = { disabled = false; style = "bold accent"; symbols.NixOS = " "; };
        directory = { style = "bold blue"; read_only = " 󰌾"; truncation_length = 3; truncation_symbol = "…/"; };
        character = { success_symbol = "[❯](bold accent)"; error_symbol = "[❯](bold red)"; vimcmd_symbol = "[❮](bold green)"; };
        git_branch = { symbol = " "; style = "bold secondary"; };
        git_status = { style = "bold red"; };
      };
    };

    # Fastfetch — trimmed module list with separators; static layout (not
    # color-generated per theme), just fastfetch's own default coloring
    # instead of the bare/unstyled default preset.
    programs.fastfetch = {
      enable = true;
      settings = {
        logo.source = "NixOS_small";
        display.separator = "  ";
        modules = [
          "break"
          { type = "title"; }
          "separator"
          { type = "os"; key = " OS"; }
          { type = "kernel"; key = " Kernel"; }
          { type = "uptime"; key = " Uptime"; }
          { type = "packages"; key = " Packages"; }
          "separator"
          { type = "wm"; key = " WM"; }
          { type = "terminal"; key = " Terminal"; }
          "separator"
          { type = "cpu"; key = " CPU"; }
          { type = "gpu"; key = " GPU"; }
          { type = "memory"; key = " Memory"; }
          { type = "disk"; key = " Disk"; folders = "/"; }
          "break"
          { type = "colors"; }
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
