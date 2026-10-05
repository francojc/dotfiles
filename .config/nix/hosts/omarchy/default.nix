# Omarchy (Arch Linux + Hyprland) user environment.
#
# This host is deliberately NOT a NixOS system. Omarchy owns the OS (kernel,
# systemd, pacman packages, theming); Nix manages only the user environment
# through a standalone Home Manager configuration. That is why there is no
# `hostModules` list here -- the flake's `mkHomeConfig` builder ignores it and
# evaluates `./home` plus `homeModules` only.
{
  system = "aarch64-linux";

  # Overrides the platform implied by `system` (aarch64-linux -> linux) so the
  # flake routes this host to `homeConfigurations` instead of
  # `nixosConfigurations`. See lib/systems.nix `helpers.platformOf`.
  platform = "arch";

  username = "jcf";
  useremail = "francojc@wfu.edu";
  # Matches the Omarchy "Tokyo Night" stock theme, so the small amount of
  # Nix-managed theming (nvim theme file, WezTerm) lines up with the desktop.
  theme = "tokyonight";

  # Appended to ./home by the standalone Home Manager builder.
  homeModules = [
    ../../profiles/arch/configuration.nix
  ];
}
