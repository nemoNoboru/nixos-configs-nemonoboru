{ inputs, ... }:
{
  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.nixos = {
        imports = [ ../home/default.nix ];
      };
    };
  };
}
