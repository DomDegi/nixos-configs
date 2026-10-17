# Document tooling: writing, compiling and processing course material.
# LaTeX (TeX Live medium + latexmk) and Typst (+ tinymist LSP) both preview
# live in VS Code: LaTeX Workshop rebuilds on save, Tinymist on every
# keystroke (config in config/vscode/settings.json; per-folder PDF export
# lives in that folder's .vscode/settings.json, e.g. the Obsidian vault).
{
  flake.modules.homeManager.documents = { pkgs, ... }: {
    home.packages = with pkgs; [
      # LaTeX: pdflatex/xelatex/lualatex + latexmk (LaTeX Workshop's default
      # recipe). Also pandoc's PDF engine:
      #   pandoc notes.md -o notes.pdf
      texliveMedium
      pandoc

      # Typst: `typst compile report.typ`; tinymist = LSP + live preview +
      # PDF export, used by the VS Code Tinymist extension (serverPath).
      typst
      tinymist

      # Scanned PDFs -> searchable/copy-pasteable: `ocrmypdf in.pdf out.pdf`
      ocrmypdf
    ];
  };
}
