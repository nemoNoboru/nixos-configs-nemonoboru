{ ... }:
{
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";
  home.stateVersion = "26.05";

  imports = [
    ./git.nix
    ./pi.nix
    # ./nvim.nix  # opt-in: makes home-manager own Neovim (see nvim.nix)
  ];
}
