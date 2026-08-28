{
  lib,
  username,
  ...
}: {
  # The guide creates this EFI system partition and labels the root filesystem.
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.loader.efi.canTouchEfiVariables = false;
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "virtio_net"
  ];

  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = lib.mkDefault {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
  };

  networking.networkmanager.enable = true;

  users.users.${username}.extraGroups = [
    "wheel"
    "networkmanager"
    "audio"
    "video"
  ];

  system.stateVersion = "24.11";
}
