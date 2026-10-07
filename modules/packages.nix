{
  flake.modules.nixos.packages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      neovim
      wget
      bun
      uv
      git
    ];
  };
}
