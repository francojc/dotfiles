{ inputs, ... }:

{
  # imports = [
  #   inputs.nixvim.homeManagerModules.nixvim
  #   ./opts.nix
  # ];
  
  programs.nixvim = {
   enable = true;
  };

}
