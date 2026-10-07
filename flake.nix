{
  description = "NixOS configuration for this machine, portable to clones";

  inputs = {
    llm-agents.url = "github:numtide/llm-agents.nix";
    ryoku = {
      url = "github:aethctl/Ryoku-on-NixOS/main";
    };
    # NixOS official package source, pinned to the nixos-26.05 branch.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # home-manager: per-user dotfiles/packages. Follow our nixpkgs so there is
    # exactly one nixpkgs in the graph.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { ryoku, self, nixpkgs, llm-agents, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ryoku.nixosModules.default
        ./ryoku.nix

        # Shared system config (GNOME, networking, user, packages).
        ./configuration.nix

        # This machine's hardware scan. Keep one per host:
        #   hosts/<hostname>/hardware-configuration.nix
        ./hosts/nixos/hardware-configuration.nix

        # Per-user dotfiles/packages (see home/).
        inputs.home-manager.nixosModules.home-manager
        ./home-manager.nix

        # AI coding tools from numtide/llm-agents.nix.
        ({ pkgs, ... }: {
          environment.systemPackages =
            with llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
              skills
              codegraph
              tuicr
              annot
              kandev-desktop
              herdr
              pi
              orca
              omp
              nono
              luvus
              sidecar
              td
            ];
        })
      ];
    };
  };
}
