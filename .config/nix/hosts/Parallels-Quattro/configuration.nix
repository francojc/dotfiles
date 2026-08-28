{
  lib,
  username,
  ...
}: {
  # The guide creates this EFI system partition and labels the root filesystem.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
