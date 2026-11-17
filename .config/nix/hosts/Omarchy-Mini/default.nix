# Omarchy-Mini: Omarchy (Arch Linux + Hyprland) in a try-omarchy VM on the
# Mac mini (Mac-Minicore).
#
# Same shape as Omarchy-Air: Omarchy owns the OS and Nix manages only the user
# environment through standalone Home Manager. The difference is the profile:
# `arch/vm.nix` instead of `arch/native.nix`. The macOS host keeps the GPU for
# the local LLM servers; this guest does CPU-bound dev work.
{
  system = "aarch64-linux";

  # Routes this host to `homeConfigurations` (see lib/systems.nix `platformOf`).
  platform = "arch";

  username = "jeridf";
  useremail = "francojc@wfu.edu";
  # Matches the Omarchy "Tokyo Night" stock theme; revisit later.
  theme = "tokyonight";

  homeModules =
    (import ../../roles).arch
    ++ [
      ../../profiles/arch/base.nix
      ../../profiles/arch/vm.nix
      ./local.nix # host-specific tweaks; keep last
    ];
}
