# Development tooling: docker, git, direnv, nix-ld, micro ($EDITOR), compilers, search tools.
{
  flake.modules.nixos.dev = {
    virtualisation.docker.enable = true;
    users.users.domdegi.extraGroups = [ "docker" ];

    # Dynamic-loader shim so unpatched prebuilt binaries run: Julia artifacts,
    # language servers downloaded by VS Code/Positron extensions, etc.
    programs.nix-ld.enable = true;
  };

  flake.modules.homeManager.dev = { pkgs, ... }: {
    home.packages = with pkgs; [
      fd
      ripgrep
      jq
      gcc
      claude-code
      micro # nano-style terminal editor: Ctrl+S save, Ctrl+Q quit
    ];

    # Used by git commit, sudoedit, crontab -e, ...
    home.sessionVariables = {
      EDITOR = "micro";
      VISUAL = "micro";
    };

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "DomDegi";
          email = "domenico.degiorgio@mail.polimi.it";
        };
        init = {
          defaultBranch = "main";
        };
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
