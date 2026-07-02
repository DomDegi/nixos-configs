# Development tooling: docker, git, direnv, compilers, search tools.
{
  flake.modules.nixos.dev = {
    virtualisation.docker.enable = true;
    users.users.domdegi.extraGroups = [ "docker" ];
  };

  flake.modules.homeManager.dev = { pkgs, ... }: {
    home.packages = with pkgs; [
      fd
      ripgrep
      jq
      gcc
      claude-code
    ];

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
