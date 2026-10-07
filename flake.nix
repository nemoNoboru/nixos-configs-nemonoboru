{
  description = "NixOS configuration for this machine, portable to clones";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Module system for the flake itself (dendritic pattern).
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    llm-agents.url = "github:numtide/llm-agents.nix";
    ryoku.url = "github:aethctl/Ryoku-on-NixOS/main";

    # Per-user dotfiles/packages. Follow our nixpkgs so there is exactly one
    # nixpkgs in the graph.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Build the flake's outputs with flake-parts, using every module import-tree
  # finds under ./modules. This file stays tiny; features live in ./modules.
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
