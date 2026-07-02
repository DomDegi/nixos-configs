# sops-nix: secrets encrypted in-repo (secrets/secrets.yaml), decrypted
# at activation with the age key at /persist/var/lib/sops-nix/key.txt.
# /persist is neededForBoot, so the key is available early enough for
# neededForUsers secrets.
{ inputs, ... }:

{
  flake.modules.nixos.secrets = { config, ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops = {
      defaultSopsFile = ../secrets/secrets.yaml;
      age.keyFile = "/persist/var/lib/sops-nix/key.txt";
      # No SSH host keys on this machine — age key only.
      age.sshKeyPaths = [ ];
      gnupg.sshKeyPaths = [ ];

      # Decrypted to /run/secrets-for-users BEFORE users are created,
      # which is what lets hashedPasswordFile work with mutableUsers=false.
      secrets."domdegi-password-hash".neededForUsers = true;
    };

    users.users.domdegi.hashedPasswordFile =
      config.sops.secrets."domdegi-password-hash".path;
  };
}
