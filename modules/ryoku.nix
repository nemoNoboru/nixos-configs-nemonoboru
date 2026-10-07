{ inputs, ... }:
{
  flake.modules.nixos.ryoku = {
    imports = [
      inputs.ryoku.nixosModules.default
      ./_ryoku-settings.nix
    ];
  };
}
