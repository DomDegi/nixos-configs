# Document tooling: converting, compiling and processing course material.
{
  flake.modules.homeManager.documents = { pkgs, ... }: {
    home.packages = with pkgs; [
      # Anything -> Markdown (PDF, docx, pptx, xlsx, html...): `markitdown file.pdf`
      python3Packages.markitdown

      # Markdown -> PDF etc. `tectonic` is the LaTeX engine pandoc needs
      # for PDF output (self-contained, downloads packages on demand):
      #   pandoc notes.md -o notes.pdf --pdf-engine=tectonic
      pandoc
      tectonic

      # Scanned PDFs -> searchable/copy-pasteable: `ocrmypdf in.pdf out.pdf`
      ocrmypdf

      # Modern LaTeX alternative for reports: `typst compile report.typ`
      typst
    ];
  };
}
