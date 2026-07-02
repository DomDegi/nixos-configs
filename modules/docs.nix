# Generated documentation: harvests each module's header comment into a
# markdown reference (javadoc-style — docs live in the source).
# Regenerate with:  nix run .#docs > docs/reference.md
{
  perSystem = { pkgs, ... }: {
    packages.docs = pkgs.writeShellApplication {
      name = "gen-module-docs";
      runtimeInputs = with pkgs; [ gnugrep gawk findutils coreutils ];
      text = ''
        echo "# Module reference (generated)"
        echo
        echo "> Do not edit by hand. Regenerate from the module header comments:"
        echo "> \`nix run .#docs > docs/reference.md\`"
        echo

        find modules -name '*.nix' | sort | while read -r f; do
          name=''${f#modules/}

          # Which configuration classes does this file contribute to?
          # (|| true: files with no match must not trip pipefail)
          classes=$({ grep -o 'flake\.modules\.\(nixos\|homeManager\)' "$f" || true; } \
            | sort -u | sed 's/flake\.modules\.//' | paste -sd ' + ' -)
          [ -n "$classes" ] || classes="flake-parts"

          echo "## \`$name\`"
          echo
          echo "*Contributes to: $classes*"
          echo
          # Leading comment block = the module's docstring
          awk '/^#/ { sub(/^# ?/, ""); print; next } { exit }' "$f"
          echo
        done
      '';
    };
  };
}
