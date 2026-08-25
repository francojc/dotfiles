{
  determinate,
  virby,
  ...
}: {
  imports = [
    determinate.darwinModules.default
    virby.darwinModules.default
  ];

  determinateNix = {
    enable = true;
    customSettings = {
      extra-substituters = [
        "https://virby-nix-darwin.cachix.org"
      ];
      extra-trusted-public-keys = [
        "virby-nix-darwin.cachix.org-1:z9GiEZeBU5bEeoDQjyfHPMGPBaIQJOOvYOOjGMKIlLo="
      ];
    };
  };

  services.virby.enable = true;
}
