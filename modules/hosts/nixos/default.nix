{ inputs, config, ... }:
let
  features = config.flake.modules.nixos;
in
{
  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      features.base
      features.packages
      features.user
      features.ryoku
      features."llm-agents"
      features.steam
      features."home-manager"
      ./_configuration.nix
      ./_hardware-configuration.nix
    ];
  };
}
