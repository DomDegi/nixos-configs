# Thunar file manager: foot as "open terminal here", and right-click custom
# actions (~/.config/Thunar/uca.xml, owned by HM): Extract Here, Compress to
# .zip, Open folder in VS Code / Zed, Open Terminal Here. Archives
# double-click into xarchiver. Extraction uses libarchive's bsdtar (zip, tar.*,
# 7z, rar) with 7z as fallback; an archive with a single top-level folder is
# unpacked without an extra wrapping directory.
{
  flake.modules.nixos.thunar = { pkgs, ... }: {
    programs.thunar.enable = true;
    programs.xfconf.enable = true;
    programs.thunar.plugins = [ pkgs.thunar-volman ];

    # Required by Thunar for Trash, USB auto-mounting, and network drives
    services.gvfs.enable = true;
    # Required by Thunar to generate image thumbnails
    services.tumbler.enable = true;
  };

  flake.modules.homeManager.thunar = { pkgs, lib, ... }:
    let
      extract-here = pkgs.writeShellApplication {
        name = "extract-here";
        runtimeInputs = with pkgs; [ libarchive p7zip coreutils libnotify ];
        text = ''
          shopt -s nullglob dotglob
          for a in "$@"; do
            dir=$(dirname -- "$a")
            base=$(basename -- "$a")
            name=''${base%.*}
            name=''${name%.tar}
            dest="$dir/$name"
            n=1
            while [ -e "$dest" ]; do dest="$dir/$name ($n)"; n=$((n + 1)); done
            mkdir -p -- "$dest"
            if ! bsdtar -xf "$a" -C "$dest" 2>/dev/null \
              && ! 7z x -y -o"$dest" -- "$a" >/dev/null; then
              rm -rf -- "$dest"
              notify-send -i dialog-error "Extract failed" "$base"
              continue
            fi
            # Single top-level folder inside: lift it up instead of nesting.
            entries=("$dest"/*)
            if [ ''${#entries[@]} -eq 1 ] && [ -d "''${entries[0]}" ]; then
              inner=$(basename -- "''${entries[0]}")
              tmp="$dest.extract-$$"
              mv -- "''${entries[0]}" "$tmp"
              rmdir -- "$dest"
              if [ -e "$dir/$inner" ]; then mv -- "$tmp" "$dest"; else mv -- "$tmp" "$dir/$inner"; fi
            fi
          done
        '';
      };

      compress-zip = pkgs.writeShellApplication {
        name = "compress-zip";
        runtimeInputs = with pkgs; [ libarchive coreutils libnotify ];
        text = ''
          # Run from the files' directory with basenames (Thunar %N).
          if [ $# -eq 1 ]; then name=''${1%/}; name=''${name%.*}; [ -n "$name" ] || name=$1; else name=Archive; fi
          out="$name.zip"
          n=1
          while [ -e "$out" ]; do out="$name ($n).zip"; n=$((n + 1)); done
          bsdtar -a -cf "$out" -- "$@" || notify-send -i dialog-error "Compress failed" "$out"
        '';
      };

      archivePatterns = lib.concatStringsSep ";" [
        "*.zip" "*.ZIP" "*.7z" "*.rar" "*.RAR" "*.tar" "*.tar.gz" "*.tgz"
        "*.tar.xz" "*.txz" "*.tar.bz2" "*.tbz2" "*.tar.zst" "*.tzst"
        "*.gz" "*.xz" "*.bz2" "*.zst" "*.jar"
      ];
    in
    {
      home.packages = [ pkgs.xarchiver extract-here compress-zip ];

      # 1. Tell XFCE/Thunar to use Foot as the default terminal emulator
      xdg.configFile."xfce4/helpers.rc".text = ''
        TerminalEmulator=foot
      '';

      # 2. Teach XFCE how to launch Foot and pass the current directory to it
      xdg.dataFile."xfce4/helpers/foot.desktop".text = ''
        [Desktop Entry]
        Version=1.0
        Icon=foot
        Type=X-XFCE-Helper
        Name=Foot
        StartupNotify=false
        X-XFCE-Binaries=foot;
        X-XFCE-Category=TerminalEmulator
        X-XFCE-Commands=%B;
        X-XFCE-CommandsWithParameter=%B -D %s;
      '';

      # 3. Right-click custom actions
      xdg.configFile."Thunar/uca.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <actions>
        <action>
          <icon>archive-extract</icon>
          <name>Extract Here</name>
          <submenu></submenu>
          <unique-id>domdegi-extract-here</unique-id>
          <command>extract-here %F</command>
          <description>Extract into a folder next to the archive</description>
          <range></range>
          <patterns>${archivePatterns}</patterns>
          <other-files/>
        </action>
        <action>
          <icon>package-x-generic</icon>
          <name>Compress to .zip</name>
          <submenu></submenu>
          <unique-id>domdegi-compress-zip</unique-id>
          <command>cd %d &amp;&amp; compress-zip %N</command>
          <description>Create a .zip of the selection</description>
          <range></range>
          <patterns>*</patterns>
          <directories/>
          <audio-files/>
          <image-files/>
          <other-files/>
          <text-files/>
          <video-files/>
        </action>
        <action>
          <icon>vscode</icon>
          <name>Open in VS Code</name>
          <submenu></submenu>
          <unique-id>domdegi-open-code</unique-id>
          <command>code %f</command>
          <description>Open this folder in VS Code</description>
          <range>1-1</range>
          <patterns>*</patterns>
          <directories/>
        </action>
        <action>
          <icon>zed</icon>
          <name>Open in Zed</name>
          <submenu></submenu>
          <unique-id>domdegi-open-zed</unique-id>
          <command>zeditor %f</command>
          <description>Open this folder in Zed</description>
          <range>1-1</range>
          <patterns>*</patterns>
          <directories/>
        </action>
        <action>
          <icon>utilities-terminal</icon>
          <name>Open Terminal Here</name>
          <submenu></submenu>
          <unique-id>domdegi-terminal-here</unique-id>
          <command>foot -D %f</command>
          <description>Open a terminal in this folder</description>
          <range>1-1</range>
          <patterns>*</patterns>
          <directories/>
        </action>
        </actions>
      '';
    };
}
