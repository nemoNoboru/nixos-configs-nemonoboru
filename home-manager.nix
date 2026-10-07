# Wire home-manager for the "nixos" user. Applied on every `nixos-rebuild switch`.
{ ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.nixos = {
      imports = [ ./home/default.nix ];
    };
  };
}
