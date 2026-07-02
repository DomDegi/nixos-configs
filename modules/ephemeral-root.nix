# BTRFS ephemeral root: the @ subvolume is rolled back to a pristine
# state in the initrd on every boot. Anything worth keeping must be
# listed in persistence.nix.
{
  flake.modules.nixos.ephemeral-root = {
    boot.initrd.systemd.services.rollback = {
      description = "Rollback BTRFS root subvolume to a pristine state";
      wantedBy = [ "initrd.target" ];

      # 1. Properly escaped systemd unit names! Systemd requires \x2d for hyphens.
      # 'requires' strictly forces systemd to wait for the hardware to appear.
      requires = [ "dev-disk-by\\x2duuid-9e2795ab\\x2d5614\\x2d4890\\x2dbfc3\\x2d9dad9a669179.device" ];
      after = [ "dev-disk-by\\x2duuid-9e2795ab\\x2d5614\\x2d4890\\x2dbfc3\\x2d9dad9a669179.device" ];

      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";

      script = ''
        # 2. Bulletproof fallback: manually wait for the drive to populate
        while [ ! -b /dev/disk/by-uuid/9e2795ab-5614-4890-bfc3-9dad9a669179 ]; do
            sleep 1
        done

        mkdir -p /mnt-root
        mount -t btrfs -o subvol=/ /dev/disk/by-uuid/9e2795ab-5614-4890-bfc3-9dad9a669179 /mnt-root

        # Function to safely handle subvolumes created by things like Docker
        delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/mnt-root/$i"
          done
          btrfs subvolume delete "$1"
        }

        # Create old_roots unconditionally so 'find' never crashes
        mkdir -p /mnt-root/old_roots

        if [ -e /mnt-root/@ ]; then
            timestamp=$(date --date="@$(stat -c %Y /mnt-root/@)" "+%Y-%m-%d_%H:%M:%S")
            mv /mnt-root/@ "/mnt-root/old_roots/$timestamp"
        fi

        # Create the fresh root
        btrfs subvolume create /mnt-root/@

        # Added -mindepth 1 so it doesn't try to delete the parent directory
        for i in $(find /mnt-root/old_roots/ -mindepth 1 -maxdepth 1 -mtime +30); do
            delete_subvolume_recursively "$i"
        done

        umount /mnt-root
      '';
    };
  };
}
