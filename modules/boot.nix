# Bootloader (GRUB dual-boot with Windows), kernel, and the NTFS data
# partitions shared with the Windows install.
{
  flake.modules.nixos.boot = { pkgs, ... }: {
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      # --- Manual Windows Boot Entry ---
      extraEntries = ''
        menuentry "Windows" {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          search --fs-uuid --set=root E68F-608D
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
    };
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.timeout = 10; # Give yourself 10 seconds to choose Windows

    # Always use the bleeding-edge latest Linux kernel
    boot.kernelPackages = pkgs.linuxPackages_latest;

    boot.supportedFilesystems = [ "ntfs" ];

    fileSystems."/mnt/shared" = {
      device = "/dev/disk/by-uuid/7BC87C182CCB6762";
      fsType = "ntfs-3g";
      options = [ "rw" "uid=1000" "gid=100" "umask=022" ];
    };

    fileSystems."/mnt/windows" = {
      device = "/dev/disk/by-uuid/94C891ECC891CCBC";
      fsType = "ntfs-3g";
      options = [ "rw" "uid=1000" "gid=100" ];
    };

    systemd.tmpfiles.rules = [
      "L+ /home/domdegi/shared - - - - /mnt/shared"
      "L+ /home/domdegi/windows - - - - /mnt/windows"
    ];
  };
}
